// lib/features/grades/domain/usecases/grades_usecases.dart
// Requirements: 13.1-13.5, 14.1-14.5

import '../../data/models/grade_model.dart';
import '../repositories/grades_repository.dart';

/// Use case for fetching student grades in a class
/// **Validates: Requirements 13.1-13.5**
class GetStudentGradesUseCase {
  final IGradesRepository _repository;

  GetStudentGradesUseCase(this._repository);

  Future<List<GradeModel>> execute(String studentId, String classId) {
    return _repository.fetchStudentGrades(studentId, classId);
  }
}

/// Use case for fetching current student's grades
class GetMyGradesUseCase {
  final IGradesRepository _repository;

  GetMyGradesUseCase(this._repository);

  Future<List<GradeModel>> execute() {
    return _repository.fetchMyGrades();
  }
}

/// Use case for fetching class grades (mentor view)
/// **Validates: Requirements 14.1-14.5**
class GetClassGradesUseCase {
  final IGradesRepository _repository;

  GetClassGradesUseCase(this._repository);

  Future<List<GradeModel>> execute(String classId) {
    return _repository.fetchClassGrades(classId);
  }
}

/// Use case for calculating student average
class CalculateStudentAverageUseCase {
  final IGradesRepository _repository;

  CalculateStudentAverageUseCase(this._repository);

  Future<double> execute(String studentId, String classId) {
    return _repository.calculateStudentAverage(studentId, classId);
  }
}

/// Use case for syncing grades from quiz
/// **Validates: Requirements 13.1-13.5**
class SyncGradesFromQuizUseCase {
  final IGradesRepository _repository;

  SyncGradesFromQuizUseCase(this._repository);

  Future<GradeModel?> execute({
    required String studentId,
    required String classId,
    required String quizId,
    required double score,
    required double maxScore,
    String? quizTitle,
  }) async {
    // Validate score bounds
    if (score < 0) {
      throw Exception('Score tidak boleh negatif');
    }
    if (maxScore <= 0) {
      throw Exception('Max score harus lebih dari 0');
    }
    if (score > maxScore) {
      throw Exception('Score tidak boleh melebihi max score');
    }

    return _repository.syncGradeFromQuiz(
      studentId: studentId,
      classId: classId,
      quizId: quizId,
      score: score,
      maxScore: maxScore,
      quizTitle: quizTitle,
    );
  }
}

/// Use case for syncing grades from assignment
/// **Validates: Requirements 13.1-13.5**
class SyncGradesFromAssignmentUseCase {
  final IGradesRepository _repository;

  SyncGradesFromAssignmentUseCase(this._repository);

  Future<GradeModel?> execute({
    required String studentId,
    required String classId,
    required String assignmentId,
    required double score,
    required double maxScore,
    String? assignmentTitle,
  }) async {
    // Validate score bounds
    if (score < 0) {
      throw Exception('Score tidak boleh negatif');
    }
    if (maxScore <= 0) {
      throw Exception('Max score harus lebih dari 0');
    }
    if (score > maxScore) {
      throw Exception('Score tidak boleh melebihi max score');
    }

    return _repository.syncGradeFromAssignment(
      studentId: studentId,
      classId: classId,
      assignmentId: assignmentId,
      score: score,
      maxScore: maxScore,
      assignmentTitle: assignmentTitle,
    );
  }
}

/// Use case for getting student grades summary (mentor view)
class GetStudentGradesSummaryUseCase {
  final IGradesRepository _repository;

  GetStudentGradesSummaryUseCase(this._repository);

  Future<List<Map<String, dynamic>>> execute(String classId) {
    return _repository.getStudentGradesSummary(classId);
  }
}

/// Use case for getting grades grouped by class
class GetGradesByClassUseCase {
  final IGradesRepository _repository;

  GetGradesByClassUseCase(this._repository);

  Future<Map<String, List<GradeModel>>> execute() {
    return _repository.getGradesByClass();
  }
}

/// Use case for getting overall GPA
class GetOverallGPAUseCase {
  final IGradesRepository _repository;

  GetOverallGPAUseCase(this._repository);

  Future<double> execute() {
    return _repository.getOverallGPA();
  }
}
