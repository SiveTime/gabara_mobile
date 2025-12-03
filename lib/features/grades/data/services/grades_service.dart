// lib/features/grades/data/services/grades_service.dart
// Requirements: 13.1-13.5, 14.1-14.5

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/grade_model.dart';
import '../../domain/entities/grade_entity.dart';

class GradesService {
  final SupabaseClient supabaseClient;

  GradesService(this.supabaseClient);

  /// Fetch all grades for a student in a specific class
  /// **Validates: Requirements 13.1-13.5**
  Future<List<GradeModel>> fetchStudentGrades(
    String studentId,
    String classId,
  ) async {
    try {
      final response = await supabaseClient
          .from('grades')
          .select('''
            id, student_id, class_id, item_id, item_type,
            score, max_score, percentage, recorded_at,
            classes(name)
          ''')
          .eq('student_id', studentId)
          .eq('class_id', classId)
          .order('recorded_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => GradeModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetchStudentGrades: $e');
      return [];
    }
  }

  /// Fetch all grades for current student across all classes
  Future<List<GradeModel>> fetchMyGrades() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return [];

      final response = await supabaseClient
          .from('grades')
          .select('''
            id, student_id, class_id, item_id, item_type,
            score, max_score, percentage, recorded_at,
            classes(name)
          ''')
          .eq('student_id', user.id)
          .order('recorded_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => GradeModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetchMyGrades: $e');
      return [];
    }
  }

  /// Fetch all grades for a class (mentor view)
  /// **Validates: Requirements 14.1-14.5**
  Future<List<GradeModel>> fetchClassGrades(String classId) async {
    try {
      final response = await supabaseClient
          .from('grades')
          .select('''
            id, student_id, class_id, item_id, item_type,
            score, max_score, percentage, recorded_at
          ''')
          .eq('class_id', classId)
          .order('recorded_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => GradeModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetchClassGrades: $e');
      return [];
    }
  }

  /// Calculate average grade for a student in a class
  Future<double> calculateStudentAverage(
    String studentId,
    String classId,
  ) async {
    try {
      final grades = await fetchStudentGrades(studentId, classId);
      if (grades.isEmpty) return 0;

      return GradeCalculator.calculateAverage(grades);
    } catch (e) {
      debugPrint('Error calculateStudentAverage: $e');
      return 0;
    }
  }

  /// Sync grade from quiz attempt
  /// **Validates: Requirements 13.1-13.5**
  Future<GradeModel?> syncGradeFromQuiz({
    required String studentId,
    required String classId,
    required String quizId,
    required double score,
    required double maxScore,
    String? quizTitle,
  }) async {
    try {
      final percentage = maxScore > 0 ? (score / maxScore) * 100 : 0.0;

      // Check if grade already exists
      final existing = await supabaseClient
          .from('grades')
          .select()
          .eq('student_id', studentId)
          .eq('item_id', quizId)
          .maybeSingle();

      if (existing != null) {
        // Update existing grade
        final response = await supabaseClient
            .from('grades')
            .update({
              'score': score,
              'max_score': maxScore,
              'percentage': percentage,
              'recorded_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', existing['id'])
            .select()
            .single();

        return GradeModel.fromJson(response);
      } else {
        // Create new grade
        final response = await supabaseClient
            .from('grades')
            .insert({
              'student_id': studentId,
              'class_id': classId,
              'item_id': quizId,
              'item_type': 'quiz',
              'score': score,
              'max_score': maxScore,
              'percentage': percentage,
              'recorded_at': DateTime.now().toUtc().toIso8601String(),
            })
            .select()
            .single();

        return GradeModel.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error syncGradeFromQuiz: $e');
      rethrow;
    }
  }

  /// Sync grade from assignment submission
  /// **Validates: Requirements 13.1-13.5**
  Future<GradeModel?> syncGradeFromAssignment({
    required String studentId,
    required String classId,
    required String assignmentId,
    required double score,
    required double maxScore,
    String? assignmentTitle,
  }) async {
    try {
      final percentage = maxScore > 0 ? (score / maxScore) * 100 : 0.0;

      // Check if grade already exists
      final existing = await supabaseClient
          .from('grades')
          .select()
          .eq('student_id', studentId)
          .eq('item_id', assignmentId)
          .maybeSingle();

      if (existing != null) {
        // Update existing grade
        final response = await supabaseClient
            .from('grades')
            .update({
              'score': score,
              'max_score': maxScore,
              'percentage': percentage,
              'recorded_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', existing['id'])
            .select()
            .single();

        return GradeModel.fromJson(response);
      } else {
        // Create new grade
        final response = await supabaseClient
            .from('grades')
            .insert({
              'student_id': studentId,
              'class_id': classId,
              'item_id': assignmentId,
              'item_type': 'assignment',
              'score': score,
              'max_score': maxScore,
              'percentage': percentage,
              'recorded_at': DateTime.now().toUtc().toIso8601String(),
            })
            .select()
            .single();

        return GradeModel.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error syncGradeFromAssignment: $e');
      rethrow;
    }
  }

  /// Get student grades summary for a class (mentor view)
  Future<List<Map<String, dynamic>>> getStudentGradesSummary(
    String classId,
  ) async {
    try {
      // Get all enrolled students
      final enrollments = await supabaseClient
          .from('class_enrollments')
          .select('''
            user_id,
            profiles(id, full_name)
          ''')
          .eq('class_id', classId)
          .eq('status', 'active');

      final List<Map<String, dynamic>> summaries = [];

      for (final enrollment in enrollments) {
        final studentId = enrollment['user_id'] as String;
        final studentName = enrollment['profiles']?['full_name'] ?? 'Unknown';

        // Get grades for this student
        final grades = await fetchStudentGrades(studentId, classId);
        final average = GradeCalculator.calculateAverage(grades);
        final quizCount = grades.where((g) => g.isQuizGrade).length;
        final assignmentCount = grades.where((g) => g.isAssignmentGrade).length;

        summaries.add({
          'student_id': studentId,
          'student_name': studentName,
          'average': average,
          'quiz_count': quizCount,
          'assignment_count': assignmentCount,
          'total_items': grades.length,
        });
      }

      // Sort by average descending
      summaries.sort(
        (a, b) => (b['average'] as double).compareTo(a['average'] as double),
      );

      return summaries;
    } catch (e) {
      debugPrint('Error getStudentGradesSummary: $e');
      return [];
    }
  }

  /// Get grades grouped by class for current student
  Future<Map<String, List<GradeModel>>> getGradesByClass() async {
    try {
      final grades = await fetchMyGrades();
      final Map<String, List<GradeModel>> grouped = {};

      for (final grade in grades) {
        final classId = grade.classId;
        if (!grouped.containsKey(classId)) {
          grouped[classId] = [];
        }
        grouped[classId]!.add(grade);
      }

      return grouped;
    } catch (e) {
      debugPrint('Error getGradesByClass: $e');
      return {};
    }
  }

  /// Get overall GPA for current student
  Future<double> getOverallGPA() async {
    try {
      final grades = await fetchMyGrades();
      if (grades.isEmpty) return 0;

      final average = GradeCalculator.calculateAverage(grades);
      return GradeCalculator.getGPA(average);
    } catch (e) {
      debugPrint('Error getOverallGPA: $e');
      return 0;
    }
  }
}
