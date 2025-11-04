// lib/features/quiz/presentation/providers/quiz_provider.dart
import 'package:flutter/material.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/usecases/get_quizzes.dart';
import '../../domain/usecases/submit_answer.dart';
import '../../domain/usecases/create_quiz.dart';

enum QuizStateStatus { initial, loading, loaded, error, submitting, submitted }

class QuizProvider extends ChangeNotifier {
  final GetQuizzes getQuizzes;
  final SubmitAnswer submitAnswer;
  final CreateQuiz createQuiz;

  QuizProvider({
    required this.getQuizzes,
    required this.submitAnswer,
    required this.createQuiz,
  });

  QuizStateStatus status = QuizStateStatus.initial;
  List<QuizEntity> quizzes = [];
  String? errorMessage;

  Future<void> loadQuizzes() async {
    status = QuizStateStatus.loading;
    notifyListeners();
    try {
      quizzes = await getQuizzes();
      status = QuizStateStatus.loaded;
    } catch (e) {
      status = QuizStateStatus.error;
      errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<bool> submit(String quizId, Map<String, String> answers) async {
    status = QuizStateStatus.submitting;
    notifyListeners();
    try {
      final ok = await submitAnswer(quizId, answers);
      status = ok ? QuizStateStatus.submitted : QuizStateStatus.error;
      notifyListeners();
      return ok;
    } catch (e) {
      status = QuizStateStatus.error;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<QuizEntity?> create(QuizEntity quiz) async {
    try {
      final created = await createQuiz(quiz);
      // reload quizzes or append
      quizzes.add(created);
      notifyListeners();
      return created;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
}
