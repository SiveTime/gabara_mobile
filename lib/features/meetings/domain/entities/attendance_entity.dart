// lib/features/meetings/domain/entities/attendance_entity.dart
import 'package:equatable/equatable.dart';

/// Entity untuk Attendance/Kehadiran
/// Represents a student's attendance record for a meeting
class AttendanceEntity extends Equatable {
  final String id;
  final String meetingId;
  final String studentId;
  final String status; // 'present' | 'absent' | 'late' | 'excused'
  final DateTime? markedAt;
  final String? studentName; // Optional: for display purposes

  const AttendanceEntity({
    required this.id,
    required this.meetingId,
    required this.studentId,
    required this.status,
    this.markedAt,
    this.studentName,
  });

  /// Check if student is present
  bool get isPresent => status == 'present';

  /// Check if student is absent
  bool get isAbsent => status == 'absent';

  /// Check if student is late
  bool get isLate => status == 'late';

  /// Check if student is excused
  bool get isExcused => status == 'excused';

  /// Copy with new values
  AttendanceEntity copyWith({
    String? id,
    String? meetingId,
    String? studentId,
    String? status,
    DateTime? markedAt,
    String? studentName,
  }) {
    return AttendanceEntity(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      markedAt: markedAt ?? this.markedAt,
      studentName: studentName ?? this.studentName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        meetingId,
        studentId,
        status,
        markedAt,
        studentName,
      ];
}

/// Valid attendance statuses
class AttendanceStatus {
  static const String present = 'present';
  static const String absent = 'absent';
  static const String late = 'late';
  static const String excused = 'excused';

  static const List<String> values = [present, absent, late, excused];

  static bool isValid(String status) => values.contains(status);
}
