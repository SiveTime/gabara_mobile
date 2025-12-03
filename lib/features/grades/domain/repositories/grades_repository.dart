// lib/features/grades/domain/repositories/grades_repository.dart
// Requirements: 13.1-13.5, 14.1-14.5

import '../../data/models/grade_model.dart';

/// Abstract interface for Grades repository
/// Defines contract for grades data operations
abstract class IGradesRepository {
  /// Fetch all grades for a student in a specific class
  /// **Validates: Requirements 13.1-13.5**
  Future<List<GradeModel>> fetchStudentGrades(String studentId, String classId);

  /// Fetch all grades for current student across all classes
  Future<List<GradeModel>> fetchMyGrades();

  /// Fetch all grades for a class (mentor view)
  /// **Validates: Requirements 14.1-14.5**
  Future<List<GradeModel>> fetchClassGrades(String classId);

  /// Calculate average grade for a student in a class
  Future<double> calculateStudentAverage(String studentId, String classId);

  /// Sync grade from quiz attempt
  Future<GradeModel?> syncGradeFromQuiz({
    required String studentId,
    required String classId,
    required String quizId,
    required double score,
    required double maxScore,
    String? quizTitle,
  });

  /// Sync grade from assignment submission
  Future<GradeModel?> syncGradeFromAssignment({
    required String studentId,
    required String classId,
    required String assignmentId,
    required double score,
    required double maxScore,
    String? assignmentTitle,
  });

  /// Get student grades summary for a class (mentor view)
  Future<List<Map<String, dynamic>>> getStudentGradesSummary(String classId);

  /// Get grades grouped by class for current student
  Future<Map<String, List<GradeModel>>> getGradesByClass();

  /// Get overall GPA for current student
  Future<double> getOverallGPA();
}
