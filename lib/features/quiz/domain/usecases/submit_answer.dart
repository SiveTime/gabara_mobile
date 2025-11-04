// lib/features/quiz/domain/usecases/submit_answer.dart
import '../repositories/quiz_repository.dart';

class SubmitAnswer {
  final QuizRepository repository;
  SubmitAnswer(this.repository);

  /// answers: { questionId: selectedOptionId }
  Future<bool> call(String quizId, Map<String, String> answers) async {
    return repository.submitAnswers(quizId, answers);
  }
}
