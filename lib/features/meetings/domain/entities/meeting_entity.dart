// lib/features/meetings/domain/entities/meeting_entity.dart
import 'package:equatable/equatable.dart';

/// Entity untuk Meeting/Pertemuan
/// Represents a class meeting that can be online or offline
class MeetingEntity extends Equatable {
  final String id;
  final String classId;
  final String title;
  final String description;
  final DateTime meetingDate;
  final int durationMinutes;
  final String meetingType; // 'online' | 'offline'
  final String? meetingLink; // for online meetings
  final String? location; // for offline meetings
  final String status; // 'scheduled' | 'ongoing' | 'completed' | 'cancelled'
  final String createdBy; // mentor user_id
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MeetingEntity({
    required this.id,
    required this.classId,
    required this.title,
    this.description = '',
    required this.meetingDate,
    this.durationMinutes = 60,
    required this.meetingType,
    this.meetingLink,
    this.location,
    this.status = 'scheduled',
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  /// Check if meeting is online
  bool get isOnline => meetingType == 'online';

  /// Check if meeting is offline
  bool get isOffline => meetingType == 'offline';

  /// Check if meeting is scheduled
  bool get isScheduled => status == 'scheduled';

  /// Check if meeting is ongoing
  bool get isOngoing => status == 'ongoing';

  /// Check if meeting is completed
  bool get isCompleted => status == 'completed';

  /// Check if meeting is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Get meeting end time
  DateTime get endTime => meetingDate.add(Duration(minutes: durationMinutes));

  /// Check if meeting has started
  bool get hasStarted => DateTime.now().isAfter(meetingDate);

  /// Check if meeting has ended
  bool get hasEnded => DateTime.now().isAfter(endTime);

  /// Copy with new values
  MeetingEntity copyWith({
    String? id,
    String? classId,
    String? title,
    String? description,
    DateTime? meetingDate,
    int? durationMinutes,
    String? meetingType,
    String? meetingLink,
    String? location,
    String? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MeetingEntity(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      title: title ?? this.title,
      description: description ?? this.description,
      meetingDate: meetingDate ?? this.meetingDate,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      meetingType: meetingType ?? this.meetingType,
      meetingLink: meetingLink ?? this.meetingLink,
      location: location ?? this.location,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        classId,
        title,
        description,
        meetingDate,
        durationMinutes,
        meetingType,
        meetingLink,
        location,
        status,
        createdBy,
        createdAt,
        updatedAt,
      ];
}

/// Valid meeting types
class MeetingType {
  static const String online = 'online';
  static const String offline = 'offline';

  static const List<String> values = [online, offline];

  static bool isValid(String type) => values.contains(type);
}

/// Valid meeting statuses
class MeetingStatus {
  static const String scheduled = 'scheduled';
  static const String ongoing = 'ongoing';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';

  static const List<String> values = [scheduled, ongoing, completed, cancelled];

  static bool isValid(String status) => values.contains(status);

  /// Check if transition from one status to another is valid
  static bool isValidTransition(String from, String to) {
    switch (from) {
      case scheduled:
        return to == ongoing || to == cancelled;
      case ongoing:
        return to == completed || to == cancelled;
      case completed:
        return false; // Cannot transition from completed
      case cancelled:
        return false; // Cannot transition from cancelled
      default:
        return false;
    }
  }
}
