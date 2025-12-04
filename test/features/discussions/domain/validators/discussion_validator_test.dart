// test/features/discussions/domain/validators/discussion_validator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:gabara_mobile/features/discussions/domain/validators/discussion_validator.dart';

void main() {
  group('DiscussionValidator.validateTitle', () {
    test('returns valid for non-empty title', () {
      final result = DiscussionValidator.validateTitle('Test Title');
      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('returns invalid for null title', () {
      final result = DiscussionValidator.validateTitle(null);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('tidak boleh kosong'));
    });

    test('returns invalid for empty title', () {
      final result = DiscussionValidator.validateTitle('');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('tidak boleh kosong'));
    });

    test('returns invalid for whitespace-only title', () {
      final result = DiscussionValidator.validateTitle('   ');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('tidak boleh kosong'));
    });

    test('returns invalid for title exceeding 255 characters', () {
      final longTitle = 'a' * 256;
      final result = DiscussionValidator.validateTitle(longTitle);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('maksimal 255'));
    });

    test('returns valid for title with exactly 255 characters', () {
      final maxTitle = 'a' * 255;
      final result = DiscussionValidator.validateTitle(maxTitle);
      expect(result.isValid, isTrue);
    });
  });

  group('DiscussionValidator.validateContent', () {
    test('returns valid for non-empty content', () {
      final result = DiscussionValidator.validateContent('Test content');
      expect(result.isValid, isTrue);
    });

    test('returns invalid for null content', () {
      final result = DiscussionValidator.validateContent(null);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('tidak boleh kosong'));
    });

    test('returns invalid for empty content', () {
      final result = DiscussionValidator.validateContent('');
      expect(result.isValid, isFalse);
    });
  });

  group('DiscussionValidator.validateUserRoleForCreate', () {
    /// **Feature: forum-discussion-feature, Property 1: Discussion Creation Authorization**
    /// *For any* discussion creation attempt, only users with role "student"
    /// should be able to create discussions.
    /// **Validates: Requirements 1.1-1.8**
    test('Property 1: Only students can create discussions', () {
      // Student can create
      final studentResult = DiscussionValidator.validateUserRoleForCreate(
        'student',
      );
      expect(studentResult.isValid, isTrue);

      // Mentor cannot create
      final mentorResult = DiscussionValidator.validateUserRoleForCreate(
        'mentor',
      );
      expect(mentorResult.isValid, isFalse);
      expect(mentorResult.errorMessage, contains('Hanya student'));

      // Admin cannot create
      final adminResult = DiscussionValidator.validateUserRoleForCreate(
        'admin',
      );
      expect(adminResult.isValid, isFalse);
    });

    test('returns invalid for null role', () {
      final result = DiscussionValidator.validateUserRoleForCreate(null);
      expect(result.isValid, isFalse);
    });
  });

  group('DiscussionValidator.validateClassEnrollment', () {
    test('returns valid when user is enrolled in class', () {
      final result = DiscussionValidator.validateClassEnrollment('class-1', [
        'class-1',
        'class-2',
        'class-3',
      ]);
      expect(result.isValid, isTrue);
    });

    test('returns invalid when user is not enrolled in class', () {
      final result = DiscussionValidator.validateClassEnrollment('class-4', [
        'class-1',
        'class-2',
        'class-3',
      ]);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('tidak terdaftar'));
    });

    test('returns invalid for null classId', () {
      final result = DiscussionValidator.validateClassEnrollment(null, [
        'class-1',
      ]);
      expect(result.isValid, isFalse);
    });
  });

  group('DiscussionValidator.validateStatusToggleAuthorization', () {
    /// **Feature: forum-discussion-feature, Property 4: Discussion Status Toggle Authorization**
    /// *For any* discussion status change, only the discussion creator (student)
    /// OR any mentor of the class should be able to toggle the status.
    /// **Validates: Requirements 4.1-4.6, 6.1-6.6**
    test('Property 4: Creator can toggle status', () {
      final result = DiscussionValidator.validateStatusToggleAuthorization(
        currentUserId: 'user-1',
        discussionCreatorId: 'user-1',
        userRole: 'student',
        isMentorOfClass: false,
      );
      expect(result.isValid, isTrue);
    });

    test('Property 4: Mentor of class can toggle status', () {
      final result = DiscussionValidator.validateStatusToggleAuthorization(
        currentUserId: 'mentor-1',
        discussionCreatorId: 'user-1',
        userRole: 'mentor',
        isMentorOfClass: true,
      );
      expect(result.isValid, isTrue);
    });

    test('Property 4: Non-creator student cannot toggle status', () {
      final result = DiscussionValidator.validateStatusToggleAuthorization(
        currentUserId: 'user-2',
        discussionCreatorId: 'user-1',
        userRole: 'student',
        isMentorOfClass: false,
      );
      expect(result.isValid, isFalse);
    });

    test('Property 4: Mentor of different class cannot toggle status', () {
      final result = DiscussionValidator.validateStatusToggleAuthorization(
        currentUserId: 'mentor-2',
        discussionCreatorId: 'user-1',
        userRole: 'mentor',
        isMentorOfClass: false,
      );
      expect(result.isValid, isFalse);
    });
  });

  group('DiscussionValidator.validateForCreate', () {
    test('returns valid for complete valid data', () {
      final result = DiscussionValidator.validateForCreate(
        title: 'Test Discussion',
        content: 'This is test content',
        classId: 'class-1',
        userRole: 'student',
        enrolledClassIds: ['class-1', 'class-2'],
      );
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('returns multiple errors for invalid data', () {
      final result = DiscussionValidator.validateForCreate(
        title: '',
        content: '',
        classId: 'class-3',
        userRole: 'mentor',
        enrolledClassIds: ['class-1', 'class-2'],
      );
      expect(result.isValid, isFalse);
      expect(result.errors.length, greaterThan(1));
      expect(result.hasError('title'), isTrue);
      expect(result.hasError('content'), isTrue);
      expect(result.hasError('role'), isTrue);
    });
  });
}
