// test/features/discussions/data/models/reply_model_test.dart
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:gabara_mobile/features/discussions/data/models/reply_model.dart';

void main() {
  group('ReplyModel.fromJson', () {
    test('parses complete JSON correctly', () {
      final json = {
        'id': 'reply-123',
        'discussion_id': 'disc-456',
        'parent_reply_id': 'reply-000',
        'content': '@John Doe This is a reply',
        'is_edited': true,
        'created_by': 'user-789',
        'profiles': {'full_name': 'Jane Smith'},
        'mentioned_user_name': 'John Doe',
        'created_at': '2025-01-15T10:30:00Z',
        'updated_at': '2025-01-15T11:00:00Z',
      };

      final model = ReplyModel.fromJson(json);

      expect(model.id, equals('reply-123'));
      expect(model.discussionId, equals('disc-456'));
      expect(model.parentReplyId, equals('reply-000'));
      expect(model.content, equals('@John Doe This is a reply'));
      expect(model.isEdited, isTrue);
      expect(model.createdBy, equals('user-789'));
      expect(model.authorName, equals('Jane Smith'));
      expect(model.authorInitials, equals('JS'));
      expect(model.mentionedUserName, equals('John Doe'));
    });

    test('handles top-level reply (no parent)', () {
      final json = {
        'id': 'reply-123',
        'discussion_id': 'disc-456',
        'parent_reply_id': null,
        'content': 'This is a top-level reply',
        'created_by': 'user-789',
        'created_at': '2025-01-15T10:30:00Z',
        'updated_at': '2025-01-15T10:30:00Z',
      };

      final model = ReplyModel.fromJson(json);

      expect(model.parentReplyId, isNull);
      expect(model.isNestedReply, isFalse);
    });

    test('handles nested reply', () {
      final json = {
        'id': 'reply-123',
        'discussion_id': 'disc-456',
        'parent_reply_id': 'reply-000',
        'content': '@Parent Author Reply content',
        'created_by': 'user-789',
        'created_at': '2025-01-15T10:30:00Z',
        'updated_at': '2025-01-15T10:30:00Z',
      };

      final model = ReplyModel.fromJson(json);

      expect(model.parentReplyId, equals('reply-000'));
      expect(model.isNestedReply, isTrue);
    });

    test('parses nested replies array', () {
      final json = {
        'id': 'reply-123',
        'discussion_id': 'disc-456',
        'content': 'Parent reply',
        'created_by': 'user-789',
        'created_at': '2025-01-15T10:30:00Z',
        'updated_at': '2025-01-15T10:30:00Z',
        'nested_replies': [
          {
            'id': 'reply-124',
            'discussion_id': 'disc-456',
            'parent_reply_id': 'reply-123',
            'content': '@Parent Nested reply',
            'created_by': 'user-790',
            'created_at': '2025-01-15T11:00:00Z',
            'updated_at': '2025-01-15T11:00:00Z',
          },
        ],
      };

      final model = ReplyModel.fromJson(json);

      expect(model.nestedReplies.length, equals(1));
      expect(model.nestedReplies[0].id, equals('reply-124'));
      expect(model.nestedReplies[0].parentReplyId, equals('reply-123'));
    });

    test('handles missing optional fields with defaults', () {
      final json = {
        'id': 'reply-123',
        'discussion_id': 'disc-456',
        'content': 'Test reply',
        'created_by': 'user-789',
        'created_at': '2025-01-15T10:30:00Z',
        'updated_at': '2025-01-15T10:30:00Z',
      };

      final model = ReplyModel.fromJson(json);

      expect(model.parentReplyId, isNull);
      expect(model.isEdited, isFalse);
      expect(model.authorName, isNull);
      expect(model.mentionedUserName, isNull);
      expect(model.nestedReplies, isEmpty);
    });
  });

  group('ReplyModel.toJson', () {
    test('serializes to correct JSON format', () {
      final model = ReplyModel(
        id: 'reply-123',
        discussionId: 'disc-456',
        parentReplyId: 'reply-000',
        content: '@John Doe This is a reply',
        isEdited: true,
        createdBy: 'user-789',
        authorName: 'Jane Smith',
        mentionedUserName: 'John Doe',
        createdAt: DateTime(2025, 1, 15, 10, 30),
        updatedAt: DateTime(2025, 1, 15, 11, 0),
      );

      final json = model.toJson();

      expect(json['discussion_id'], equals('disc-456'));
      expect(json['parent_reply_id'], equals('reply-000'));
      expect(json['content'], equals('@John Doe This is a reply'));
      expect(json['is_edited'], isTrue);
      expect(json['created_by'], equals('user-789'));
      // toJson should not include computed fields
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('author_name'), isFalse);
    });
  });

  group('ReplyModel round-trip serialization', () {
    /// **Feature: forum-discussion-feature, Property 5: Reply Mention Consistency**
    /// *For any* valid ReplyModel, serializing to JSON and deserializing
    /// should preserve the essential data fields including @mention.
    /// **Validates: Requirements 7.1-7.5**
    test(
      'Property 5: Round-trip preserves essential fields (100 iterations)',
      () {
        final random = Random(42);

        for (var i = 0; i < 100; i++) {
          final original = _generateRandomReply(random, i);

          // Simulate what Supabase would return
          final json = {
            'id': original.id,
            'discussion_id': original.discussionId,
            'parent_reply_id': original.parentReplyId,
            'content': original.content,
            'is_edited': original.isEdited,
            'created_by': original.createdBy,
            'profiles': {'full_name': original.authorName},
            'mentioned_user_name': original.mentionedUserName,
            'created_at': original.createdAt.toIso8601String(),
            'updated_at': original.updatedAt.toIso8601String(),
          };

          final restored = ReplyModel.fromJson(json);

          expect(
            restored.id,
            equals(original.id),
            reason: 'id mismatch at iteration $i',
          );
          expect(
            restored.discussionId,
            equals(original.discussionId),
            reason: 'discussionId mismatch at iteration $i',
          );
          expect(
            restored.parentReplyId,
            equals(original.parentReplyId),
            reason: 'parentReplyId mismatch at iteration $i',
          );
          expect(
            restored.content,
            equals(original.content),
            reason: 'content mismatch at iteration $i',
          );
          expect(
            restored.isEdited,
            equals(original.isEdited),
            reason: 'isEdited mismatch at iteration $i',
          );
          expect(
            restored.createdBy,
            equals(original.createdBy),
            reason: 'createdBy mismatch at iteration $i',
          );
          expect(
            restored.authorName,
            equals(original.authorName),
            reason: 'authorName mismatch at iteration $i',
          );
          expect(
            restored.mentionedUserName,
            equals(original.mentionedUserName),
            reason: 'mentionedUserName mismatch at iteration $i',
          );
        }
      },
    );
  });

  group('ReplyModel.copyWith', () {
    test('creates copy with updated fields', () {
      final original = ReplyModel(
        id: 'reply-123',
        discussionId: 'disc-456',
        content: 'Original content',
        createdBy: 'user-789',
        createdAt: DateTime(2025, 1, 15),
        updatedAt: DateTime(2025, 1, 15),
      );

      final updated = original.copyWith(
        content: 'Updated content',
        isEdited: true,
        mentionedUserName: 'John Doe',
      );

      expect(updated.id, equals(original.id));
      expect(updated.discussionId, equals(original.discussionId));
      expect(updated.content, equals('Updated content'));
      expect(updated.isEdited, isTrue);
      expect(updated.mentionedUserName, equals('John Doe'));
    });
  });

  group('ReplyEntity properties', () {
    test('isNestedReply returns correct value', () {
      final topLevel = ReplyModel(
        id: '1',
        discussionId: '1',
        parentReplyId: null,
        content: 'Top level',
        createdBy: '1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(topLevel.isNestedReply, isFalse);

      final nested = topLevel.copyWith(parentReplyId: 'parent-1');
      expect(nested.isNestedReply, isTrue);
    });

    test('displayContent adds @mention when needed', () {
      // Reply with mention already in content
      final withMention = ReplyModel(
        id: '1',
        discussionId: '1',
        content: '@John Doe Hello!',
        createdBy: '1',
        mentionedUserName: 'John Doe',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(withMention.displayContent, equals('@John Doe Hello!'));

      // Reply without mention in content but has mentionedUserName
      final withoutMention = ReplyModel(
        id: '1',
        discussionId: '1',
        content: 'Hello!',
        createdBy: '1',
        mentionedUserName: 'John Doe',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(withoutMention.displayContent, equals('@John Doe Hello!'));

      // Reply without mentionedUserName
      final noMention = ReplyModel(
        id: '1',
        discussionId: '1',
        content: 'Hello!',
        createdBy: '1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(noMention.displayContent, equals('Hello!'));
    });
  });
}

ReplyModel _generateRandomReply(Random random, int seed) {
  final names = ['John Doe', 'Jane Smith', 'Bob Wilson', 'Alice Brown'];
  final hasParent = random.nextBool();
  final authorName = names[random.nextInt(names.length)];
  final mentionedName = hasParent ? names[random.nextInt(names.length)] : null;

  String content = 'This is reply content $seed';
  if (mentionedName != null) {
    content = '@$mentionedName $content';
  }

  return ReplyModel(
    id: 'reply-$seed',
    discussionId: 'disc-${random.nextInt(100)}',
    parentReplyId: hasParent ? 'reply-${random.nextInt(seed + 1)}' : null,
    content: content,
    isEdited: random.nextBool(),
    createdBy: 'user-${random.nextInt(100)}',
    authorName: authorName,
    mentionedUserName: mentionedName,
    createdAt: DateTime(2025, 1 + random.nextInt(12), 1 + random.nextInt(28)),
    updatedAt: DateTime(2025, 1 + random.nextInt(12), 1 + random.nextInt(28)),
  );
}
