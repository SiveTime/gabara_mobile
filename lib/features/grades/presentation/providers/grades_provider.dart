// lib/features/grades/presentation/providers/grades_provider.dart
// Updated to work with new GradesService

import 'package:flutter/material.dart';
import '../../data/services/grades_service.dart';
import '../../data/models/grade_model.dart';

class GradesProvider extends ChangeNotifier {
  final GradesService gradesService;

  GradesProvider(this.gradesService);

  // State variables
  Map<String, dynamic>? _gradesData;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, dynamic>? get gradesData => _gradesData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load grades for current student in a specific class
  Future<void> loadStudentGrades(String classId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _gradesData = await gradesService.fetchStudentGrades(classId);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error loading student grades: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get quiz grades as GradeModel list
  List<GradeModel> get quizGrades {
    if (_gradesData == null) return [];
    final rawGrades = List<Map<String, dynamic>>.from(
      _gradesData!['quiz_grades'] ?? [],
    );
    return rawGrades.map((grade) => _convertToGradeModel(grade)).toList();
  }

  /// Get assignment grades as GradeModel list
  List<GradeModel> get assignmentGrades {
    if (_gradesData == null) return [];
    final rawGrades = List<Map<String, dynamic>>.from(
      _gradesData!['assignment_grades'] ?? [],
    );
    return rawGrades.map((grade) => _convertToGradeModel(grade)).toList();
  }

  /// Get all grades as GradeModel list
  List<GradeModel> get allGrades {
    return [...quizGrades, ...assignmentGrades];
  }

  /// Get grades (for compatibility)
  List<GradeModel> get grades => allGrades;

  /// Get grades by class
  Map<String, List<GradeModel>> get gradesByClass {
    final Map<String, List<GradeModel>> result = {};
    for (final grade in allGrades) {
      result[grade.classId] ??= [];
      result[grade.classId]!.add(grade);
    }
    return result;
  }

  /// Get current average
  double get currentAverage => overallAverage;

  /// Get quiz count
  int get quizCount => quizGrades.length;

  /// Get assignment count
  int get assignmentCount => assignmentGrades.length;

  /// Get class average (alias for overall average)
  double get classAverage => overallAverage;

  /// Calculate quiz average
  double get quizAverage {
    final rawGrades = List<Map<String, dynamic>>.from(
      _gradesData?['quiz_grades'] ?? [],
    );
    return gradesService.calculateAverage(rawGrades);
  }

  /// Calculate assignment average
  double get assignmentAverage {
    final rawGrades = List<Map<String, dynamic>>.from(
      _gradesData?['assignment_grades'] ?? [],
    );
    return gradesService.calculateAverage(rawGrades);
  }

  /// Calculate overall average
  double get overallAverage {
    final rawGrades = [
      ...List<Map<String, dynamic>>.from(_gradesData?['quiz_grades'] ?? []),
      ...List<Map<String, dynamic>>.from(
        _gradesData?['assignment_grades'] ?? [],
      ),
    ];
    return gradesService.calculateAverage(rawGrades);
  }

  /// Get letter grade
  String get letterGrade {
    return gradesService.getLetterGrade(overallAverage);
  }

  /// Clear grades data
  void clearGrades() {
    _gradesData = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Load class grades summary for mentor
  Future<void> loadClassGradesSummary(String classId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _gradesData = await gradesService.fetchStudentGrades(classId);
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error loading class grades summary: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get student summaries for mentor view
  List<Map<String, dynamic>> get studentSummaries {
    if (_gradesData == null) return [];

    // Group grades by student and calculate summaries
    final Map<String, List<GradeModel>> gradesByStudent = {};
    for (final grade in allGrades) {
      gradesByStudent[grade.studentId] ??= [];
      gradesByStudent[grade.studentId]!.add(grade);
    }

    return gradesByStudent.entries.map((entry) {
      final studentGrades = entry.value;
      final average = studentGrades.isNotEmpty
          ? studentGrades.fold(0.0, (sum, g) => sum + g.percentage) /
                studentGrades.length
          : 0.0;

      return {
        'student_id': entry.key,
        'student_name': 'Student ${entry.key.substring(0, 8)}', // Placeholder
        'total_grades': studentGrades.length,
        'average': average,
        'quiz_count': studentGrades.where((g) => g.isQuizGrade).length,
        'assignment_count': studentGrades
            .where((g) => g.isAssignmentGrade)
            .length,
      };
    }).toList();
  }

  // Legacy methods for compatibility
  Future<void> loadMyGrades() async {
    // For compatibility - does nothing
    debugPrint('loadMyGrades called - use loadStudentGrades instead');
  }

  /// Convert raw grade data to GradeModel
  GradeModel _convertToGradeModel(Map<String, dynamic> grade) {
    return GradeModel(
      id: grade['id']?.toString() ?? '',
      studentId: grade['student_id']?.toString() ?? '',
      classId: grade['class_id']?.toString() ?? '',
      itemId: grade['item_id']?.toString() ?? grade['id']?.toString() ?? '',
      itemType: grade['type'] ?? 'quiz',
      score: (grade['score'] ?? 0).toDouble(),
      maxScore: (grade['max_score'] ?? 100).toDouble(),
      percentage: (grade['percentage'] ?? 0).toDouble(),
      recordedAt:
          _parseDateTime(grade['submitted_at'] ?? grade['graded_at']) ??
          DateTime.now(),
      itemTitle: grade['title'],
      className: grade['class_name'],
    );
  }

  /// Parse DateTime from string
  DateTime? _parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      debugPrint('Error parsing DateTime: $dateString - $e');
      return null;
    }
  }
}
