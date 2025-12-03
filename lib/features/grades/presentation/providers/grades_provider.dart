// lib/features/grades/presentation/providers/grades_provider.dart
// Requirements: 13.1-13.5, 14.1-14.5

import 'package:flutter/material.dart';
import '../../data/models/grade_model.dart';
import '../../data/services/grades_service.dart';
import '../../domain/entities/grade_entity.dart';

class GradesProvider extends ChangeNotifier {
  final GradesService gradesService;

  GradesProvider(this.gradesService);

  // State variables
  List<GradeModel> _grades = [];
  Map<String, List<GradeModel>> _gradesByClass = {};
  List<Map<String, dynamic>> _studentSummaries = [];
  double _overallGPA = 0;
  double _classAverage = 0;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedClassId;

  // Getters
  List<GradeModel> get grades => _grades;
  Map<String, List<GradeModel>> get gradesByClass => _gradesByClass;
  List<Map<String, dynamic>> get studentSummaries => _studentSummaries;
  double get overallGPA => _overallGPA;
  double get classAverage => _classAverage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedClassId => _selectedClassId;

  /// Load grades for current student
  /// **Validates: Requirements 13.1-13.5**
  Future<void> loadMyGrades() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _grades = await gradesService.fetchMyGrades();
      _gradesByClass = await gradesService.getGradesByClass();
      _overallGPA = await gradesService.getOverallGPA();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load grades for a specific student in a class
  Future<void> loadStudentGrades(String studentId, String classId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _grades = await gradesService.fetchStudentGrades(studentId, classId);
      _classAverage = await gradesService.calculateStudentAverage(
        studentId,
        classId,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load class grades summary (mentor view)
  /// **Validates: Requirements 14.1-14.5**
  Future<void> loadClassGradesSummary(String classId) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedClassId = classId;
    notifyListeners();

    try {
      _studentSummaries = await gradesService.getStudentGradesSummary(classId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sync grade from quiz attempt
  Future<GradeModel?> syncGradeFromQuiz({
    required String studentId,
    required String classId,
    required String quizId,
    required double score,
    required double maxScore,
    String? quizTitle,
  }) async {
    try {
      final grade = await gradesService.syncGradeFromQuiz(
        studentId: studentId,
        classId: classId,
        quizId: quizId,
        score: score,
        maxScore: maxScore,
        quizTitle: quizTitle,
      );

      if (grade != null) {
        // Update local state
        final index = _grades.indexWhere((g) => g.itemId == quizId);
        if (index != -1) {
          _grades[index] = grade;
        } else {
          _grades.insert(0, grade);
        }
        notifyListeners();
      }
      return grade;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Sync grade from assignment submission
  Future<GradeModel?> syncGradeFromAssignment({
    required String studentId,
    required String classId,
    required String assignmentId,
    required double score,
    required double maxScore,
    String? assignmentTitle,
  }) async {
    try {
      final grade = await gradesService.syncGradeFromAssignment(
        studentId: studentId,
        classId: classId,
        assignmentId: assignmentId,
        score: score,
        maxScore: maxScore,
        assignmentTitle: assignmentTitle,
      );

      if (grade != null) {
        // Update local state
        final index = _grades.indexWhere((g) => g.itemId == assignmentId);
        if (index != -1) {
          _grades[index] = grade;
        } else {
          _grades.insert(0, grade);
        }
        notifyListeners();
      }
      return grade;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Get grades filtered by type
  List<GradeModel> get quizGrades =>
      _grades.where((g) => g.isQuizGrade).toList();

  List<GradeModel> get assignmentGrades =>
      _grades.where((g) => g.isAssignmentGrade).toList();

  /// Get passing grades
  List<GradeModel> get passingGrades =>
      _grades.where((g) => g.isPassing).toList();

  /// Get failing grades
  List<GradeModel> get failingGrades =>
      _grades.where((g) => !g.isPassing).toList();

  /// Calculate average for current grades
  double get currentAverage {
    if (_grades.isEmpty) return 0;
    return GradeCalculator.calculateAverage(_grades);
  }

  /// Calculate weighted average for current grades
  double get currentWeightedAverage {
    if (_grades.isEmpty) return 0;
    return GradeCalculator.calculateWeightedAverage(_grades);
  }

  /// Get total items count
  int get totalItems => _grades.length;

  /// Get quiz count
  int get quizCount => quizGrades.length;

  /// Get assignment count
  int get assignmentCount => assignmentGrades.length;

  /// Set selected class
  void setSelectedClass(String? classId) {
    _selectedClassId = classId;
    notifyListeners();
  }

  /// Clear grades
  void clearGrades() {
    _grades = [];
    _gradesByClass = {};
    _studentSummaries = [];
    _overallGPA = 0;
    _classAverage = 0;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
