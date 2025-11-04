// lib/features/quiz/domain/entities/quiz_entity.dart
class OptionEntity {
  final String id;
  final String text;
  final bool isCorrect;

  OptionEntity({required this.id, required this.text, this.isCorrect = false});
}

class QuestionEntity {
  final String id;
  final String question;
  final List<OptionEntity> options;

  QuestionEntity({
    required this.id,
    required this.question,
    required this.options,
  });
}

class QuizEntity {
  final String id;
  final String title;
  final String description;
  final List<dynamic> questions; // can be QuestionEntity or QuestionModel
  final DateTime? openAt;
  final DateTime? closeAt;
  final int attemptsAllowed;
  final int durationMinutes;

  QuizEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    this.openAt,
    this.closeAt,
    this.attemptsAllowed = 1,
    this.durationMinutes = 0,
  });
}
