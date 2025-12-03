// lib/features/assignments/data/models/assignment_model.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/assignment_entity.dart';

/// Model untuk Assignment dengan serialization
class AssignmentModel extends AssignmentEntity {
  const AssignmentModel({
    required super.id,
    required super.classId,
    super.meetingId,
    required super.title,
    super.description,
    required super.deadline,
    super.maxScore,
    super.attachmentUrl,
    super.isActive,
    required super.createdBy,
    super.createdAt,
    super.updatedAt,
  });

  /// Create from JSON (Supabase response)
  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id']?.toString() ?? '',
      classId: json['class_id']?.toString() ?? '',
      meetingId: json['meeting_id']?.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      deadline: _parseDateTime(json['deadline']) ?? DateTime.now(),
      maxScore: json['max_score'] ?? 100,
      attachmentUrl: json['attachment_url'],
      isActive: json['is_active'] ?? true,
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'class_id': classId,
      'title': title,
      'description': description,
      'deadline': _formatDateTimeForSupabase(deadline),
      'max_score': maxScore,
      'attachment_url': attachmentUrl,
      'is_active': isActive,
      'created_by': createdBy,
    };
    // Only include meeting_id if it's not null
    if (meetingId != null) {
      json['meeting_id'] = meetingId;
    }
    return json;
  }

  /// Convert to JSON for creating new assignment (without id)
  Map<String, dynamic> toCreateJson() {
    final json = {
      'class_id': classId,
      'title': title,
      'description': description,
      'deadline': _formatDateTimeForSupabase(deadline),
      'max_score': maxScore,
      'attachment_url': attachmentUrl,
      'is_active': isActive,
      'created_by': createdBy,
    };
    // Only include meeting_id if it's not null
    if (meetingId != null) {
      json['meeting_id'] = meetingId;
    }
    return json;
  }

  /// Convert to JSON for updating assignment
  Map<String, dynamic> toUpdateJson() => {
        'title': title,
        'description': description,
        'deadline': _formatDateTimeForSupabase(deadline),
        'max_score': maxScore,
        'attachment_url': attachmentUrl,
        'is_active': isActive,
      };

  @override
  AssignmentModel copyWith({
    String? id,
    String? classId,
    String? meetingId,
    String? title,
    String? description,
    DateTime? deadline,
    int? maxScore,
    String? attachmentUrl,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      meetingId: meetingId ?? this.meetingId,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      maxScore: maxScore ?? this.maxScore,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      isActive: isActive ?? this.isActive,
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
