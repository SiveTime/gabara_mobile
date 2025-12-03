// test/features/grades/grade_model_test.dart
// **Feature: meetings-assignments-grades, Property 6: Grade Calculation Accuracy**
// **Validates: Requirements 13.1-13.5**

import 'package:glados/glados.dart';
import 'package:gabara_mobile/features/grades/data/models/grade_model.dart';
import 'package:gabara_mobile/features/grades/domain/entities/grade_entity.dart';

void main() {
  group('GradeModel Serialization', () {
    Glados(any.gradeModel).test(
      'Grade round-trip serialization preserves all fields',
      (grade) {
        // Serialize to JSON
        final json = grade.toJson();

        // Deserialize from JSON
        final restored = GradeModel.fromJson(json);

        // Verify all fields are preserved
        expect(restored.id, equals(grade.id));
        expect(restored.studentId, equals(grade.studentId));
        expect(restored.classId, equals(grade.classId));
        expect(restored.itemId, equals(grade.itemId));
        expect(restored.itemType, equals(grade.itemType));
        expect(restored.score, equals(grade.score));
        expect(restored.maxScore, equals(grade.maxScore));
        expect(restored.percentage, equals(grade.percentage));
      },
    );

    Glados(any.gradeModel).test(
      'toCreateJson excludes id field',
      (grade) {
        final json = grade.toCreateJson();
        expect(json.containsKey('id'), isFalse);
        expect(json['student_id'], equals(grade.studentId));
        expect(json['item_id'], equals(grade.itemId));
      },
    );
  });

  group('GradeEntity Properties', () {
    test('isQuizGrade returns true for quiz grades', () {
      final grade = GradeModel(
        id: '1',
        studentId: 's1',
        classId: 'c1',
        itemId: 'q1',
        itemType: 'quiz',
        score: 85,
        maxScore: 100,
        percentage: 85,
        recordedAt: DateTime.now(),
      );
      expect(grade.isQuizGrade, isTrue);
      expect(grade.isAssignmentGrade, isFalse);
    });

    test('isAssignmentGrade returns true for assignment grades', () {
      final grade = GradeModel(
        id: '1',
        studentId: 's1',
        classId: 'c1',
        itemId: 'a1',
        itemType: 'assignment',
        score: 90,
        maxScore: 100,
        percentage: 90,
        recordedAt: DateTime.now(),
      );
      expect(grade.isAssignmentGrade, isTrue);
      expect(grade.isQuizGrade, isFalse);
    });

    test('isPassing returns true for percentage >= 60', () {
      final passing = GradeModel(
        id: '1',
        studentId: 's1',
        classId: 'c1',
        itemId: 'q1',
        itemType: 'quiz',
        score: 60,
        maxScore: 100,
        percentage: 60,
        recordedAt: DateTime.now(),
      );
      expect(passing.isPassing, isTrue);

      final failing = GradeModel(
        id: '2',
        studentId: 's1',
        classId: 'c1',
        itemId: 'q2',
        itemType: 'quiz',
        score: 50,
        maxScore: 100,
        percentage: 50,
        recordedAt: DateTime.now(),
      );
      expect(failing.isPassing, isFalse);
    });

    test('letterGrade returns correct grade', () {
      expect(
        GradeModel(
          id: '1', studentId: 's1', classId: 'c1', itemId: 'q1',
          itemType: 'quiz', score: 95, maxScore: 100, percentage: 95,
          recordedAt: DateTime.now(),
        ).letterGrade,
        equals('A'),
      );
      expect(
        GradeModel(
          id: '2', studentId: 's1', classId: 'c1', itemId: 'q2',
          itemType: 'quiz', score: 85, maxScore: 100, percentage: 85,
          recordedAt: DateTime.now(),
        ).letterGrade,
        equals('B'),
      );
      expect(
        GradeModel(
          id: '3', studentId: 's1', classId: 'c1', itemId: 'q3',
          itemType: 'quiz', score: 75, maxScore: 100, percentage: 75,
          recordedAt: DateTime.now(),
        ).letterGrade,
        equals('C'),
      );
      expect(
        GradeModel(
          id: '4', studentId: 's1', classId: 'c1', itemId: 'q4',
          itemType: 'quiz', score: 65, maxScore: 100, percentage: 65,
          recordedAt: DateTime.now(),
        ).letterGrade,
        equals('D'),
      );
      expect(
        GradeModel(
          id: '5', studentId: 's1', classId: 'c1', itemId: 'q5',
          itemType: 'quiz', score: 50, maxScore: 100, percentage: 50,
          recordedAt: DateTime.now(),
        ).letterGrade,
        equals('E'),
      );
    });
  });

  group('Property 6: Grade Calculation Accuracy', () {
    // For any student in a class, the calculated average grade should equal
    // the sum of all item scores divided by the count of graded items.

    Glados(any.gradeList).test(
      'calculateAverage returns correct average percentage',
      (grades) {
        if (grades.isEmpty) {
          expect(GradeCalculator.calculateAverage(grades), equals(0));
          return;
        }

        // Calculate expected average
        final totalPercentage = grades.fold<double>(
          0,
          (sum, grade) => sum + grade.percentage,
        );
        final expectedAverage = totalPercentage / grades.length;

        // Verify calculation
        final calculatedAverage = GradeCalculator.calculateAverage(grades);
        expect(calculatedAverage, closeTo(expectedAverage, 0.001));
      },
    );

    Glados(any.gradeList).test(
      'calculateWeightedAverage returns correct weighted average',
      (grades) {
        if (grades.isEmpty) {
          expect(GradeCalculator.calculateWeightedAverage(grades), equals(0));
          return;
        }

        // Calculate expected weighted average
        final totalScore = grades.fold<double>(0, (sum, g) => sum + g.score);
        final totalMaxScore = grades.fold<double>(0, (sum, g) => sum + g.maxScore);
        final expectedAverage = totalMaxScore > 0
            ? (totalScore / totalMaxScore) * 100
            : 0.0;

        // Verify calculation
        final calculatedAverage = GradeCalculator.calculateWeightedAverage(grades);
        expect(calculatedAverage, closeTo(expectedAverage, 0.001));
      },
    );

    test('calculatePercentage returns correct percentage', () {
      expect(GradeCalculator.calculatePercentage(85, 100), equals(85.0));
      expect(GradeCalculator.calculatePercentage(45, 50), equals(90.0));
      expect(GradeCalculator.calculatePercentage(0, 100), equals(0.0));
      expect(GradeCalculator.calculatePercentage(100, 0), equals(0.0));
    });

    test('getGPA returns correct GPA', () {
      expect(GradeCalculator.getGPA(95), equals(4.0));
      expect(GradeCalculator.getGPA(85), equals(3.0));
      expect(GradeCalculator.getGPA(75), equals(2.0));
      expect(GradeCalculator.getGPA(65), equals(1.0));
      expect(GradeCalculator.getGPA(50), equals(0.0));
    });
  });

  group('GradeModel Factory Methods', () {
    test('fromQuizAttempt creates correct grade', () {
      final grade = GradeModel.fromQuizAttempt(
        studentId: 's1',
        classId: 'c1',
        quizId: 'q1',
        score: 85,
        maxScore: 100,
        quizTitle: 'Quiz 1',
      );

      expect(grade.studentId, equals('s1'));
      expect(grade.classId, equals('c1'));
      expect(grade.itemId, equals('q1'));
      expect(grade.itemType, equals('quiz'));
      expect(grade.score, equals(85));
      expect(grade.maxScore, equals(100));
      expect(grade.percentage, equals(85));
      expect(grade.itemTitle, equals('Quiz 1'));
    });

    test('fromSubmission creates correct grade', () {
      final grade = GradeModel.fromSubmission(
        studentId: 's1',
        classId: 'c1',
        assignmentId: 'a1',
        score: 90,
        maxScore: 100,
        assignmentTitle: 'Assignment 1',
      );

      expect(grade.studentId, equals('s1'));
      expect(grade.classId, equals('c1'));
      expect(grade.itemId, equals('a1'));
      expect(grade.itemType, equals('assignment'));
      expect(grade.score, equals(90));
      expect(grade.maxScore, equals(100));
      expect(grade.percentage, equals(90));
      expect(grade.itemTitle, equals('Assignment 1'));
    });
  });

  group('GradeItemType Validation', () {
    test('valid grade item types', () {
      expect(GradeItemType.isValid('quiz'), isTrue);
      expect(GradeItemType.isValid('assignment'), isTrue);
      expect(GradeItemType.isValid('exam'), isFalse);
      expect(GradeItemType.isValid(''), isFalse);
    });
  });
}

// Custom generators for Glados
extension GradeGenerators on Any {
  Generator<GradeModel> get gradeModel => any.positiveInt.map((i) {
        final id = 'uuid-$i';
        final score = (i % 101).toDouble();
        final maxScore = 100.0;
        final percentage = (score / maxScore) * 100;
        final itemType = i % 2 == 0 ? 'quiz' : 'assignment';
        return GradeModel(
          id: id,
          studentId: 'student-$id',
          classId: 'class-$id',
          itemId: 'item-$id',
          itemType: itemType,
          score: score,
          maxScore: maxScore,
          percentage: percentage,
          recordedAt: DateTime.now(),
        );
      });

  Generator<List<GradeModel>> get gradeList =>
      any.gradeModel.map((g) => [g]);

  Generator<double> get scoreValue =>
      any.int.map((i) => (i.abs() % 101).toDouble());

  Generator<String> get gradeItemType => any.choose(['quiz', 'assignment']);
}
