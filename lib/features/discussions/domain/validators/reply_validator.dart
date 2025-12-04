import 'discussion_validator.dart';

/// Validator untuk Reply (Balasan Diskusi)
/// Validates: Requirements 9.3, 3.5, 6.3, 3.1-3.7
class ReplyValidator {
  /// Validate reply content
  static ValidationResult validateContent(String? content) {
    if (content == null || content.trim().isEmpty) {
      return ValidationResult.invalid('Balasan tidak boleh kosong');
    }
    return ValidationResult.valid();
  }

  /// Validate discussion is open for replies
  static ValidationResult validateDiscussionOpen(bool? isClosed) {
    if (isClosed == null) {
      return ValidationResult.invalid('Status diskusi tidak valid');
    }
    if (isClosed) {
      return ValidationResult.invalid(
        'Diskusi sudah ditutup, tidak dapat menambah balasan',
      );
    }
    return ValidationResult.valid();
  }

  /// Validate user role for reply creation (student only)
  static ValidationResult validateUserRoleForReply(String? role) {
    if (role == null || role.isEmpty) {
      return ValidationResult.invalid('Role pengguna tidak valid');
    }
    if (role.toLowerCase() != 'student') {
      return ValidationResult.invalid(
        'Hanya student yang dapat membalas diskusi',
      );
    }
    return ValidationResult.valid();
  }

  /// Validate parent reply exists (for nested replies)
  static ValidationResult validateParentReply({
    required String? parentReplyId,
    required bool parentExists,
  }) {
    // If no parent reply ID, it's a top-level reply - valid
    if (parentReplyId == null || parentReplyId.isEmpty) {
      return ValidationResult.valid();
    }

    // If parent reply ID provided, parent must exist
    if (!parentExists) {
      return ValidationResult.invalid(
        'Balasan yang ingin dibalas tidak ditemukan',
      );
    }

    return ValidationResult.valid();
  }

  /// Validate parent reply belongs to same discussion
  static ValidationResult validateParentReplyDiscussion({
    required String? parentReplyId,
    required String discussionId,
    required String? parentReplyDiscussionId,
  }) {
    // If no parent reply, skip this validation
    if (parentReplyId == null || parentReplyId.isEmpty) {
      return ValidationResult.valid();
    }

    if (parentReplyDiscussionId != discussionId) {
      return ValidationResult.invalid(
        'Balasan induk tidak berada di diskusi yang sama',
      );
    }

    return ValidationResult.valid();
  }

  /// Validate class enrollment for reply
  static ValidationResult validateClassEnrollment(
    String? classId,
    List<String> enrolledClassIds,
  ) {
    if (classId == null || classId.isEmpty) {
      return ValidationResult.invalid('Kelas tidak valid');
    }
    if (!enrolledClassIds.contains(classId)) {
      return ValidationResult.invalid('Anda tidak terdaftar di kelas ini');
    }
    return ValidationResult.valid();
  }

  /// Validate all reply fields for creation
  static ReplyValidationResult validateForCreate({
    required String? content,
    required bool isDiscussionClosed,
    required String? userRole,
    required String? classId,
    required List<String> enrolledClassIds,
    String? parentReplyId,
    bool parentReplyExists = true,
    String? parentReplyDiscussionId,
    required String discussionId,
  }) {
    final contentResult = validateContent(content);
    final discussionOpenResult = validateDiscussionOpen(isDiscussionClosed);
    final roleResult = validateUserRoleForReply(userRole);
    final enrollmentResult = validateClassEnrollment(classId, enrolledClassIds);
    final parentResult = validateParentReply(
      parentReplyId: parentReplyId,
      parentExists: parentReplyExists,
    );
    final parentDiscussionResult = validateParentReplyDiscussion(
      parentReplyId: parentReplyId,
      discussionId: discussionId,
      parentReplyDiscussionId: parentReplyDiscussionId ?? discussionId,
    );

    final errors = <String, String>{};

    if (!contentResult.isValid) {
      errors['content'] = contentResult.errorMessage!;
    }
    if (!discussionOpenResult.isValid) {
      errors['discussionStatus'] = discussionOpenResult.errorMessage!;
    }
    if (!roleResult.isValid) {
      errors['role'] = roleResult.errorMessage!;
    }
    if (!enrollmentResult.isValid) {
      errors['enrollment'] = enrollmentResult.errorMessage!;
    }
    if (!parentResult.isValid) {
      errors['parentReply'] = parentResult.errorMessage!;
    }
    if (!parentDiscussionResult.isValid) {
      errors['parentReplyDiscussion'] = parentDiscussionResult.errorMessage!;
    }

    return ReplyValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Validate @mention format in content
  static ValidationResult validateMentionFormat(String content) {
    // Check if content has @mention pattern
    final mentionRegex = RegExp(r'@(\w+(?:\s+\w+)?)');
    final matches = mentionRegex.allMatches(content);

    // If content starts with @, it should have valid mention
    if (content.trim().startsWith('@') && matches.isEmpty) {
      return ValidationResult.invalid('Format @mention tidak valid');
    }

    return ValidationResult.valid();
  }

  /// Validate that nested reply has @mention of parent author
  static ValidationResult validateNestedReplyMention({
    required String? parentReplyId,
    required String? parentAuthorName,
    required String content,
  }) {
    // If not a nested reply, skip validation
    if (parentReplyId == null || parentReplyId.isEmpty) {
      return ValidationResult.valid();
    }

    // If parent author name is unknown, skip validation
    if (parentAuthorName == null || parentAuthorName.isEmpty) {
      return ValidationResult.valid();
    }

    // Check if content contains @mention of parent author
    if (!content.contains('@$parentAuthorName')) {
      return ValidationResult.invalid(
        'Balasan ke balasan lain harus menyertakan @$parentAuthorName',
      );
    }

    return ValidationResult.valid();
  }
}

/// Reply validation result with multiple field errors
class ReplyValidationResult {
  final bool isValid;
  final Map<String, String> errors;

  const ReplyValidationResult({required this.isValid, this.errors = const {}});

  /// Get error for specific field
  String? getError(String field) => errors[field];

  /// Check if specific field has error
  bool hasError(String field) => errors.containsKey(field);

  /// Get all error messages as list
  List<String> get errorMessages => errors.values.toList();

  /// Get first error message
  String? get firstError =>
      errors.values.isNotEmpty ? errors.values.first : null;
}
