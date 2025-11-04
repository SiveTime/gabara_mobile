// lib/features/quiz/data/models/quiz_model.dart
import '../../domain/entities/quiz_entity.dart';

class OptionModel {
  final String id;
  final String text;
  final bool isCorrect;

  OptionModel({required this.id, required this.text, this.isCorrect = false});

  factory OptionModel.fromJson(Map<String, dynamic> json) => OptionModel(
        id: json['id'].toString(),
        text: json['text'] ?? '',
        isCorrect: json['is_correct'] == true || json['isCorrect'] == true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'is_correct': isCorrect,
      };
}

class QuestionModel {
  final String id;
  final String question;
  final List<OptionModel> options;

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        id: json['id'].toString(),
        question: json['question'] ?? '',
        options: (json['options'] as List<dynamic>? ?? [])
            .map((o) => OptionModel.fromJson(o as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options.map((o) => o.toJson()).toList(),
      };
}

class QuizModel extends QuizEntity {
  QuizModel({
    required super.id,
    required super.title,
    required super.description,
    required List<QuestionModel> questions,
    required super.openAt,
    required super.closeAt,
    super.attemptsAllowed = 1,
    super.durationMinutes = 0,
  }) : super(
          questions: questions
              .map((q) => q as dynamic) // domain stores generic question objects
              .toList()
        );

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    final qlist = (json['questions'] as List<dynamic>? ?? [])
        .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
        .toList();
    return QuizModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      questions: qlist,
      openAt: json['open_at'] != null ? DateTime.tryParse(json['open_at']) : null,
      closeAt: json['close_at'] != null ? DateTime.tryParse(json['close_at']) : null,
      attemptsAllowed: json['attempts_allowed'] ?? 1,
      durationMinutes: json['duration_minutes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'questions': questions.map((q) {
          if (q is QuestionModel) return q.toJson();
          return {};
        }).toList(),
      };
}
