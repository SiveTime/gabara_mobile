// lib/features/meetings/domain/validators/meeting_validator.dart
// Requirements: 16.1-16.6

import '../../data/models/meeting_model.dart';

/// Validator for Meeting data
/// **Validates: Requirements 16.1-16.6**
class MeetingValidator {
  /// Validate meeting data for creation
  static ValidationResult validateForCreate(MeetingModel meeting) {
    final errors = <String>[];

    // Validate title
    if (meeting.title.trim().isEmpty) {
      errors.add('Judul meeting tidak boleh kosong');
    }

    // Validate class ID
    if (meeting.classId.isEmpty) {
      errors.add('Kelas harus dipilih');
    }

    // Validate meeting date is not in the past
    if (meeting.meetingDate.isBefore(DateTime.now())) {
      errors.add('Tanggal meeting tidak boleh di masa lalu');
    }

    // Validate duration
    if (meeting.durationMinutes <= 0) {
      errors.add('Durasi meeting harus lebih dari 0 menit');
    }

    // Validate meeting type
    if (!['online', 'offline'].contains(meeting.meetingType)) {
      errors.add('Tipe meeting tidak valid');
    }

    // Validate meeting link for online meetings
    if (meeting.meetingType == 'online') {
      if (meeting.meetingLink == null || meeting.meetingLink!.trim().isEmpty) {
        errors.add('Meeting online harus memiliki link');
      } else if (!_isValidUrl(meeting.meetingLink!)) {
        errors.add('Format link meeting tidak valid');
      }
    }

    // Validate location for offline meetings
    if (meeting.meetingType == 'offline') {
      if (meeting.location == null || meeting.location!.trim().isEmpty) {
        errors.add('Meeting offline harus memiliki lokasi');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate meeting data for update
  static ValidationResult validateForUpdate(MeetingModel meeting) {
    final errors = <String>[];

    // Validate title
    if (meeting.title.trim().isEmpty) {
      errors.add('Judul meeting tidak boleh kosong');
    }

    // Validate duration
    if (meeting.durationMinutes <= 0) {
      errors.add('Durasi meeting harus lebih dari 0 menit');
    }

    // Validate meeting type
    if (!['online', 'offline'].contains(meeting.meetingType)) {
      errors.add('Tipe meeting tidak valid');
    }

    // Validate meeting link for online meetings
    if (meeting.meetingType == 'online') {
      if (meeting.meetingLink == null || meeting.meetingLink!.trim().isEmpty) {
        errors.add('Meeting online harus memiliki link');
      } else if (!_isValidUrl(meeting.meetingLink!)) {
        errors.add('Format link meeting tidak valid');
      }
    }

    // Validate location for offline meetings
    if (meeting.meetingType == 'offline') {
      if (meeting.location == null || meeting.location!.trim().isEmpty) {
        errors.add('Meeting offline harus memiliki lokasi');
      }
    }

    // Validate status
    if (!['scheduled', 'ongoing', 'completed', 'cancelled']
        .contains(meeting.status)) {
      errors.add('Status meeting tidak valid');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Validate attendance status
  static ValidationResult validateAttendanceStatus(String status) {
    final validStatuses = ['present', 'absent', 'late', 'excused'];
    if (!validStatuses.contains(status)) {
      return ValidationResult(
        isValid: false,
        errors: ['Status kehadiran tidak valid'],
      );
    }
    return ValidationResult(isValid: true, errors: []);
  }

  /// Check if URL is valid
  static bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }
}

/// Result of validation
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });

  String get errorMessage => errors.join(', ');
}
