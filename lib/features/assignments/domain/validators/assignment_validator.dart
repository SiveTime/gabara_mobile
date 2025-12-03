// lib/features/assignments/domain/validators/assignment_validator.dart
// Requirements: 16.1-16.6

import '../../data/models/assignment_model.dart';
import '../../data/models/submission_model.dart';

/// Validator for Assignment data
/// **Validates: Requirements 16.1-16.6**
class AssignmentValidator {
  /// Validate assignment data for creation
  static ValidationResult validateForCreate(AssignmentModel assignment) {
    final errors = <String>[];

    // Validate title
    if (assignment.title.trim().isEmpty) {
      errors.add('Judul tugas tidak boleh kosong');
    }

    // Validate class ID
    if (assignment.classId.isEmpty) {
      errors.add('Kelas harus dipilih');
    }

    // Validate deadline is not in the past
    if (assignment.deadline.isBefore(DateTime.now())) {
      errors.add('Deadline tidak boleh di masa lalu');
    }

    // Validate max score
    if (assignment.maxScore <= 0) {
      errors.add('Max score harus lebih dari 0');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate assignment data for update
  static ValidationResult validateForUpdate(
    AssignmentModel assignment, {
    bool hasSubmissions = false,
    AssignmentModel? original,
  }) {
    final errors = <String>[];

    // Validate title
    if (assignment.title.trim().isEmpty) {
      errors.add('Judul tugas tidak boleh kosong');
    }

    // Validate max score
    if (assignment.maxScore <= 0) {
      errors.add('Max score harus lebih dari 0');
    }

    // If has submissions, prevent changing deadline and max score
    if (hasSubmissions && original != null) {
      if (original.deadline != assignment.deadline) {
        errors.add('Tidak dapat mengubah deadline karena sudah ada submission');
      }
      if (original.maxScore != assignment.maxScore) {
        errors.add(
          'Tidak dapat mengubah max score karena sudah ada submission',
        );
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

/// Validator for Submission data
/// **Validates: Requirements 16.1-16.6**
class SubmissionValidator {
  /// Validate submission data
  static ValidationResult validateSubmission(SubmissionModel submission) {
    final errors = <String>[];

    // Validate content
    if (submission.content.trim().isEmpty) {
      errors.add('Konten submission tidak boleh kosong');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate score for grading
  static ValidationResult validateScore(double score, double maxScore) {
    final errors = <String>[];

    // Validate score is not negative
    if (score < 0) {
      errors.add('Score tidak boleh negatif');
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

  /// Check if submission is late
  static bool isLateSubmission(DateTime submittedAt, DateTime deadline) {
    return submittedAt.isAfter(deadline);
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
