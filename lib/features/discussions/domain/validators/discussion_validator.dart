/// Validator untuk Discussion
/// Validates: Requirements 9.1-9.3, 1.1-1.8
class DiscussionValidator {
  /// Maximum title length
  static const int maxTitleLength = 255;

  /// Validation result class
  static ValidationResult validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return ValidationResult.invalid('Judul diskusi tidak boleh kosong');
    }
    if (title.trim().length > maxTitleLength) {
      return ValidationResult.invalid(
        'Judul diskusi maksimal $maxTitleLength karakter',
      );
    }
    return ValidationResult.valid();
  }

  /// Validate discussion content
  static ValidationResult validateContent(String? content) {
    if (content == null || content.trim().isEmpty) {
      return ValidationResult.invalid('Konten diskusi tidak boleh kosong');
    }
    return ValidationResult.valid();
  }

  /// Validate class ID
  static ValidationResult validateClassId(String? classId) {
    if (classId == null || classId.trim().isEmpty) {
      return ValidationResult.invalid('Kelas harus dipilih');
    }
    return ValidationResult.valid();
  }

  /// Validate user role for discussion creation (student only)
  static ValidationResult validateUserRoleForCreate(String? role) {
    if (role == null || role.isEmpty) {
      return ValidationResult.invalid('Role pengguna tidak valid');
    }
    if (role.toLowerCase() != 'student') {
      return ValidationResult.invalid(
        'Hanya student yang dapat membuat diskusi',
      );
    }
    return ValidationResult.valid();
  }

  /// Validate class enrollment for discussion creation
  static ValidationResult validateClassEnrollment(
    String? classId,
    List<String> enrolledClassIds,
  ) {
    if (classId == null || classId.isEmpty) {
      return ValidationResult.invalid('Kelas harus dipilih');
    }
    if (!enrolledClassIds.contains(classId)) {
      return ValidationResult.invalid('Anda tidak terdaftar di kelas ini');
    }
    return ValidationResult.valid();
  }

  /// Validate all discussion fields for creation
  static DiscussionValidationResult validateForCreate({
    required String? title,
    required String? content,
    required String? classId,
    required String? userRole,
    required List<String> enrolledClassIds,
  }) {
    final titleResult = validateTitle(title);
    final contentResult = validateContent(content);
    final classIdResult = validateClassId(classId);
    final roleResult = validateUserRoleForCreate(userRole);
    final enrollmentResult = validateClassEnrollment(classId, enrolledClassIds);

    final errors = <String, String>{};

    if (!titleResult.isValid) {
      errors['title'] = titleResult.errorMessage!;
    }
    if (!contentResult.isValid) {
      errors['content'] = contentResult.errorMessage!;
    }
    if (!classIdResult.isValid) {
      errors['classId'] = classIdResult.errorMessage!;
    }
    if (!roleResult.isValid) {
      errors['role'] = roleResult.errorMessage!;
    }
    if (!enrollmentResult.isValid && classIdResult.isValid) {
      errors['enrollment'] = enrollmentResult.errorMessage!;
    }

    return DiscussionValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Validate user authorization for status toggle
  static ValidationResult validateStatusToggleAuthorization({
    required String? currentUserId,
    required String? discussionCreatorId,
    required String? userRole,
    required bool isMentorOfClass,
  }) {
    if (currentUserId == null) {
      return ValidationResult.invalid('User tidak terautentikasi');
    }

    // Discussion creator can toggle
    if (currentUserId == discussionCreatorId) {
      return ValidationResult.valid();
    }

    // Mentor of the class can toggle
    if (userRole?.toLowerCase() == 'mentor' && isMentorOfClass) {
      return ValidationResult.valid();
    }

    return ValidationResult.invalid(
      'Anda tidak memiliki izin untuk mengubah status diskusi',
    );
  }
}

/// Simple validation result
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult._({required this.isValid, this.errorMessage});

  factory ValidationResult.valid() => const ValidationResult._(isValid: true);

  factory ValidationResult.invalid(String message) =>
      ValidationResult._(isValid: false, errorMessage: message);
}

/// Discussion validation result with multiple field errors
class DiscussionValidationResult {
  final bool isValid;
  final Map<String, String> errors;

  const DiscussionValidationResult({
    required this.isValid,
    this.errors = const {},
  });

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
