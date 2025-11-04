// lib/features/quiz/domain/usecases/create_quiz.dart
import '../entities/quiz_entity.dart';
import '../repositories/quiz_repository.dart';

class CreateQuiz {
  final QuizRepository repository;
  CreateQuiz(this.repository);

  Future<QuizEntity> call(QuizEntity quiz) async {
    return repository.createQuiz(quiz);
  }
}
