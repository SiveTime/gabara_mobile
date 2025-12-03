// lib/features/assignments/domain/usecases/assignment_usecases.dart
// Requirements: 5.1-5.8, 6.1-6.6, 7.1-7.5, 8.1-8.4, 9.1-9.5, 12.1-12.6

import '../../data/models/assignment_model.dart';
import '../../data/models/submission_model.dart';
import '../repositories/assignment_repository.dart';

/// Use case for creating a new assignment
/// **Validates: Requirements 5.1-5.8**
class CreateAssignmentUseCase {
  final IAssignmentRepository _repository;

  CreateAssignmentUseCase(this._repository);

  Future<AssignmentModel?> execute(AssignmentModel assignment) async {
    // Validate deadline is not in the past
    if (assignment.deadline.isBefore(DateTime.now())) {
      throw Exception('Deadline tidak boleh di masa lalu');
    }

    // Validate max score
    if (assignment.maxScore <= 0) {
      throw Exception('Max score harus lebih dari 0');
    }

    return _repository.createAssignment(assignment);
  }
}

/// Use case for fetching assignments by mentor
/// **Validates: Requirements 6.1-6.6**
class GetAssignmentsByMentorUseCase {
  final IAssignmentRepository _repository;

  GetAssignmentsByMentorUseCase(this._repository);

  Future<List<AssignmentModel>> execute() {
    return _repository.fetchAssignmentsByMentor();
  }
}

/// Use case for fetching assignments by class
class GetAssignmentsByClassUseCase {
  final IAssignmentRepository _repository;

  GetAssignmentsByClassUseCase(this._repository);

  Future<List<AssignmentModel>> execute(String classId) {
    return _repository.fetchAssignmentsByClass(classId);
  }
}

/// Use case for fetching a single assignment
class GetAssignmentByIdUseCase {
  final IAssignmentRepository _repository;

  GetAssignmentByIdUseCase(this._repository);

  Future<AssignmentModel?> execute(String assignmentId) {
    return _repository.fetchAssignmentById(assignmentId);
  }
}

/// Use case for updating an assignment
/// **Validates: Requirements 7.1-7.5**
class UpdateAssignmentUseCase {
  final IAssignmentRepository _repository;

  UpdateAssignmentUseCase(this._repository);

  Future<AssignmentModel?> execute(
    AssignmentModel assignment, {
    bool allowDeadlineChange = true,
  }) async {
    // Check if assignment has submissions
    final hasSubmissions = await _repository.hasSubmissions(assignment.id);

    if (hasSubmissions && !allowDeadlineChange) {
      // Get original assignment to compare
      final original = await _repository.fetchAssignmentById(assignment.id);
      if (original != null) {
        if (original.deadline != assignment.deadline) {
          throw Exception(
            'Tidak dapat mengubah deadline karena sudah ada submission',
          );
        }
        if (original.maxScore != assignment.maxScore) {
          throw Exception(
            'Tidak dapat mengubah max score karena sudah ada submission',
          );
        }
      }
    }

    return _repository.updateAssignment(assignment);
  }
}

/// Use case for deleting an assignment
/// **Validates: Requirements 8.1-8.4**
class DeleteAssignmentUseCase {
  final IAssignmentRepository _repository;

  DeleteAssignmentUseCase(this._repository);

  Future<void> execute(String assignmentId) {
    return _repository.deleteAssignment(assignmentId);
  }
}

/// Use case for submitting an assignment (student)
/// **Validates: Requirements 12.1-12.6**
class SubmitAssignmentUseCase {
  final IAssignmentRepository _repository;

  SubmitAssignmentUseCase(this._repository);

  Future<SubmissionModel?> execute(SubmissionModel submission) async {
    // Validate content is not empty
    if (submission.content.trim().isEmpty) {
      throw Exception('Konten submission tidak boleh kosong');
    }

    return _repository.submitAssignment(submission);
  }
}

/// Use case for fetching submissions for an assignment
class GetSubmissionsUseCase {
  final IAssignmentRepository _repository;

  GetSubmissionsUseCase(this._repository);

  Future<List<SubmissionModel>> execute(String assignmentId) {
    return _repository.fetchSubmissions(assignmentId);
  }
}

/// Use case for fetching student's submission
class GetStudentSubmissionUseCase {
  final IAssignmentRepository _repository;

  GetStudentSubmissionUseCase(this._repository);

  Future<SubmissionModel?> execute(String assignmentId) {
    return _repository.fetchStudentSubmission(assignmentId);
  }
}

/// Use case for grading a submission
/// **Validates: Requirements 9.1-9.5**
class GradeSubmissionUseCase {
  final IAssignmentRepository _repository;

  GradeSubmissionUseCase(this._repository);

  Future<SubmissionModel?> execute({
    required String submissionId,
    required double score,
    required String feedback,
    required double maxScore,
  }) async {
    // Validate score bounds
    if (score < 0) {
      throw Exception('Score tidak boleh negatif');
    }
    if (score > maxScore) {
      throw Exception('Score tidak boleh melebihi max score ($maxScore)');
    }

    return _repository.gradeSubmission(
      submissionId: submissionId,
      score: score,
      feedback: feedback,
    );
  }
}
