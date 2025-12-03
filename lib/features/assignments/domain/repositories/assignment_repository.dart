// lib/features/assignments/domain/repositories/assignment_repository.dart
// Requirements: 5.1-5.8, 6.1-6.6, 7.1-7.5, 8.1-8.4, 9.1-9.5, 12.1-12.6

import '../../data/models/assignment_model.dart';
import '../../data/models/submission_model.dart';

/// Abstract interface for Assignment repository
/// Defines contract for assignment and submission data operations
abstract class IAssignmentRepository {
  /// Create a new assignment
  /// **Validates: Requirements 5.1-5.8**
  Future<AssignmentModel?> createAssignment(AssignmentModel assignment);

  /// Fetch all assignments created by the current mentor
  /// **Validates: Requirements 6.1-6.6**
  Future<List<AssignmentModel>> fetchAssignmentsByMentor();

  /// Fetch assignments for a specific class
  Future<List<AssignmentModel>> fetchAssignmentsByClass(String classId);

  /// Fetch a single assignment by ID
  Future<AssignmentModel?> fetchAssignmentById(String assignmentId);

  /// Update an assignment
  /// **Validates: Requirements 7.1-7.5**
  Future<AssignmentModel?> updateAssignment(AssignmentModel assignment);

  /// Delete an assignment
  /// **Validates: Requirements 8.1-8.4**
  Future<void> deleteAssignment(String assignmentId);

  /// Submit an assignment (student)
  /// **Validates: Requirements 12.1-12.6**
  Future<SubmissionModel?> submitAssignment(SubmissionModel submission);

  /// Fetch all submissions for an assignment (mentor)
  Future<List<SubmissionModel>> fetchSubmissions(String assignmentId);

  /// Fetch a single submission by ID
  Future<SubmissionModel?> fetchSubmissionById(String submissionId);

  /// Fetch student's submission for an assignment
  Future<SubmissionModel?> fetchStudentSubmission(String assignmentId);

  /// Grade a submission (mentor)
  /// **Validates: Requirements 9.1-9.5**
  Future<SubmissionModel?> gradeSubmission({
    required String submissionId,
    required double score,
    required String feedback,
  });

  /// Get submission count for an assignment
  Future<int> getSubmissionCount(String assignmentId);

  /// Check if assignment has submissions
  Future<bool> hasSubmissions(String assignmentId);

  /// Get classes owned by current mentor
  Future<List<Map<String, dynamic>>> getMyClasses();
}
