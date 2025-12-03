// lib/features/meetings/data/models/meeting_model.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/meeting_entity.dart';

/// Model untuk Meeting dengan serialization
class MeetingModel extends MeetingEntity {
  const MeetingModel({
    required super.id,
    required super.classId,
    required super.title,
    super.description,
    required super.meetingDate,
    super.durationMinutes,
    required super.meetingType,
    super.meetingLink,
    super.location,
    super.status,
    required super.createdBy,
    super.createdAt,
    super.updatedAt,
  });

  /// Create from JSON (Supabase response)
  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id']?.toString() ?? '',
      classId: json['class_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      meetingDate: _parseDateTime(json['meeting_date']) ?? DateTime.now(),
      durationMinutes: json['duration_minutes'] ?? 60,
      meetingType: json['meeting_type'] ?? 'online',
      meetingLink: json['meeting_link'],
      location: json['location'],
      status: json['status'] ?? 'scheduled',
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() => {
        'id': id,
        'class_id': classId,
        'title': title,
        'description': description,
        'meeting_date': _formatDateTimeForSupabase(meetingDate),
        'duration_minutes': durationMinutes,
        'meeting_type': meetingType,
        'meeting_link': meetingLink,
        'location': location,
        'status': status,
        'created_by': createdBy,
      };

  /// Convert to JSON for creating new meeting (without id)
  Map<String, dynamic> toCreateJson() => {
        'class_id': classId,
        'title': title,
        'description': description,
        'meeting_date': _formatDateTimeForSupabase(meetingDate),
        'duration_minutes': durationMinutes,
        'meeting_type': meetingType,
        'meeting_link': meetingLink,
        'location': location,
        'status': status,
        'created_by': createdBy,
      };

  /// Convert to JSON for updating meeting
  Map<String, dynamic> toUpdateJson() => {
        'title': title,
        'description': description,
        'meeting_date': _formatDateTimeForSupabase(meetingDate),
        'duration_minutes': durationMinutes,
        'meeting_type': meetingType,
        'meeting_link': meetingLink,
        'location': location,
        'status': status,
      };

  @override
  MeetingModel copyWith({
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
    return MeetingModel(
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
