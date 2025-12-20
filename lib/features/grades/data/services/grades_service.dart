// lib/features/grades/data/services/grades_service.dart
// Fetch grades from quiz_attempts and assignment_submissions

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GradesService {
  final SupabaseClient supabaseClient;

  GradesService(this.supabaseClient);

  /// Fetch student grades for a specific class
  Future<Map<String, dynamic>> fetchStudentGrades(String classId) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return {'quiz_grades': [], 'assignment_grades': []};

      debugPrint('=== FETCHING STUDENT GRADES ===');
      debugPrint('Class ID: $classId');
      debugPrint('User ID: ${user.id}');

      // Fetch quiz grades
      final quizGrades = await supabaseClient
          .from('quiz_attempts')
          .select('''
            id,
            score,
            max_score,
            percentage,
            submitted_at,
            quizzes(
              id,
              title,
              max_attempts
            )
          ''')
          .eq('user_id', user.id)
          .eq('status', 'submitted')
          .order('submitted_at', ascending: false);

      debugPrint('Quiz attempts found: ${quizGrades.length}');

      // Filter quiz grades for this class
      final classQuizGrades = <Map<String, dynamic>>[];
      for (var attempt in quizGrades) {
        final quiz = attempt['quizzes'];
        if (quiz != null) {
          // Check if quiz belongs to this class
          final quizClass = await supabaseClient
              .from('quizzes')
              .select('class_id')
              .eq('id', quiz['id'])
              .maybeSingle();

          if (quizClass != null && quizClass['class_id'] == classId) {
            classQuizGrades.add({
              'id': attempt['id'],
              'title': quiz['title'] ?? 'Quiz',
              'score': attempt['score'] ?? 0,
              'max_score': attempt['max_score'] ?? 100,
              'percentage': attempt['percentage'] ?? 0,
              'submitted_at': attempt['submitted_at'],
              'type': 'quiz',
            });
          }
        }
      }

      // Fetch assignment grades
      final assignmentGrades = await supabaseClient
          .from('assignment_submissions')
          .select('''
            id,
            score,
            feedback,
            submitted_at,
            graded_at,
            assignments(
              id,
              title,
              max_score,
              class_id
            )
          ''')
          .eq('user_id', user.id)
          .eq('status', 'graded')
          .order('submitted_at', ascending: false);

      debugPrint('Assignment submissions found: ${assignmentGrades.length}');

      // Filter assignment grades for this class
      final classAssignmentGrades = <Map<String, dynamic>>[];
      for (var submission in assignmentGrades) {
        final assignment = submission['assignments'];
        if (assignment != null && assignment['class_id'] == classId) {
          classAssignmentGrades.add({
            'id': submission['id'],
            'title': assignment['title'] ?? 'Assignment',
            'score': submission['score'] ?? 0,
            'max_score': assignment['max_score'] ?? 100,
            'percentage': assignment['max_score'] > 0
                ? (submission['score'] / assignment['max_score']) * 100
                : 0,
            'submitted_at': submission['submitted_at'],
            'graded_at': submission['graded_at'],
            'feedback': submission['feedback'],
            'type': 'assignment',
          });
        }
      }

      debugPrint('Class quiz grades: ${classQuizGrades.length}');
      debugPrint('Class assignment grades: ${classAssignmentGrades.length}');

      return {
        'quiz_grades': classQuizGrades,
        'assignment_grades': classAssignmentGrades,
      };
    } catch (e) {
      debugPrint('Error fetchStudentGrades: $e');
      return {'quiz_grades': [], 'assignment_grades': []};
    }
  }

  /// Calculate average grade for student in class
  double calculateAverage(List<Map<String, dynamic>> allGrades) {
    if (allGrades.isEmpty) return 0.0;

    double totalScore = 0;
    double totalMaxScore = 0;

    for (var grade in allGrades) {
      totalScore += (grade['score'] as num).toDouble();
      totalMaxScore += (grade['max_score'] as num).toDouble();
    }

    return totalMaxScore > 0 ? (totalScore / totalMaxScore) * 100 : 0.0;
  }

  /// Get letter grade from percentage
  String getLetterGrade(double percentage) {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  // Legacy methods for compatibility
  Future<void> syncGradeFromQuiz({
    required String studentId,
    required String classId,
    required String quizId,
    required double score,
    required double maxScore,
    String? quizTitle,
  }) async {
    // This method is for compatibility only
    // Grades are automatically synced from quiz_attempts
    debugPrint(
      'syncGradeFromQuiz called - grades auto-synced from quiz_attempts',
    );
  }

  Future<void> syncGradeFromAssignment({
    required String studentId,
    required String classId,
    required String assignmentId,
    required double score,
    required double maxScore,
    String? assignmentTitle,
  }) async {
    // This method is for compatibility only
    // Grades are automatically synced from assignment_submissions
    debugPrint(
      'syncGradeFromAssignment called - grades auto-synced from assignment_submissions',
    );
  }

  Future<List<dynamic>> fetchMyGrades() async {
    // Return empty for compatibility
    return [];
  }

  Future<List<dynamic>> fetchClassGrades(String classId) async {
    // Return empty for compatibility
    return [];
  }

  Future<double> calculateStudentAverage(
    String studentId,
    String classId,
  ) async {
    final grades = await fetchStudentGrades(classId);
    final allGrades = <Map<String, dynamic>>[
      ...List<Map<String, dynamic>>.from(grades['quiz_grades'] ?? []),
      ...List<Map<String, dynamic>>.from(grades['assignment_grades'] ?? []),
    ];
    return calculateAverage(allGrades);
  }

  Future<List<Map<String, dynamic>>> getStudentGradesSummary(
    String classId,
  ) async {
    // Return empty for compatibility
    return [];
  }

  Future<Map<String, List<dynamic>>> getGradesByClass() async {
    // Return empty for compatibility
    return {};
  }

  Future<double> getOverallGPA() async {
    // Return 0 for compatibility
    return 0.0;
  }
}
