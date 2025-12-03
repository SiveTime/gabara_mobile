// lib/features/meetings/data/models/attendance_model.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/attendance_entity.dart';

/// Model untuk Attendance dengan serialization
class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required super.id,
    required super.meetingId,
    required super.studentId,
    required super.status,
    super.markedAt,
    super.studentName,
  });

  /// Create from JSON (Supabase response)
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    // Handle nested profile data for student name
    String? studentName;
    if (json['profiles'] != null) {
      studentName = json['profiles']['full_name'];
    }

    return AttendanceModel(
      id: json['id']?.toString() ?? '',
      meetingId: json['meeting_id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      status: json['status'] ?? 'absent',
      markedAt: _parseDateTime(json['marked_at']),
      studentName: studentName,
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() => {
        'id': id,
        'meeting_id': meetingId,
        'student_id': studentId,
        'status': status,
        'marked_at': _formatDateTimeForSupabase(markedAt),
      };

  /// Convert to JSON for creating new attendance (without id)
  Map<String, dynamic> toCreateJson() => {
        'meeting_id': meetingId,
        'student_id': studentId,
        'status': status,
        'marked_at': _formatDateTimeForSupabase(DateTime.now()),
      };

  /// Convert to JSON for updating attendance
  Map<String, dynamic> toUpdateJson() => {
        'status': status,
        'marked_at': _formatDateTimeForSupabase(DateTime.now()),
      };

  @override
  AttendanceModel copyWith({
    String? id,
    String? meetingId,
    String? studentId,
    String? status,
    DateTime? markedAt,
    String? studentName,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      markedAt: markedAt ?? this.markedAt,
      studentName: studentName ?? this.studentName,
    );
  }
}

/// Helper function untuk parse DateTime dari Supabase
DateTime? _parseDateTime(String? dateString) {
  if (dateString == null || dateString.isEmpty) return null;
  try {
    final parsed = DateTime.tryParse(dateString);
    if (parsed == null) return null;
    if (parsed.isUtc) {
      return parsed.toLocal();
    }
    return parsed;
  } catch (e) {
    debugPrint('Error parsing DateTime: $dateString - $e');
    return null;
  }
}

/// Helper function untuk format DateTime ke ISO8601 string untuk Supabase
String? _formatDateTimeForSupabase(DateTime? dateTime) {
  if (dateTime == null) return null;
  return dateTime.toUtc().toIso8601String();
}
