// lib/features/quiz/presentation/providers/student_quiz_provider.dart
// Requirements: 1.2, 1.3, 1.4, 1.5, 3.3, 4.1, 4.2, 4.4, 5.3

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/models/quiz_attempt_model.dart';
import '../../data/models/quiz_model.dart';
import '../../data/services/student_quiz_service.dart';

class StudentQuizProvider extends ChangeNotifier {
  final StudentQuizService studentQuizService;

  StudentQuizProvider(this.studentQuizService);

  // State variables
  QuizModel? _currentQuiz;
  QuizAttemptModel? _currentAttempt;
  List<QuizAttemptModel> _attemptHistory = [];
  Map<String, String?> _currentAnswers = {}; // questionId -> optionId
  int _remainingSeconds = 0;
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  Timer? _timer;

  // Getters
  QuizModel? get currentQuiz => _currentQuiz;
  QuizAttemptModel? get currentAttempt => _currentAttempt;
  List<QuizAttemptModel> get attemptHistory => _attemptHistory;
  Map<String, String?> get currentAnswers => _currentAnswers;
  int get remainingSeconds => _remainingSeconds;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  /// Get formatted timer string (M:SS)
  /// **Validates: Requirements 4.1**
  String get formattedTimer => formatDuration(_remainingSeconds);

  /// Format duration in seconds to M:SS format
  static String formatDuration(int totalSeconds) {
    if (totalSeconds < 0) return '0:00';
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get count of answered questions
  /// **Validates: Requirements 5.1**
  int get answeredCount =>
      _currentAnswers.values.where((v) => v != null).length;

  /// Get total questions count
  int get totalQuestions => _currentQuiz?.questionCount ?? 0;

  /// Get current question (if quiz is loaded)
  QuestionModel? get currentQuestion {
    if (_currentQuiz == null) return null;
    if (_currentQuestionIndex < 0 ||
        _currentQuestionIndex >= _currentQuiz!.questionModels.length) {
      return null;
    }
    return _currentQuiz!.questionModels[_currentQuestionIndex];
  }

  /// Check if student can start a new quiz attempt
  /// **Validates: Requirements 1.4, 1.5**
  bool canStartQuiz() {
    if (_currentQuiz == null) return false;

    // Check if quiz is published
    if (!_currentQuiz!.isPublished) return false;

    // Check date range - DateTime sudah dalam local time dari Supabase
    final now = DateTime.now();

    if (_currentQuiz!.openAt != null && now.isBefore(_currentQuiz!.openAt!)) {
      return false;
    }
    if (_currentQuiz!.closeAt != null && now.isAfter(_currentQuiz!.closeAt!)) {
      return false;
    }

    // Check max attempts
    if (_attemptHistory.length >= _currentQuiz!.attemptsAllowed) {
      return false;
    }

    return true;
  }

  /// Get reason why quiz cannot be started
  String? getCannotStartReason() {
    if (_currentQuiz == null) return 'Quiz tidak ditemukan';
    if (!_currentQuiz!.isPublished) return 'Quiz belum diterbitkan';

    final now = DateTime.now();

    if (_currentQuiz!.openAt != null && now.isBefore(_currentQuiz!.openAt!)) {
      return 'Quiz belum dibuka';
    }
    if (_currentQuiz!.closeAt != null && now.isAfter(_currentQuiz!.closeAt!)) {
      return 'Quiz sudah ditutup';
    }
    if (_attemptHistory.length >= _currentQuiz!.attemptsAllowed) {
      return 'Kesempatan mengerjakan sudah habis';
    }

    return null;
  }

  /// Get student status text
  /// **Validates: Requirements 1.2, 1.3**
  String getStudentStatus() {
    if (_attemptHistory.isEmpty) {
      return 'Belum mengerjakan';
    }

    final hasFinished = _attemptHistory.any((a) => a.isFinished);
    if (hasFinished) {
      return 'Selesai';
    }

    final hasInProgress = _attemptHistory.any((a) => a.status == 'in_progress');
    if (hasInProgress) {
      return 'Sedang mengerjakan';
    }

    return 'Sedang mengerjakan';
  }

  /// Check if there's an in-progress attempt that can be resumed
  bool hasInProgressAttempt() {
    return _attemptHistory.any((a) => a.status == 'in_progress');
  }

  /// Get the in-progress attempt if exists
  QuizAttemptModel? getInProgressAttempt() {
    try {
      return _attemptHistory.firstWhere((a) => a.status == 'in_progress');
    } catch (e) {
      return null;
    }
  }

  /// Get button text based on state
  String getStartButtonText() {
    if (hasInProgressAttempt()) {
      return 'Lanjutkan Quiz';
    }
    return 'Mulai Quiz';
  }

  /// Check if student can start or resume quiz
  bool canStartOrResumeQuiz() {
    if (_currentQuiz == null) return false;
    if (!_currentQuiz!.isPublished) return false;

    final now = DateTime.now();
    if (_currentQuiz!.openAt != null && now.isBefore(_currentQuiz!.openAt!)) {
      return false;
    }
    if (_currentQuiz!.closeAt != null && now.isAfter(_currentQuiz!.closeAt!)) {
      return false;
    }

    // Can resume if there's an in-progress attempt
    if (hasInProgressAttempt()) {
      return true;
    }

    // Can start new if attempts not exhausted
    final finishedAttempts = _attemptHistory.where((a) => a.isFinished).length;
    return finishedAttempts < _currentQuiz!.attemptsAllowed;
  }

  /// Load quiz with attempt history
  Future<void> loadQuizWithAttempts(String quizId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch quiz details
      _currentQuiz = await studentQuizService.fetchQuizForStudent(quizId);

      // Fetch attempt history
      _attemptHistory = await studentQuizService.fetchAttemptsByQuiz(quizId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Start a new quiz attempt or resume existing one
  /// **Validates: Requirements 3.3**
  Future<bool> startQuizAttempt() async {
    if (_currentQuiz == null) return false;

    // Prevent race condition: Check if already loading
    if (_isLoading) {
      debugPrint('Cannot start quiz: Already loading');
      return false;
    }

    // Check if there's an in-progress attempt to resume
    final inProgressAttempt = getInProgressAttempt();
    if (inProgressAttempt != null) {
      return await resumeQuizAttempt(inProgressAttempt);
    }

    // Otherwise start new attempt
    if (!canStartQuiz()) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create new attempt
      _currentAttempt = await studentQuizService.createAttempt(
        _currentQuiz!.id,
      );

      // Initialize answers map
      _currentAnswers = {};
      for (final question in _currentQuiz!.questions) {
        _currentAnswers[question.id] = null;
      }

      // Reset question index
      _currentQuestionIndex = 0;

      // Start timer
      _remainingSeconds = _currentQuiz!.durationMinutes * 60;
      startTimer();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Resume an existing in-progress attempt
  Future<bool> resumeQuizAttempt(QuizAttemptModel attempt) async {
    if (_currentQuiz == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentAttempt = attempt;

      // Initialize answers map from existing answers
      _currentAnswers = {};
      for (final question in _currentQuiz!.questions) {
        _currentAnswers[question.id] = null;
      }

      // Load existing answers if any
      for (final answer in attempt.answerModels) {
        if (_currentAnswers.containsKey(answer.questionId)) {
          _currentAnswers[answer.questionId] = answer.selectedOptionId;
        }
      }

      // Reset question index
      _currentQuestionIndex = 0;

      // Calculate remaining time based on when attempt started
      final elapsedSeconds = DateTime.now()
          .difference(attempt.startedAt)
          .inSeconds;
      final totalSeconds = _currentQuiz!.durationMinutes * 60;
      _remainingSeconds = (totalSeconds - elapsedSeconds).clamp(
        0,
        totalSeconds,
      );

      // If time already expired, auto-submit
      if (_remainingSeconds <= 0) {
        _isLoading = false;
        notifyListeners();
        await submitQuizAttempt();
        return false;
      }

      startTimer();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Select an answer for current question
  /// **Validates: Requirements 4.4, 4.5**
  void selectAnswer(String questionId, String optionId) {
    // Validasi: Quiz harus ada dan aktif
    if (_currentQuiz == null || _currentAttempt == null) {
      debugPrint('Cannot select answer: Quiz or attempt not active');
      return;
    }

    // Validasi: Question harus ada di quiz
    QuestionModel? question;
    try {
      final foundQuestion = _currentQuiz!.questions.firstWhere(
        (q) => q.id == questionId,
      );
      question = foundQuestion is QuestionModel ? foundQuestion : null;
    } catch (e) {
      debugPrint('Cannot select answer: Question $questionId not found');
      return;
    }

    if (question == null) {
      debugPrint(
        'Cannot select answer: Question $questionId is not a QuestionModel',
      );
      return;
    }

    // Validasi: Option harus ada di question
    try {
      question.options.firstWhere((o) => o.id == optionId);
    } catch (e) {
      debugPrint(
        'Cannot select answer: Option $optionId not found in question $questionId',
      );
      return;
    }

    // Validasi: Attempt harus masih in_progress
    if (_currentAttempt!.status != 'in_progress') {
      debugPrint('Cannot select answer: Attempt is not in progress');
      return;
    }

    // Validasi: Timer harus masih berjalan
    if (_remainingSeconds <= 0) {
      debugPrint('Cannot select answer: Time expired');
      return;
    }

    // Atomic update: Simpan jawaban dengan validasi
    final previousAnswer = _currentAnswers[questionId];
    _currentAnswers[questionId] = optionId;

    debugPrint(
      'Answer selected: Question $questionId -> Option $optionId (was: $previousAnswer)',
    );
    notifyListeners();
  }

  /// Navigate to specific question
  void goToQuestion(int index) {
    if (index >= 0 && index < totalQuestions) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  /// Go to next question
  void nextQuestion() {
    if (_currentQuestionIndex < totalQuestions - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  /// Go to previous question
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  /// Check if question is answered
  bool isQuestionAnswered(int index) {
    if (_currentQuiz == null || index >= _currentQuiz!.questions.length) {
      return false;
    }
    final questionId = _currentQuiz!.questions[index].id;
    return _currentAnswers[questionId] != null;
  }

  /// Submit quiz attempt
  /// **Validates: Requirements 5.3**
  Future<bool> submitQuizAttempt() async {
    if (_currentAttempt == null || _currentQuiz == null) return false;

    // Prevent double submission
    if (_isSubmitting) {
      debugPrint('Cannot submit: Already submitting');
      return false;
    }

    // Validate attempt is still in progress
    if (_currentAttempt!.status != 'in_progress') {
      debugPrint('Cannot submit: Attempt is not in progress');
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Stop timer
      stopTimer();

      // Validate answers before submission
      final validatedAnswers = _validateAnswersBeforeSubmit();

      debugPrint('Submitting quiz with ${validatedAnswers.length} answers');
      debugPrint('Validated answers: $validatedAnswers');

      // Submit answers
      _currentAttempt = await studentQuizService.submitAttempt(
        _currentAttempt!.id,
        validatedAnswers,
        _currentQuiz!,
      );

      // Refresh attempt history
      _attemptHistory = await studentQuizService.fetchAttemptsByQuiz(
        _currentQuiz!.id,
      );

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Start countdown timer
  /// **Validates: Requirements 4.1, 4.2**
  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        // Timer expired - auto submit
        timer.cancel();
        submitQuizAttempt();
      }
    });
  }

  /// Stop timer
  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Load attempt result for viewing
  Future<void> loadAttemptResult(String attemptId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentAttempt = await studentQuizService.fetchAttemptById(attemptId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear current quiz state
  void clearQuizState() {
    stopTimer();
    _currentQuiz = null;
    _currentAttempt = null;
    _attemptHistory = [];
    _currentAnswers = {};
    _remainingSeconds = 0;
    _currentQuestionIndex = 0;
    _errorMessage = null;
    notifyListeners();
  }

  /// Validate answers before submission to ensure data integrity
  Map<String, String?> _validateAnswersBeforeSubmit() {
    final validatedAnswers = <String, String?>{};

    if (_currentQuiz == null) return validatedAnswers;

    for (final question in _currentQuiz!.questions) {
      final selectedOptionId = _currentAnswers[question.id];

      if (selectedOptionId != null && selectedOptionId.isNotEmpty) {
        // Validate that the selected option exists in the question
        final optionExists = question.options.any(
          (o) => o.id == selectedOptionId,
        );

        if (optionExists) {
          validatedAnswers[question.id] = selectedOptionId;
          debugPrint(
            '✅ Valid answer: Question ${question.id} -> Option $selectedOptionId',
          );
        } else {
          // Invalid option, don't include in submission
          debugPrint(
            '❌ Invalid answer removed: Question ${question.id} -> Option $selectedOptionId (not found)',
          );
          validatedAnswers[question.id] = null;
        }
      } else {
        // No answer provided
        validatedAnswers[question.id] = null;
        debugPrint('⚪ No answer: Question ${question.id}');
      }
    }

    return validatedAnswers;
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }
}
