// lib/features/grades/data/services/grades_analytics_service.dart
// Analytics and visualization service for grades

import '../models/grade_model.dart';
import '../../domain/entities/grade_entity.dart';

/// Service untuk analytics dan visualisasi data grades
class GradesAnalyticsService {
  /// Calculate performance trends over time
  List<Map<String, dynamic>> calculatePerformanceTrends(
    List<GradeModel> grades,
  ) {
    if (grades.isEmpty) return [];

    // Group grades by month
    final Map<String, List<GradeModel>> gradesByMonth = {};

    for (final grade in grades) {
      final monthKey =
          '${grade.recordedAt.year}-${grade.recordedAt.month.toString().padLeft(2, '0')}';
      gradesByMonth[monthKey] ??= [];
      gradesByMonth[monthKey]!.add(grade);
    }

    // Calculate average for each month
    final trends = <Map<String, dynamic>>[];
    final sortedMonths = gradesByMonth.keys.toList()..sort();

    for (final month in sortedMonths) {
      final monthGrades = gradesByMonth[month]!;
      final average = GradeCalculator.calculateAverage(monthGrades);

      trends.add({
        'month': month,
        'average': average,
        'count': monthGrades.length,
        'quizCount': monthGrades.where((g) => g.isQuizGrade).length,
        'assignmentCount': monthGrades.where((g) => g.isAssignmentGrade).length,
      });
    }

    return trends;
  }

  /// Calculate grade distribution
  Map<String, int> calculateGradeDistribution(List<GradeModel> grades) {
    final distribution = <String, int>{
      'A': 0, // 90-100
      'B': 0, // 80-89
      'C': 0, // 70-79
      'D': 0, // 60-69
      'E': 0, // <60
    };

    for (final grade in grades) {
      final percentage = grade.percentage;
      if (percentage >= 90) {
        distribution['A'] = distribution['A']! + 1;
      } else if (percentage >= 80) {
        distribution['B'] = distribution['B']! + 1;
      } else if (percentage >= 70) {
        distribution['C'] = distribution['C']! + 1;
      } else if (percentage >= 60) {
        distribution['D'] = distribution['D']! + 1;
      } else {
        distribution['E'] = distribution['E']! + 1;
      }
    }

    return distribution;
  }

  /// Calculate subject performance comparison
  Map<String, Map<String, dynamic>> calculateSubjectPerformance(
    Map<String, List<GradeModel>> gradesByClass,
  ) {
    final subjectPerformance = <String, Map<String, dynamic>>{};

    gradesByClass.forEach((classId, grades) {
      if (grades.isNotEmpty) {
        final className = grades.first.className ?? 'Unknown Class';
        final average = GradeCalculator.calculateAverage(grades);
        final quizAverage = grades.where((g) => g.isQuizGrade).isNotEmpty
            ? GradeCalculator.calculateAverage(
                grades.where((g) => g.isQuizGrade).toList(),
              )
            : 0.0;
        final assignmentAverage =
            grades.where((g) => g.isAssignmentGrade).isNotEmpty
            ? GradeCalculator.calculateAverage(
                grades.where((g) => g.isAssignmentGrade).toList(),
              )
            : 0.0;

        subjectPerformance[classId] = {
          'className': className,
          'average': average,
          'quizAverage': quizAverage,
          'assignmentAverage': assignmentAverage,
          'totalItems': grades.length,
          'quizCount': grades.where((g) => g.isQuizGrade).length,
          'assignmentCount': grades.where((g) => g.isAssignmentGrade).length,
        };
      }
    });

    return subjectPerformance;
  }

  /// Calculate improvement rate
  double calculateImprovementRate(List<GradeModel> grades) {
    if (grades.length < 2) return 0.0;

    // Sort by date
    final sortedGrades = List<GradeModel>.from(grades)
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    // Take first and last 3 grades for comparison
    final firstGrades = sortedGrades.take(3).toList();
    final lastGrades = sortedGrades.reversed.take(3).toList();

    final firstAverage = GradeCalculator.calculateAverage(firstGrades);
    final lastAverage = GradeCalculator.calculateAverage(lastGrades);

    if (firstAverage == 0) return 0.0;

    return ((lastAverage - firstAverage) / firstAverage) * 100;
  }

  /// Get performance insights
  Map<String, dynamic> getPerformanceInsights(List<GradeModel> grades) {
    if (grades.isEmpty) {
      return {
        'totalGrades': 0,
        'averageScore': 0.0,
        'improvementRate': 0.0,
        'strongestSubject': null,
        'weakestSubject': null,
        'recommendation': 'Belum ada data nilai untuk dianalisis.',
      };
    }

    final average = GradeCalculator.calculateAverage(grades);
    final improvementRate = calculateImprovementRate(grades);

    // Group by class to find strongest/weakest
    final gradesByClass = <String, List<GradeModel>>{};
    for (final grade in grades) {
      gradesByClass[grade.classId] ??= [];
      gradesByClass[grade.classId]!.add(grade);
    }

    String? strongestSubject;
    String? weakestSubject;
    double highestAverage = 0.0;
    double lowestAverage = 100.0;

    gradesByClass.forEach((classId, classGrades) {
      final classAverage = GradeCalculator.calculateAverage(classGrades);
      final className = classGrades.first.className ?? 'Unknown';

      if (classAverage > highestAverage) {
        highestAverage = classAverage;
        strongestSubject = className;
      }

      if (classAverage < lowestAverage) {
        lowestAverage = classAverage;
        weakestSubject = className;
      }
    });

    // Generate recommendation
    String recommendation;
    if (average >= 90) {
      recommendation = 'Performa sangat baik! Pertahankan konsistensi belajar.';
    } else if (average >= 80) {
      recommendation =
          'Performa baik. Fokus pada mata pelajaran yang masih lemah.';
    } else if (average >= 70) {
      recommendation =
          'Performa cukup. Tingkatkan waktu belajar dan minta bantuan guru.';
    } else {
      recommendation =
          'Performa perlu ditingkatkan. Konsultasi dengan guru dan buat jadwal belajar.';
    }

    if (improvementRate > 10) {
      recommendation += ' Tren peningkatan sangat positif!';
    } else if (improvementRate < -10) {
      recommendation +=
          ' Perhatikan penurunan performa dan evaluasi metode belajar.';
    }

    return {
      'totalGrades': grades.length,
      'averageScore': average,
      'improvementRate': improvementRate,
      'strongestSubject': strongestSubject,
      'weakestSubject': weakestSubject,
      'recommendation': recommendation,
      'gradeDistribution': calculateGradeDistribution(grades),
      'performanceTrends': calculatePerformanceTrends(grades),
    };
  }

  /// Calculate weekly performance
  List<Map<String, dynamic>> calculateWeeklyPerformance(
    List<GradeModel> grades,
  ) {
    if (grades.isEmpty) return [];

    final Map<String, List<GradeModel>> gradesByWeek = {};

    for (final grade in grades) {
      // Calculate week number
      final date = grade.recordedAt;
      final startOfYear = DateTime(date.year, 1, 1);
      final daysSinceStart = date.difference(startOfYear).inDays;
      final weekNumber = (daysSinceStart / 7).floor() + 1;
      final weekKey = '${date.year}-W$weekNumber';

      gradesByWeek[weekKey] ??= [];
      gradesByWeek[weekKey]!.add(grade);
    }

    final weeklyPerformance = <Map<String, dynamic>>[];
    final sortedWeeks = gradesByWeek.keys.toList()..sort();

    for (final week in sortedWeeks) {
      final weekGrades = gradesByWeek[week]!;
      final average = GradeCalculator.calculateAverage(weekGrades);

      weeklyPerformance.add({
        'week': week,
        'average': average,
        'count': weekGrades.length,
        'grades': weekGrades,
      });
    }

    return weeklyPerformance;
  }
}
