// test/features/discussions/domain/validators/reply_validator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gabara_mobile/features/discussions/domain/validators/reply_validator.dart';

void main() {
  group('ReplyValidator.validateContent', () {
    test('returns valid for non-empty content', () {
      final result = ReplyValidator.validateContent('Test reply');
      expect(result.isValid, isTrue);
    });

    test('returns invalid for null content', () {
      final result = ReplyValidator.validateContent(null);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('tidak boleh kosong'));
    });

    test('returns invalid for empty content', () {
      final result = ReplyValidator.validateContent('');
      expect(result.isValid, isFalse);
    });

    test('returns invalid for whitespace-only content', () {
      final result = ReplyValidator.validateContent('   ');
      expect(result.isValid, isFalse);
    });
  });

  group('ReplyValidator.validateDiscussionOpen', () {
    /// **Feature: forum-discussion-feature, Property 6: Closed Discussion Reply Prevention**
    /// *For any* discussion with status "closed", no new replies should be allowed.
    /// **Validates: Requirements 3.5, 4.3, 6.3**
    test('Property 6: Returns valid when discussion is open', () {
      final result = ReplyValidator.validateDiscussionOpen(false);
      expect(result.isValid, isTrue);
    });

    test('Property 6: Returns invalid when discussion is closed', () {
      final result = ReplyValidator.validateDiscussionOpen(true);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('sudah ditutup'));
    });

    test('returns invalid for null status', () {
      final result = ReplyValidator.validateDiscussionOpen(null);
      expect(result.isValid, isFalse);
    });
  });

  group('ReplyValidator.validateUserRoleForReply', () {
    /// **Feature: forum-discussion-feature, Property 2: Reply Authorization**
    /// *For any* reply creation attempt, only users with role "student"
    /// should be able to create replies.
    /// **Validates: Requirements 3.1-3.7**
    test('Property 2: Only students can reply', () {
      // Student can reply
      final studentResult = ReplyValidator.validateUserRoleForReply('student');
      expect(studentResult.isValid, isTrue);

      // Mentor cannot reply
      final mentorResult = ReplyValidator.validateUserRoleForReply('mentor');
      expect(mentorResult.isValid, isFalse);
      expect(mentorResult.errorMessage, contains('Hanya student'));
    });

    /// **Feature: forum-discussion-feature, Property 3: Mentor Read-Only Access**
    /// *For any* mentor accessing a discussion, they should only be able to view,
    /// not create or reply.
    /// **Validates: Requirements 5.1-5.6, 6.1-6.6**
    test('Property 3: Mentor has read-only access (cannot reply)', () {
      final result = ReplyValidator.validateUserRoleForReply('mentor');
      expect(result.isValid, isFalse);
    });

    test('returns invalid for null role', () {
      final result = ReplyValidator.validateUserRoleForReply(null);
      expect(result.isValid, isFalse);
    });
  });

  group('ReplyValidator.validateParentReply', () {
    /// **Feature: forum-discussion-feature, Property 8: Reply Hierarchy Consistency**
    /// *For any* reply with parent_reply_id, the parent reply must exist.
    /// **Validates: Requirements 3.3-3.4, 7.1-7.5**
    test('Property 8: Returns valid for top-level reply (no parent)', () {
      final result = ReplyValidator.validateParentReply(
        parentReplyId: null,
        parentExists: false,
      );
      expect(result.isValid, isTrue);
    });

    test('Property 8: Returns valid when parent reply exists', () {
      final result = ReplyValidator.validateParentReply(
        parentReplyId: 'reply-1',
        parentExists: true,
      );
      expect(result.isValid, isTrue);
    });

    test('Property 8: Returns invalid when parent reply does not exist', () {
      final result = ReplyValidator.validateParentReply(
        parentReplyId: 'reply-1',
        parentExists: false,
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('tidak ditemukan'));
    });
  });

  group('ReplyValidator.validateNestedReplyMention', () {
    /// **Feature: forum-discussion-feature, Property 5: Reply Mention Consistency**
    /// *For any* reply with parent_reply_id, the content should contain
    /// "@username" mention of the parent reply's author.
    /// **Validates: Requirements 7.1-7.5**
    test('Property 5: Returns valid when @mention is present', () {
      final result = ReplyValidator.validateNestedReplyMention(
        parentReplyId: 'reply-1',
        parentAuthorName: 'John Doe',
        content: '@John Doe This is my reply',
      );
      expect(result.isValid, isTrue);
    });

    test('Property 5: Returns invalid when @mention is missing', () {
      final result = ReplyValidator.validateNestedReplyMention(
        parentReplyId: 'reply-1',
        parentAuthorName: 'John Doe',
        content: 'This is my reply without mention',
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('@John Doe'));
    });

    test('Property 5: Skips validation for top-level reply', () {
      final result = ReplyValidator.validateNestedReplyMention(
        parentReplyId: null,
        parentAuthorName: 'John Doe',
        content: 'This is a top-level reply',
      );
      expect(result.isValid, isTrue);
    });

    test('Property 5: Skips validation when parent author is unknown', () {
      final result = ReplyValidator.validateNestedReplyMention(
        parentReplyId: 'reply-1',
        parentAuthorName: null,
        content: 'This is my reply',
      );
      expect(result.isValid, isTrue);
    });
  });

  group('ReplyValidator.validateForCreate', () {
    test('returns valid for complete valid data', () {
      final result = ReplyValidator.validateForCreate(
        content: 'Test reply content',
        isDiscussionClosed: false,
        userRole: 'student',
        classId: 'class-1',
        enrolledClassIds: ['class-1', 'class-2'],
        discussionId: 'discussion-1',
      );
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('returns multiple errors for invalid data', () {
      final result = ReplyValidator.validateForCreate(
        content: '',
        isDiscussionClosed: true,
        userRole: 'mentor',
        classId: 'class-3',
        enrolledClassIds: ['class-1', 'class-2'],
        discussionId: 'discussion-1',
      );
      expect(result.isValid, isFalse);
      expect(result.errors.length, greaterThan(1));
      expect(result.hasError('content'), isTrue);
      expect(result.hasError('discussionStatus'), isTrue);
      expect(result.hasError('role'), isTrue);
    });

    test('validates nested reply with parent', () {
      final result = ReplyValidator.validateForCreate(
        content: 'Reply to another reply',
        isDiscussionClosed: false,
        userRole: 'student',
        classId: 'class-1',
        enrolledClassIds: ['class-1'],
        discussionId: 'discussion-1',
        parentReplyId: 'reply-1',
        parentReplyExists: true,
        parentReplyDiscussionId: 'discussion-1',
      );
      expect(result.isValid, isTrue);
    });

    test('returns error when parent reply not found', () {
      final result = ReplyValidator.validateForCreate(
        content: 'Reply to another reply',
        isDiscussionClosed: false,
        userRole: 'student',
        classId: 'class-1',
        enrolledClassIds: ['class-1'],
        discussionId: 'discussion-1',
        parentReplyId: 'reply-1',
        parentReplyExists: false,
      );
      expect(result.isValid, isFalse);
      expect(result.hasError('parentReply'), isTrue);
    });
  });
}
