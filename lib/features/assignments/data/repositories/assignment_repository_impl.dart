// lib/features/assignments/data/repositories/assignment_repository_impl.dart
// Requirements: 5.1-5.8, 6.1-6.6, 7.1-7.5, 8.1-8.4, 9.1-9.5, 12.1-12.6

import '../../domain/repositories/assignment_repository.dart';
import '../models/assignment_model.dart';
import '../models/submission_model.dart';
import '../services/assignment_service.dart';

/// Implementation of IAssignmentRepository
/// Delegates operations to AssignmentService
class AssignmentRepositoryImpl implements IAssignmentRepository {
  final AssignmentService _assignmentService;

  AssignmentRepositoryImpl(this._assignmentService);

  @override
  Future<AssignmentModel?> createAssignment(AssignmentModel assignment) {
    return _assignmentService.createAssignment(assignment);
  }

  @override
  Future<List<AssignmentModel>> fetchAssignmentsByMentor() {
    return _assignmentService.fetchAssignmentsByMentor();
  }

  @override
  Future<List<AssignmentModel>> fetchAssignmentsByClass(String classId) {
    return _assignmentService.fetchAssignmentsByClass(classId);
  }

  @override
  Future<AssignmentModel?> fetchAssignmentById(String assignmentId) {
    return _assignmentService.fetchAssignmentById(assignmentId);
  }

  @override
  Future<AssignmentModel?> updateAssignment(AssignmentModel assignment) {
    return _assignmentService.updateAssignment(assignment);
  }

  @override
  Future<void> deleteAssignment(String assignmentId) {
    return _assignmentService.deleteAssignment(assignmentId);
  }

  @override
  Future<SubmissionModel?> submitAssignment(SubmissionModel submission) {
    return _assignmentService.submitAssignment(submission);
  }

  @override
  Future<List<SubmissionModel>> fetchSubmissions(String assignmentId) {
    return _assignmentService.fetchSubmissions(assignmentId);
  }

  @override
  Future<SubmissionModel?> fetchSubmissionById(String submissionId) {
    return _assignmentService.fetchSubmissionById(submissionId);
  }

  @override
  Future<SubmissionModel?> fetchStudentSubmission(String assignmentId) {
    return _assignmentService.fetchStudentSubmission(assignmentId);
  }

  @override
  Future<SubmissionModel?> gradeSubmission({
    required String submissionId,
    required double score,
    required String feedback,
  }) {
    return _assignmentService.gradeSubmission(
      submissionId: submissionId,
      score: score,
      feedback: feedback,
    );
  }

  @override
  Future<int> getSubmissionCount(String assignmentId) {
    return _assignmentService.getSubmissionCount(assignmentId);
  }

  @override
  Future<bool> hasSubmissions(String assignmentId) {
    return _assignmentService.hasSubmissions(assignmentId);
  }

  @override
  Future<List<Map<String, dynamic>>> getMyClasses() {
    return _assignmentService.getMyClasses();
  }
}
