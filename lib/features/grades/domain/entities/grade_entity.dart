// lib/features/grades/domain/entities/grade_entity.dart
import 'package:equatable/equatable.dart';

/// Entity untuk Grade/Nilai
/// Represents a grade record for a student from quiz or assignment
class GradeEntity extends Equatable {
  final String id;
  final String studentId;
  final String classId;
  final String itemId; // quiz_id or assignment_id
  final String itemType; // 'quiz' | 'assignment'
  final double score;
  final double maxScore;
  final double percentage;
  final DateTime recordedAt;
  final String? itemTitle; // Optional: for display purposes
  final String? className; // Optional: for display purposes

  const GradeEntity({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.itemId,
    required this.itemType,
    required this.score,
    required this.maxScore,
    required this.percentage,
    required this.recordedAt,
    this.itemTitle,
    this.className,
  });

  /// Check if grade is from quiz
  bool get isQuizGrade => itemType == 'quiz';

  /// Check if grade is from assignment
  bool get isAssignmentGrade => itemType == 'assignment';

  /// Check if grade is passing (>= 60%)
  bool get isPassing => percentage >= 60;

  /// Get letter grade based on percentage
  String get letterGrade {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'E';
  }

  /// Copy with new values
  GradeEntity copyWith({
    String? id,
    String? studentId,
    String? classId,
    String? itemId,
    String? itemType,
    double? score,
    double? maxScore,
    double? percentage,
    DateTime? recordedAt,
    String? itemTitle,
    String? className,
  }) {
    return GradeEntity(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      itemId: itemId ?? this.itemId,
      itemType: itemType ?? this.itemType,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      percentage: percentage ?? this.percentage,
      recordedAt: recordedAt ?? this.recordedAt,
      itemTitle: itemTitle ?? this.itemTitle,
      className: className ?? this.className,
    );
  }

  @override
  List<Object?> get props => [
        id,
        studentId,
        classId,
        itemId,
        itemType,
        score,
        maxScore,
        percentage,
        recordedAt,
        itemTitle,
        className,
      ];
}

/// Valid grade item types
class GradeItemType {
  static const String quiz = 'quiz';
  static const String assignment = 'assignment';

  static const List<String> values = [quiz, assignment];

  static bool isValid(String type) => values.contains(type);
}

/// Utility class for grade calculations
class GradeCalculator {
  /// Calculate percentage from score and max score
  static double calculatePercentage(double score, double maxScore) {
    if (maxScore <= 0) return 0;
    return (score / maxScore) * 100;
  }

  /// Calculate average from list of grades
  static double calculateAverage(List<GradeEntity> grades) {
    if (grades.isEmpty) return 0;
    final totalPercentage = grades.fold<double>(
      0,
      (sum, grade) => sum + grade.percentage,
    );
    return totalPercentage / grades.length;
  }

  /// Calculate weighted average from list of grades
  static double calculateWeightedAverage(List<GradeEntity> grades) {
    if (grades.isEmpty) return 0;
    final totalScore = grades.fold<double>(0, (sum, grade) => sum + grade.score);
    final totalMaxScore = grades.fold<double>(
      0,
      (sum, grade) => sum + grade.maxScore,
    );
    if (totalMaxScore <= 0) return 0;
    return (totalScore / totalMaxScore) * 100;
  }

  /// Get GPA from percentage (4.0 scale)
  static double getGPA(double percentage) {
    if (percentage >= 90) return 4.0;
    if (percentage >= 80) return 3.0;
    if (percentage >= 70) return 2.0;
    if (percentage >= 60) return 1.0;
    return 0.0;
  }
}
