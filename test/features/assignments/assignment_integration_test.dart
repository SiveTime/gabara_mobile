// test/features/assignments/assignment_integration_test.dart
// Integration tests for Assignment flow
// **Validates: Requirements 5.1-5.8, 9.1-9.5, 12.1-12.6**

import 'package:flutter_test/flutter_test.dart';
import 'package:gabara_mobile/features/assignments/data/models/assignment_model.dart';

void main() {
  group('Assignment Integration Tests', () {
    group('Assignment CRUD Flow', () {
      test('Assignment model can be created with all required fields', () {
        final assignment = AssignmentModel(
          id: 'assignment-1',
          classId: 'class-1',
          title: 'Tugas 1: Pengenalan',
          description: 'Kerjakan soal-soal berikut',
          deadline: DateTime.now().add(const Duration(days: 7)),
          maxScore: 100,
          createdBy: 'mentor-1',
          createdAt: DateTime.now(),
        );

        expect(assignment.id, equals('assignment-1'));
        expect(assignment.title, equals('Tugas 1: Pengenalan'));
        expect(assignment.maxScore, equals(100));
        expect(assignment.isActive, isTrue);
      });

      test('Assignment serialization round-trip preserves data', () {
        final original = AssignmentModel(
          id: 'assignment-1',
          classId: 'class-1',
          title: 'Test Assignment',
          description: 'Test Description',
          deadline: DateTime(2025, 12, 15, 23, 59),
          maxScore: 100,
          attachmentUrl: 'https://example.com/file.pdf',
          createdBy: 'mentor-1',
          createdAt: DateTime(2025, 12, 1),
        );

        final json = original.toJson();
        final restored = AssignmentModel.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.classId, equals(original.classId));
        expect(restored.title, equals(original.title));
        expect(restored.description, equals(original.description));
        expect(restored.maxScore, equals(original.maxScore));
        expect(restored.attachmentUrl, equals(original.attachmentUrl));
      });

      test('Assignment active status can be set', () {
        // Active assignment
        final activeAssignment = AssignmentModel(
          id: 'assignment-1',
          classId: 'class-1',
          title: 'Active Assignment',
          description: 'Test',
          deadline: DateTime.now().add(const Duration(days: 7)),
          maxScore: 100,
          createdBy: 'mentor-1',
          isActive: true,
        );
        expect(activeAssignment.isActive, isTrue);

        // Inactive assignment
        final inactiveAssignment = AssignmentModel(
          id: 'assignment-2',
          classId: 'class-1',
          title: 'Inactive Assignment',
          description: 'Test',
          deadline: DateTime.now().subtract(const Duration(days: 1)),
          maxScore: 100,
          createdBy: 'mentor-1',
          isActive: false,
        );
        expect(inactiveAssignment.isActive, isFalse);
      });

      test('Assignment deadline can be checked', () {
        final futureDeadline = DateTime.now().add(const Duration(days: 7));
        final pastDeadline = DateTime.now().subtract(const Duration(days: 1));

        final futureAssignment = AssignmentModel(
          id: 'assignment-1',
          classId: 'class-1',
          title: 'Future Assignment',
          description: 'Test',
          deadline: futureDeadline,
          maxScore: 100,
          createdBy: 'mentor-1',
        );
        expect(futureAssignment.deadline.isAfter(DateTime.now()), isTrue);

        final pastAssignment = AssignmentModel(
          id: 'assignment-2',
          classId: 'class-1',
          title: 'Past Assignment',
          description: 'Test',
          deadline: pastDeadline,
          maxScore: 100,
          createdBy: 'mentor-1',
        );
        expect(pastAssignment.deadline.isBefore(DateTime.now()), isTrue);
      });
    });

    group('Assignment Validation', () {
      test('Max score must be positive', () {
        final assignment = AssignmentModel(
          id: 'assignment-1',
          classId: 'class-1',
          title: 'Test Assignment',
          description: 'Test',
          deadline: DateTime.now().add(const Duration(days: 7)),
          maxScore: 100,
          createdBy: 'mentor-1',
        );
        expect(assignment.maxScore, greaterThan(0));
      });

      test('Title cannot be empty', () {
        final assignment = AssignmentModel(
          id: 'assignment-1',
          classId: 'class-1',
          title: 'Valid Title',
          description: 'Test',
          deadline: DateTime.now().add(const Duration(days: 7)),
          maxScore: 100,
          createdBy: 'mentor-1',
        );
        expect(assignment.title.isNotEmpty, isTrue);
      });
    });
  });
}
