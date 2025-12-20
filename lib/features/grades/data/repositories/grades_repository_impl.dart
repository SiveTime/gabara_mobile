// lib/features/grades/data/repositories/grades_repository_impl.dart
// Updated to work with new GradesService

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
  ) async {
    // Convert new service response to old format
    final data = await _gradesService.fetchStudentGrades(classId);
    final allGrades = [...data['quiz_grades'], ...data['assignment_grades']];

    return allGrades
        .map(
          (grade) => GradeModel(
            id: grade['id'],
            studentId: studentId,
            classId: classId,
            itemId: grade['id'],
            itemType: grade['type'],
            score: (grade['score'] as num).toDouble(),
            maxScore: (grade['max_score'] as num).toDouble(),
            percentage: (grade['percentage'] as num).toDouble(),
            recordedAt: DateTime.parse(
              grade['submitted_at'] ?? DateTime.now().toIso8601String(),
            ),
            className: 'Class',
          ),
        )
        .toList();
  }

  @override
  Future<List<GradeModel>> fetchMyGrades() async {
    return [];
  }

  @override
  Future<List<GradeModel>> fetchClassGrades(String classId) async {
    return [];
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
  }) async {
    await _gradesService.syncGradeFromQuiz(
      studentId: studentId,
      classId: classId,
      quizId: quizId,
      score: score,
      maxScore: maxScore,
      quizTitle: quizTitle,
    );
    return null;
  }

  @override
  Future<GradeModel?> syncGradeFromAssignment({
    required String studentId,
    required String classId,
    required String assignmentId,
    required double score,
    required double maxScore,
    String? assignmentTitle,
  }) async {
    await _gradesService.syncGradeFromAssignment(
      studentId: studentId,
      classId: classId,
      assignmentId: assignmentId,
      score: score,
      maxScore: maxScore,
      assignmentTitle: assignmentTitle,
    );
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentGradesSummary(String classId) {
    return _gradesService.getStudentGradesSummary(classId);
  }

  @override
  Future<Map<String, List<GradeModel>>> getGradesByClass() async {
    return {};
  }

  @override
  Future<double> getOverallGPA() {
    return _gradesService.getOverallGPA();
  }
}
