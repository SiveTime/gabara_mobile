// lib/features/grades/data/repositories/grades_repository_impl.dart
// Requirements: 13.1-13.5, 14.1-14.5

import '../../domain/repositories/grades_repository.dart';
import '../models/grade_model.dart';
import '../services/grades_service.dart';

/// Implementation of IGradesRepository
/// Delegates operations to GradesService
class GradesRepositoryImpl implements IGradesRepository {
  final GradesService _gradesService;

  GradesRepositoryImpl(this._gradesService);

  @override
  Future<List<GradeModel>> fetchStudentGrades(
    String studentId,
    String classId,
  ) {
    return _gradesService.fetchStudentGrades(studentId, classId);
  }

  @override
  Future<List<GradeModel>> fetchMyGrades() {
    return _gradesService.fetchMyGrades();
  }

  @override
  Future<List<GradeModel>> fetchClassGrades(String classId) {
    return _gradesService.fetchClassGrades(classId);
  }

  @override
  Future<double> calculateStudentAverage(String studentId, String classId) {
    return _gradesService.calculateStudentAverage(studentId, classId);
  }

  @override
  Future<GradeModel?> syncGradeFromQuiz({
    required String studentId,
    required String classId,
    required String quizId,
    required double score,
    required double maxScore,
    String? quizTitle,
  }) {
    return _gradesService.syncGradeFromQuiz(
      studentId: studentId,
      classId: classId,
      quizId: quizId,
      score: score,
      maxScore: maxScore,
      quizTitle: quizTitle,
    );
  }

  @override
  Future<GradeModel?> syncGradeFromAssignment({
    required String studentId,
    required String classId,
    required String assignmentId,
    required double score,
    required double maxScore,
    String? assignmentTitle,
  }) {
    return _gradesService.syncGradeFromAssignment(
      studentId: studentId,
      classId: classId,
      assignmentId: assignmentId,
      score: score,
      maxScore: maxScore,
      assignmentTitle: assignmentTitle,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentGradesSummary(String classId) {
    return _gradesService.getStudentGradesSummary(classId);
  }

  @override
  Future<Map<String, List<GradeModel>>> getGradesByClass() {
    return _gradesService.getGradesByClass();
  }

  @override
  Future<double> getOverallGPA() {
    return _gradesService.getOverallGPA();
  }
}
