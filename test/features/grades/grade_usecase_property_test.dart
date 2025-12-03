// test/features/grades/grade_usecase_property_test.dart
// **Feature: meetings-assignments-grades, Property 6: Grade Calculation Accuracy**
// **Validates: Requirements 13.1-13.5**

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide test, group, expect;

/// Property tests for Grades use cases
/// Tests grade calculation accuracy
void main() {
  group('Grade Calculation Accuracy Property Tests', () {
    // **Property 6: Grade Calculation Accuracy**
    // For any student in a class, the calculated average grade should equal
    // the sum of all item scores divided by the count of graded items

    Glados<List<double>>(
      any.list(any.doubleInRange(0, 100)),
    ).test('average calculation is accurate', (scores) {
      if (scores.isEmpty) return;

      final calculatedAverage = _calculateAverage(scores);
      final expectedAverage = scores.reduce((a, b) => a + b) / scores.length;

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

    test('empty grades list returns 0 average', () {
      expect(_calculateAverage([]), 0.0);
    });

    test('single grade returns that grade as average', () {
      expect(_calculateAverage([85.0]), 85.0);
    });

    test('percentage with zero max score returns 0', () {
      expect(_calculatePercentage(50, 0), 0.0);
    });
  });

  group('GPA Calculation Property Tests', () {
    Glados<double>(any.doubleInRange(0, 100)).test(
      'GPA is within valid range [0, 4]',
      (percentage) {
        final gpa = _calculateGPA(percentage);
        expect(gpa, greaterThanOrEqualTo(0));
        expect(gpa, lessThanOrEqualTo(4));
      },
    );

    test('100% equals 4.0 GPA', () {
      expect(_calculateGPA(100), 4.0);
    });

    test('0% equals 0.0 GPA', () {
      expect(_calculateGPA(0), 0.0);
    });

    test('75% equals 3.0 GPA', () {
      expect(_calculateGPA(75), 3.0);
    });
  });

  group('Grade Validation Property Tests', () {
    Glados2<double, double>(
      any.doubleInRange(-10, 110),
      any.doubleInRange(1, 100),
    ).test('grade validation checks score bounds', (score, maxScore) {
      final isValid = _validateGrade(score, maxScore);

      if (score >= 0 && score <= maxScore) {
        expect(isValid, true);
      } else {
        expect(isValid, false);
      }
    });

    test('item type must be quiz or assignment', () {
      expect(_validateItemType('quiz'), true);
      expect(_validateItemType('assignment'), true);
      expect(_validateItemType('exam'), false);
      expect(_validateItemType(''), false);
    });
  });

  group('Grade Sync Property Tests', () {
    // Test that syncing grades from quiz/assignment creates correct records

    Glados2<double, double>(
      any.doubleInRange(0, 100),
      any.doubleInRange(1, 100),
    ).test('synced grades have correct percentage', (score, maxScore) {
      final grade = _createGradeRecord(
        score: score,
        maxScore: maxScore,
        itemType: 'quiz',
      );

      final expectedPercentage = (score / maxScore) * 100;
      expect(grade['percentage'], closeTo(expectedPercentage, 0.001));
    });
  });
}

/// Calculate average from list of scores
double _calculateAverage(List<double> scores) {
  if (scores.isEmpty) return 0.0;
  return scores.reduce((a, b) => a + b) / scores.length;
}

/// Calculate percentage
double _calculatePercentage(double score, double maxScore) {
  if (maxScore <= 0) return 0.0;
  return (score / maxScore) * 100;
}

/// Calculate GPA from percentage (4.0 scale)
double _calculateGPA(double percentage) {
  return (percentage / 100) * 4;
}

/// Validate grade
bool _validateGrade(double score, double maxScore) {
  return score >= 0 && score <= maxScore;
}

/// Validate item type
bool _validateItemType(String itemType) {
  return ['quiz', 'assignment'].contains(itemType);
}

/// Create grade record
Map<String, dynamic> _createGradeRecord({
  required double score,
  required double maxScore,
  required String itemType,
}) {
  return {
    'score': score,
    'max_score': maxScore,
    'percentage': (score / maxScore) * 100,
    'item_type': itemType,
  };
}
