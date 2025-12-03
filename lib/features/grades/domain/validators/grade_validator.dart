// lib/features/grades/domain/validators/grade_validator.dart
// Requirements: 16.1-16.6

import '../../data/models/grade_model.dart';

/// Validator for Grade data
/// **Validates: Requirements 16.1-16.6**
class GradeValidator {
  /// Validate grade data
  static ValidationResult validateGrade({
    required double score,
    required double maxScore,
  }) {
    final errors = <String>[];

    // Validate score is not negative
    if (score < 0) {
      errors.add('Score tidak boleh negatif');
    }

    // Validate max score is positive
    if (maxScore <= 0) {
      errors.add('Max score harus lebih dari 0');
    }

    // Validate score does not exceed max score
    if (score > maxScore) {
      errors.add('Score tidak boleh melebihi max score ($maxScore)');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate grade model
  static ValidationResult validateGradeModel(GradeModel grade) {
    final errors = <String>[];

    // Validate student ID
    if (grade.studentId.isEmpty) {
      errors.add('Student ID tidak boleh kosong');
    }

    // Validate class ID
    if (grade.classId.isEmpty) {
      errors.add('Class ID tidak boleh kosong');
    }

    // Validate item ID
    if (grade.itemId.isEmpty) {
      errors.add('Item ID tidak boleh kosong');
    }

    // Validate item type
    if (!['quiz', 'assignment'].contains(grade.itemType)) {
      errors.add('Item type tidak valid');
    }

    // Validate score
    final scoreValidation = validateGrade(
      score: grade.score,
      maxScore: grade.maxScore,
    );
    errors.addAll(scoreValidation.errors);

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Calculate percentage from score and max score
  static double calculatePercentage(double score, double maxScore) {
    if (maxScore <= 0) return 0;
    return (score / maxScore) * 100;
  }

  /// Validate percentage is within bounds
  static bool isValidPercentage(double percentage) {
    return percentage >= 0 && percentage <= 100;
  }
}

/// Result of validation
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });

  String get errorMessage => errors.join(', ');
}
