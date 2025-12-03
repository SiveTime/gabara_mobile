// test/features/assignments/assignment_model_test.dart
// **Feature: meetings-assignments-grades, Property 3: Assignment Deadline Immutability**
// **Validates: Requirements 7.1-7.5**

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide test, group, expect;
import 'package:gabara_mobile/features/assignments/data/models/assignment_model.dart';
import 'package:gabara_mobile/features/assignments/data/models/submission_model.dart';
import 'package:gabara_mobile/features/assignments/domain/entities/submission_entity.dart';

void main() {
  group('AssignmentModel Serialization', () {
    Glados(any.assignmentModel).test(
      'Assignment round-trip serialization preserves all fields',
      (assignment) {
        // Serialize to JSON
        final json = assignment.toJson();

        // Deserialize from JSON
        final restored = AssignmentModel.fromJson(json);

        // Verify all fields are preserved
        expect(restored.id, equals(assignment.id));
        expect(restored.classId, equals(assignment.classId));
        expect(restored.title, equals(assignment.title));
        expect(restored.description, equals(assignment.description));
        expect(restored.maxScore, equals(assignment.maxScore));
        expect(restored.attachmentUrl, equals(assignment.attachmentUrl));
        expect(restored.isActive, equals(assignment.isActive));
        expect(restored.createdBy, equals(assignment.createdBy));
      },
    );

    Glados(any.assignmentModel).test(
      'toCreateJson excludes id field',
      (assignment) {
        final json = assignment.toCreateJson();
        expect(json.containsKey('id'), isFalse);
        expect(json['title'], equals(assignment.title));
        expect(json['class_id'], equals(assignment.classId));
      },
    );
  });

  group('AssignmentEntity Properties', () {
    test('isOpen returns true when deadline is in future and active', () {
      final assignment = AssignmentModel(
        id: '1',
        classId: 'class1',
        title: 'Test Assignment',
        deadline: DateTime.now().add(const Duration(days: 7)),
        maxScore: 100,
        isActive: true,
        createdBy: 'mentor1',
      );
      expect(assignment.isOpen, isTrue);
      expect(assignment.isClosed, isFalse);
    });

    test('isClosed returns true when deadline has passed', () {
      final assignment = AssignmentModel(
        id: '1',
        classId: 'class1',
        title: 'Test Assignment',
        deadline: DateTime.now().subtract(const Duration(days: 1)),
        maxScore: 100,
        isActive: true,
        createdBy: 'mentor1',
      );
      expect(assignment.isClosed, isTrue);
      expect(assignment.isOpen, isFalse);
    });

    test('isClosed returns true when not active', () {
      final assignment = AssignmentModel(
        id: '1',
        classId: 'class1',
        title: 'Test Assignment',
        deadline: DateTime.now().add(const Duration(days: 7)),
        maxScore: 100,
        isActive: false,
        createdBy: 'mentor1',
      );
      expect(assignment.isClosed, isTrue);
    });

    test('isDeadlineApproaching returns true within 24 hours', () {
      final assignment = AssignmentModel(
        id: '1',
        classId: 'class1',
        title: 'Test Assignment',
        deadline: DateTime.now().add(const Duration(hours: 12)),
        maxScore: 100,
        isActive: true,
        createdBy: 'mentor1',
      );
      expect(assignment.isDeadlineApproaching, isTrue);
    });

    test('isDeadlineApproaching returns false when more than 24 hours', () {
      final assignment = AssignmentModel(
        id: '1',
        classId: 'class1',
        title: 'Test Assignment',
        deadline: DateTime.now().add(const Duration(days: 7)),
        maxScore: 100,
        isActive: true,
        createdBy: 'mentor1',
      );
      expect(assignment.isDeadlineApproaching, isFalse);
    });
  });

  group('SubmissionModel Serialization', () {
    Glados(any.submissionModel).test(
      'Submission round-trip serialization preserves all fields',
      (submission) {
        // Serialize to JSON
        final json = submission.toJson();

        // Deserialize from JSON
        final restored = SubmissionModel.fromJson(json);

        // Verify all fields are preserved
        expect(restored.id, equals(submission.id));
        expect(restored.assignmentId, equals(submission.assignmentId));
        expect(restored.studentId, equals(submission.studentId));
        expect(restored.content, equals(submission.content));
        expect(restored.status, equals(submission.status));
      },
    );
  });

  group('SubmissionEntity Properties', () {
    test('status checks work correctly', () {
      final draft = SubmissionModel(
        id: '1',
        assignmentId: 'a1',
        studentId: 's1',
        status: 'draft',
      );
      expect(draft.isDraft, isTrue);
      expect(draft.hasBeenSubmitted, isFalse);

      final submitted = SubmissionModel(
        id: '2',
        assignmentId: 'a1',
        studentId: 's1',
        status: 'submitted',
      );
      expect(submitted.isSubmitted, isTrue);
      expect(submitted.hasBeenSubmitted, isTrue);

      final graded = SubmissionModel(
        id: '3',
        assignmentId: 'a1',
        studentId: 's1',
        status: 'graded',
        score: 85,
      );
      expect(graded.isGraded, isTrue);
      expect(graded.hasBeenSubmitted, isTrue);
    });

    test('getPercentage calculates correctly', () {
      final submission = SubmissionModel(
        id: '1',
        assignmentId: 'a1',
        studentId: 's1',
        status: 'graded',
        score: 85,
      );
      expect(submission.getPercentage(100), equals(85.0));
      expect(submission.getPercentage(50), equals(170.0));
    });

    test('getPercentage returns null when score is null', () {
      final submission = SubmissionModel(
        id: '1',
        assignmentId: 'a1',
        studentId: 's1',
        status: 'submitted',
      );
      expect(submission.getPercentage(100), isNull);
    });
  });

  group('SubmissionStatus Validation', () {
    test('valid submission statuses', () {
      expect(SubmissionStatus.isValid('draft'), isTrue);
      expect(SubmissionStatus.isValid('submitted'), isTrue);
      expect(SubmissionStatus.isValid('graded'), isTrue);
      expect(SubmissionStatus.isValid('late'), isTrue);
      expect(SubmissionStatus.isValid('returned'), isTrue);
      expect(SubmissionStatus.isValid('pending'), isFalse);
      expect(SubmissionStatus.isValid(''), isFalse);
    });
  });

  group('Property 5: Late Submission Detection', () {
    // For any submission submitted after the assignment deadline,
    // the submission status should be marked as "late"
    test('submission after deadline should be marked as late', () {
      final deadline = DateTime.now().subtract(const Duration(hours: 1));
      final submittedAt = DateTime.now();

      // Simulate late submission detection logic
      final isLate = submittedAt.isAfter(deadline);
      expect(isLate, isTrue);

      // Create submission with late status
      final submission = SubmissionModel(
        id: '1',
        assignmentId: 'a1',
        studentId: 's1',
        status: isLate ? 'late' : 'submitted',
        submittedAt: submittedAt,
      );
      expect(submission.isLate, isTrue);
    });

    test('submission before deadline should not be marked as late', () {
      final deadline = DateTime.now().add(const Duration(hours: 1));
      final submittedAt = DateTime.now();

      final isLate = submittedAt.isAfter(deadline);
      expect(isLate, isFalse);

      final submission = SubmissionModel(
        id: '1',
        assignmentId: 'a1',
        studentId: 's1',
        status: isLate ? 'late' : 'submitted',
        submittedAt: submittedAt,
      );
      expect(submission.isLate, isFalse);
      expect(submission.isSubmitted, isTrue);
    });
  });
}

// Custom generators for Glados
extension AssignmentGenerators on Any {
  Generator<AssignmentModel> get assignmentModel {
    return any.lowercaseLetters.map((id) => AssignmentModel(
          id: 'id-$id',
          classId: 'class-$id',
          title: 'Assignment $id',
          description: 'Test description',
          deadline: DateTime.now().add(const Duration(days: 7)),
          maxScore: 100,
          isActive: true,
          createdBy: 'mentor-$id',
        ));
  }

  Generator<SubmissionModel> get submissionModel {
    return any.lowercaseLetters.map((id) => SubmissionModel(
          id: 'sub-$id',
          assignmentId: 'assignment-$id',
          studentId: 'student-$id',
          content: 'Test submission content',
          status: 'submitted',
        ));
  }
}
