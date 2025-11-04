// lib/features/quiz/data/repositories/quiz_repository_impl.dart
import 'package:gabara_mobile/features/quiz/domain/entities/quiz_entity.dart';
import 'package:gabara_mobile/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:gabara_mobile/features/quiz/data/models/quiz_model.dart';
import 'package:gabara_mobile/features/quiz/data/services/quiz_service.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizService service;
  QuizRepositoryImpl(this.service);

  @override
  Future<List<QuizEntity>> getQuizzes() async {
    try {
      final raw = await service.fetchQuizzesRaw();
      final list = raw.map((j) => QuizModel.fromJson(j as Map<String, dynamic>)).toList();
      return list;
    } catch (e) {
      // fallback: return empty
      return [];
    }
  }

  @override
  Future<QuizEntity> getQuizById(String id) async {
    final raw = await service.fetchQuizByIdRaw(id);
    if (raw == null) {
      throw Exception('Quiz not found');
    }
    return QuizModel.fromJson(raw as Map<String, dynamic>);
  }

  @override
  Future<bool> submitAnswers(String quizId, Map<String, String> answers) async {
    return service.submitAnswersRaw(quizId, answers);
  }

  @override
  Future<QuizEntity> createQuiz(QuizEntity quiz) async {
    // convert to payload - best effort from QuizEntity
    final payload = {
      'title': quiz.title,
      'description': quiz.description,
      'questions': quiz.questions.map((q) {
        if (q is Map) return q;
        // if q is QuestionModel/Entity - attempt to convert
        try {
          return (q as dynamic).toJson();
        } catch (_) {
          return {};
        }
      }).toList(),
    };
    final raw = await service.createQuizRaw(payload);
    return QuizModel.fromJson(raw as Map<String, dynamic>);
  }
}
