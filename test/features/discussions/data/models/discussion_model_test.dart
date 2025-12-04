// test/features/discussions/data/models/discussion_model_test.dart
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabara_mobile/features/discussions/data/models/discussion_model.dart';

void main() {
  group('DiscussionModel.fromJson', () {
    test('parses complete JSON correctly', () {
      final json = {
        'id': 'disc-123',
        'class_id': 'class-456',
        'title': 'Test Discussion',
        'content': 'This is test content',
        'is_pinned': true,
        'is_closed': false,
        'view_count': 10,
        'created_by': 'user-789',
        'profiles': {'full_name': 'John Doe'},
        'classes': {'name': 'Math Class'},
        'created_at': '2025-01-15T10:30:00Z',
        'updated_at': '2025-01-15T11:00:00Z',
        'reply_count': 5,
      };

      final model = DiscussionModel.fromJson(json);

      expect(model.id, equals('disc-123'));
      expect(model.classId, equals('class-456'));
      expect(model.title, equals('Test Discussion'));
      expect(model.content, equals('This is test content'));
      expect(model.isPinned, isTrue);
      expect(model.isClosed, isFalse);
      expect(model.viewCount, equals(10));
      expect(model.createdBy, equals('user-789'));
      expect(model.creatorName, equals('John Doe'));
      expect(model.creatorInitials, equals('JD'));
      expect(model.className, equals('Math Class'));
      expect(model.replyCount, equals(5));
    });

    test('handles missing optional fields with defaults', () {
      final json = {
        'id': 'disc-123',
        'class_id': 'class-456',
        'title': 'Test',
        'content': 'Content',
        'created_by': 'user-789',
        'created_at': '2025-01-15T10:30:00Z',
        'updated_at': '2025-01-15T10:30:00Z',
      };

      final model = DiscussionModel.fromJson(json);

      expect(model.isPinned, isFalse);
      expect(model.isClosed, isFalse);
      expect(model.viewCount, equals(0));
      expect(model.creatorName, isNull);
      expect(model.className, isNull);
      expect(model.replyCount, equals(0));
    });

    test('generates correct initials from full name', () {
      // Two-word name
      var json = _createJsonWithName('John Doe');
      expect(DiscussionModel.fromJson(json).creatorInitials, equals('JD'));

      // Three-word name (uses first two)
      json = _createJsonWithName('John Michael Doe');
      expect(DiscussionModel.fromJson(json).creatorInitials, equals('JM'));

      // Single-word name
      json = _createJsonWithName('John');
      expect(DiscussionModel.fromJson(json).creatorInitials, equals('JO'));

      // Single character name
      json = _createJsonWithName('J');
      expect(DiscussionModel.fromJson(json).creatorInitials, equals('J'));
    });
  });

  group('DiscussionModel.toJson', () {
    test('serializes to correct JSON format', () {
      final model = DiscussionModel(
        id: 'disc-123',
        classId: 'class-456',
        title: 'Test Discussion',
        content: 'Test content',
        isPinned: true,
        isClosed: false,
        viewCount: 10,
        createdBy: 'user-789',
        creatorName: 'John Doe',
        className: 'Math Class',
        createdAt: DateTime(2025, 1, 15, 10, 30),
        updatedAt: DateTime(2025, 1, 15, 11, 0),
        replyCount: 5,
      );

      final json = model.toJson();

      expect(json['class_id'], equals('class-456'));
      expect(json['title'], equals('Test Discussion'));
      expect(json['content'], equals('Test content'));
      expect(json['is_pinned'], isTrue);
      expect(json['is_closed'], isFalse);
      expect(json['created_by'], equals('user-789'));
      // toJson should not include computed fields
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('creator_name'), isFalse);
      expect(json.containsKey('reply_count'), isFalse);
    });
  });

  group('DiscussionModel round-trip serialization', () {
    /// **Feature: forum-discussion-feature, Property: Round-trip consistency**
    /// *For any* valid DiscussionModel, serializing to JSON and deserializing
    /// should preserve the essential data fields.
    /// **Validates: Requirements 1.1-1.8**
    test(
      'Property: Round-trip preserves essential fields (100 iterations)',
      () {
        final random = Random(42);

        for (var i = 0; i < 100; i++) {
          final original = _generateRandomDiscussion(random, i);

          // Simulate what Supabase would return
          final json = {
            'id': original.id,
            'class_id': original.classId,
            'title': original.title,
            'content': original.content,
            'is_pinned': original.isPinned,
            'is_closed': original.isClosed,
            'view_count': original.viewCount,
            'created_by': original.createdBy,
            'profiles': {'full_name': original.creatorName},
            'classes': {'name': original.className},
            'created_at': original.createdAt.toIso8601String(),
            'updated_at': original.updatedAt.toIso8601String(),
            'reply_count': original.replyCount,
          };

          final restored = DiscussionModel.fromJson(json);

          expect(
            restored.id,
            equals(original.id),
            reason: 'id mismatch at iteration $i',
          );
          expect(
            restored.classId,
            equals(original.classId),
            reason: 'classId mismatch at iteration $i',
          );
          expect(
            restored.title,
            equals(original.title),
            reason: 'title mismatch at iteration $i',
          );
          expect(
            restored.content,
            equals(original.content),
            reason: 'content mismatch at iteration $i',
          );
          expect(
            restored.isPinned,
            equals(original.isPinned),
            reason: 'isPinned mismatch at iteration $i',
          );
          expect(
            restored.isClosed,
            equals(original.isClosed),
            reason: 'isClosed mismatch at iteration $i',
          );
          expect(
            restored.createdBy,
            equals(original.createdBy),
            reason: 'createdBy mismatch at iteration $i',
          );
          expect(
            restored.creatorName,
            equals(original.creatorName),
            reason: 'creatorName mismatch at iteration $i',
          );
          expect(
            restored.className,
            equals(original.className),
            reason: 'className mismatch at iteration $i',
          );
          expect(
            restored.replyCount,
            equals(original.replyCount),
            reason: 'replyCount mismatch at iteration $i',
          );
        }
      },
    );
  });

  group('DiscussionModel.copyWith', () {
    test('creates copy with updated fields', () {
      final original = DiscussionModel(
        id: 'disc-123',
        classId: 'class-456',
        title: 'Original Title',
        content: 'Original content',
        createdBy: 'user-789',
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        isClosed: true,
        replyCount: 10,
      );

      expect(updated.id, equals(original.id));
      expect(updated.classId, equals(original.classId));
      expect(updated.title, equals('Updated Title'));
      expect(updated.content, equals(original.content));
      expect(updated.isClosed, isTrue);
      expect(updated.replyCount, equals(10));
    });
  });

  group('DiscussionEntity properties', () {
    test('statusText returns correct value', () {
      final openDiscussion = DiscussionModel(
        id: '1',
        classId: '1',
        title: 'Test',
        content: 'Test',
        isClosed: false,
        createdBy: '1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(openDiscussion.statusText, equals('Open'));

      final closedDiscussion = openDiscussion.copyWith(isClosed: true);
      expect(closedDiscussion.statusText, equals('Closed'));
    });

    test('isOpen returns correct value', () {
      final openDiscussion = DiscussionModel(
        id: '1',
        classId: '1',
        title: 'Test',
        content: 'Test',
        isClosed: false,
        createdBy: '1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(openDiscussion.isOpen, isTrue);

      final closedDiscussion = openDiscussion.copyWith(isClosed: true);
      expect(closedDiscussion.isOpen, isFalse);
    });
  });
}

Map<String, dynamic> _createJsonWithName(String name) {
  return {
    'id': 'disc-123',
    'class_id': 'class-456',
    'title': 'Test',
    'content': 'Content',
    'created_by': 'user-789',
    'profiles': {'full_name': name},
    'created_at': '2025-01-15T10:30:00Z',
    'updated_at': '2025-01-15T10:30:00Z',
  };
}

DiscussionModel _generateRandomDiscussion(Random random, int seed) {
  final names = [
    'John Doe',
    'Jane Smith',
    'Bob Wilson',
    'Alice Brown',
    'Charlie Davis',
  ];
  final classes = ['Math 101', 'Physics 201', 'Chemistry 301', 'Biology 401'];

  return DiscussionModel(
    id: 'disc-$seed',
    classId: 'class-${random.nextInt(100)}',
    title: 'Discussion Title $seed',
    content: 'This is the content for discussion $seed with some random text.',
    isPinned: random.nextBool(),
    isClosed: random.nextBool(),
    viewCount: random.nextInt(1000),
    createdBy: 'user-${random.nextInt(100)}',
    creatorName: names[random.nextInt(names.length)],
    className: classes[random.nextInt(classes.length)],
    createdAt: DateTime(2025, 1 + random.nextInt(12), 1 + random.nextInt(28)),
    updatedAt: DateTime(2025, 1 + random.nextInt(12), 1 + random.nextInt(28)),
    replyCount: random.nextInt(50),
  );
}
