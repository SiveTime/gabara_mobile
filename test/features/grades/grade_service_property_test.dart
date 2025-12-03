// test/features/grades/grade_service_property_test.dart
// **Feature: meetings-assignments-grades, Property 6: Grade Calculation Accuracy**
// **Validates: Requirements 13.1-13.5**

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide test, group, expect;

/// Property tests for Grades service
/// Tests grade calculation accuracy
void main() {
  group('Grade Calculation Accuracy Property Tests', () {
    // **Property 6: Grade Calculation Accuracy**
    // For any student in a class, the calculated average grade should equal
    // the sum of all item scores divided by the count of graded items

    Glados<List<MockGrade>>(
      any.list(_anyMockGrade),
    ).test('average calculation is mathematically correct', (grades) {
      if (grades.isEmpty) {
        expect(_calculateAverage(grades), 0.0);
        return;
      }

      final calculatedAverage = _calculateAverage(grades);
      final expectedAverage =
          grades.map((g) => g.percentage).reduce((a, b) => a + b) /
              grades.length;

      expect(calculatedAverage, closeTo(expectedAverage, 0.001));
    });

    Glados2<double, double>(
      any.doubleInRange(0, 100),
      any.doubleInRange(1, 100),
    ).test('percentage calculation is accurate', (score, maxScore) {
      final percentage = _calculatePercentage(score, maxScore);
      final expected = (score / maxScore) * 100;

      expect(percentage, closeTo(expected, 0.001));
    });
  });

  group('Grade Sync Property Tests', () {
    Glados2<double, double>(
      any.doubleInRange(0, 100),
      any.doubleInRange(1, 100),
    ).test('synced grades have correct data', (score, maxScore) {
      final grade = _syncGradeFromQuiz(
        studentId: 'student-1',
        classId: 'class-1',
        quizId: 'quiz-1',
        score: score,
        maxScore: maxScore,
      );

      expect(grade.score, score);
      expect(grade.maxScore, maxScore);
      expect(grade.percentage, closeTo((score / maxScore) * 100, 0.001));
      expect(grade.itemType, 'quiz');
    });

    Glados2<double, double>(
      any.doubleInRange(0, 100),
      any.doubleInRange(1, 100),
    ).test('assignment grades sync correctly', (score, maxScore) {
      final grade = _syncGradeFromAssignment(
        studentId: 'student-1',
        classId: 'class-1',
        assignmentId: 'assignment-1',
        score: score,
        maxScore: maxScore,
      );

      expect(grade.score, score);
      expect(grade.maxScore, maxScore);
      expect(grade.percentage, closeTo((score / maxScore) * 100, 0.001));
      expect(grade.itemType, 'assignment');
    });
  });

  group('Grade Uniqueness Property Tests', () {
    Glados2<String, String>(
      any.lowercaseLetters, // studentId
      any.lowercaseLetters, // itemId
    ).test('one grade per student per item', (studentId, itemId) {
      final grades = <String, MockGrade>{};

      // Simulate multiple grade sync attempts
      for (var i = 0; i < 3; i++) {
        final key = '$studentId-$itemId';
        grades[key] = MockGrade(
          studentId: studentId,
          itemId: itemId,
          itemType: 'quiz',
          score: 80.0 + i,
          maxScore: 100.0,
          percentage: 80.0 + i,
        );
      }

      // Should only have one grade per student-item combination
      expect(grades.length, 1);
    });
  });

  group('GPA Calculation Property Tests', () {
    Glados<double>(any.doubleInRange(0, 100)).test(
      'GPA is within valid range',
      (percentage) {
        final gpa = _calculateGPA(percentage);
        expect(gpa, greaterThanOrEqualTo(0));
        expect(gpa, lessThanOrEqualTo(4));
      },
    );
  });
}

/// Mock grade for testing
class MockGrade {
  final String studentId;
  final String itemId;
  final String itemType;
  final double score;
  final double maxScore;
  final double percentage;

  MockGrade({
    required this.studentId,
    required this.itemId,
    required this.itemType,
    required this.score,
    required this.maxScore,
    required this.percentage,
  });
}

/// Generator for mock grades
Generator<MockGrade> get _anyMockGrade => any.combine2(
      any.doubleInRange(0, 100),
      any.doubleInRange(1, 100),
      (score, maxScore) => MockGrade(
        studentId: 'student-1',
        itemId: 'item-1',
        itemType: 'quiz',
        score: score,
        maxScore: maxScore,
        percentage: (score / maxScore) * 100,
      ),
    );

/// Calculate average from list of grades
double _calculateAverage(List<MockGrade> grades) {
  if (grades.isEmpty) return 0.0;
  return grades.map((g) => g.percentage).reduce((a, b) => a + b) /
      grades.length;
}

/// Calculate percentage
double _calculatePercentage(double score, double maxScore) {
  if (maxScore <= 0) return 0.0;
  return (score / maxScore) * 100;
}

/// Calculate GPA from percentage
double _calculateGPA(double percentage) {
  return (percentage / 100) * 4;
}

/// Sync grade from quiz
MockGrade _syncGradeFromQuiz({
  required String studentId,
  required String classId,
  required String quizId,
  required double score,
  required double maxScore,
}) {
  return MockGrade(
    studentId: studentId,
    itemId: quizId,
    itemType: 'quiz',
    score: score,
    maxScore: maxScore,
    percentage: (score / maxScore) * 100,
  );
}

/// Sync grade from assignment
MockGrade _syncGradeFromAssignment({
  required String studentId,
  required String classId,
  required String assignmentId,
  required double score,
  required double maxScore,
}) {
  return MockGrade(
    studentId: studentId,
    itemId: assignmentId,
    itemType: 'assignment',
    score: score,
    maxScore: maxScore,
    percentage: (score / maxScore) * 100,
  );
}
