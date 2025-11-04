// lib/features/quiz/domain/usecases/get_quizzes.dart
import '../entities/quiz_entity.dart';
import '../repositories/quiz_repository.dart';

class GetQuizzes {
  final QuizRepository repository;
  GetQuizzes(this.repository);

  Future<List<QuizEntity>> call() async {
    return repository.getQuizzes();
  }
}
