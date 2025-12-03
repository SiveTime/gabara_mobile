// lib/features/quiz/data/services/student_quiz_service.dart
// Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 13.1-13.5

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz_attempt_model.dart';
import '../models/quiz_model.dart';
import '../../../grades/data/services/grades_service.dart';

class StudentQuizService {
  final SupabaseClient supabaseClient;

  StudentQuizService(this.supabaseClient);

  /// Fetch all attempts for a specific quiz by current student
  /// **Validates: Requirements 8.5**
  Future<List<QuizAttemptModel>> fetchAttemptsByQuiz(String quizId) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return [];

      final response = await supabaseClient
          .from('quiz_attempts')
          .select('''
            id, quiz_id, user_id, started_at, submitted_at, 
            status, score, percentage,
            quiz_answers(
              id, attempt_id, question_id, option_id, is_correct, created_at
            )
          ''')
          .eq('quiz_id', quizId)
          .eq('user_id', user.id)
          .order('started_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => QuizAttemptModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetchAttemptsByQuiz: $e');
      return [];
    }
  }

  /// Fetch a single attempt by ID with all answers
  Future<QuizAttemptModel?> fetchAttemptById(String attemptId) async {
    try {
      final response = await supabaseClient
          .from('quiz_attempts')
          .select('''
            id, quiz_id, user_id, started_at, submitted_at, 
            status, score, percentage,
            quiz_answers(
              id, attempt_id, question_id, option_id, is_correct, created_at
            )
          ''')
          .eq('id', attemptId)
          .maybeSingle();

      if (response == null) return null;
      return QuizAttemptModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetchAttemptById: $e');
      return null;
    }
  }

  /// Create a new quiz attempt
  /// **Validates: Requirements 8.1**
  Future<QuizAttemptModel?> createAttempt(String quizId) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User tidak login');

      // Get current attempt count for this quiz
      final attemptCount = await getAttemptCount(quizId);

      // Konversi waktu lokal ke UTC sebelum menyimpan ke Supabase
      final response = await supabaseClient
          .from('quiz_attempts')
          .insert({
            'quiz_id': quizId,
            'user_id': user.id,
            'attempt_number': attemptCount + 1,
            'started_at': DateTime.now().toUtc().toIso8601String(),
            'status': 'in_progress',
          })
          .select()
          .single();

      return QuizAttemptModel.fromJson(response);
    } catch (e) {
      debugPrint('Error createAttempt: $e');
      rethrow;
    }
  }

  /// Submit quiz attempt with answers and calculate score
  /// **Validates: Requirements 8.2, 8.3, 8.4**
  Future<QuizAttemptModel?> submitAttempt(
    String attemptId,
    Map<String, String?> answers, // questionId -> optionId
    QuizModel quiz,
  ) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User tidak login');

      // Calculate score
      int correctCount = 0;
      final answerRecords = <Map<String, dynamic>>[];

      for (final question in quiz.questions) {
        final selectedOptionId = answers[question.id];
        bool? isCorrect;

        if (selectedOptionId != null) {
          // Find if selected option is correct
          try {
            final selectedOption = question.options.firstWhere(
              (o) => o.id == selectedOptionId,
            );
            isCorrect = selectedOption.isCorrect;
            if (isCorrect) correctCount++;
          } catch (e) {
            // Option not found, mark as incorrect
            isCorrect = false;
            debugPrint(
              'Option not found for question ${question.id}: $selectedOptionId',
            );
          }
        }

        answerRecords.add({
          'attempt_id': attemptId,
          'question_id': question.id,
          'option_id': selectedOptionId,
          'is_correct': isCorrect,
        });
      }

      // Insert all answers
      if (answerRecords.isNotEmpty) {
        await supabaseClient.from('quiz_answers').insert(answerRecords);
      }

      // Calculate percentage
      final percentage = quiz.questionCount > 0
          ? (correctCount / quiz.questionCount) * 100
          : 0.0;

      // Update attempt with score and submitted status
      // Konversi waktu lokal ke UTC sebelum menyimpan ke Supabase
      await supabaseClient
          .from('quiz_attempts')
          .update({
            'submitted_at': DateTime.now().toUtc().toIso8601String(),
            'status': 'submitted',
            'score': correctCount.toDouble(),
            'max_score': quiz.questionCount.toDouble(),
            'percentage': percentage,
          })
          .eq('id', attemptId);

      // Sync grade to grades table
      // **Validates: Requirements 13.1-13.5**
      if (quiz.classId != null) {
        try {
          final gradesService = GradesService(supabaseClient);
          await gradesService.syncGradeFromQuiz(
            studentId: user.id,
            classId: quiz.classId!,
            quizId: quiz.id,
            score: correctCount.toDouble(),
            maxScore: quiz.questionCount.toDouble(),
            quizTitle: quiz.title,
          );
          debugPrint('Grade synced for quiz: ${quiz.title}');
        } catch (gradeError) {
          // Log error but don't fail the quiz submission
          debugPrint('Error syncing grade: $gradeError');
        }
      }

      // Fetch and return updated attempt
      return await fetchAttemptById(attemptId);
    } catch (e) {
      debugPrint('Error submitAttempt: $e');
      rethrow;
    }
  }

  /// Get attempt count for a quiz by current student
  Future<int> getAttemptCount(String quizId) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return 0;

      final response = await supabaseClient
          .from('quiz_attempts')
          .select('id')
          .eq('quiz_id', quizId)
          .eq('user_id', user.id);

      return (response as List).length;
    } catch (e) {
      debugPrint('Error getAttemptCount: $e');
      return 0;
    }
  }

  /// Check if student can start a new attempt
  Future<bool> canStartAttempt(String quizId, int maxAttempts) async {
    final count = await getAttemptCount(quizId);
    return count < maxAttempts;
  }

  /// Fetch quiz with questions for student (without showing correct answers)
  Future<QuizModel?> fetchQuizForStudent(String quizId) async {
    try {
      final response = await supabaseClient
          .from('quizzes')
          .select('''
            id, class_id, title, description, duration_minutes, 
            max_attempts, is_active, open_at, close_at, 
            created_by, created_at, updated_at,
            questions(
              id, quiz_id, question_text, question_type, order_index,
              options(id, question_id, option_text, is_correct, order_index)
            )
          ''')
          .eq('id', quizId)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) return null;
      return QuizModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetchQuizForStudent: $e');
      return null;
    }
  }
}
