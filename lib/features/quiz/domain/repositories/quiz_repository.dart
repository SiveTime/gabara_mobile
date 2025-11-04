// lib/features/quiz/domain/repositories/quiz_repository.dart
import '../entities/quiz_entity.dart';

abstract class QuizRepository {
  Future<List<QuizEntity>> getQuizzes();
  Future<QuizEntity> getQuizById(String id);
  Future<bool> submitAnswers(String quizId, Map<String, String> answers); // questionId -> optionId
  Future<QuizEntity> createQuiz(QuizEntity quiz);
}
