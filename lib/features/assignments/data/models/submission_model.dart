// lib/features/assignments/data/models/submission_model.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/submission_entity.dart';

/// Model untuk Submission dengan serialization
class SubmissionModel extends SubmissionEntity {
  const SubmissionModel({
    required super.id,
    required super.assignmentId,
    required super.studentId,
    super.content,
    super.attachmentUrl,
    super.status,
    super.submittedAt,
    super.score,
    super.feedback,
    super.gradedAt,
    super.gradedBy,
    super.createdAt,
    super.updatedAt,
    super.studentName,
  });

  /// Create from JSON (Supabase response) - for 'submissions' table
  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    // Handle nested profile data for student name
    String? studentName;
    if (json['profiles'] != null) {
      studentName = json['profiles']['full_name'];
    }

    return SubmissionModel(
      id: json['id']?.toString() ?? '',
      assignmentId: json['assignment_id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      content: json['content'] ?? '',
      attachmentUrl: json['attachment_url'],
      status: json['status'] ?? 'draft',
      submittedAt: _parseDateTime(json['submitted_at']),
      score: json['score']?.toDouble(),
      feedback: json['feedback'],
      gradedAt: _parseDateTime(json['graded_at']),
      gradedBy: json['graded_by']?.toString(),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      studentName: studentName,
    );
  }

  /// Create from JSON V2 (Supabase response) - for 'assignment_submissions' table
  /// This table uses 'user_id' instead of 'student_id'
  factory SubmissionModel.fromJsonV2(Map<String, dynamic> json) {
    // Handle nested profile data for student name
    String? studentName;
    if (json['profiles'] != null) {
      studentName = json['profiles']['full_name'];
    }

    return SubmissionModel(
      id: json['id']?.toString() ?? '',
      assignmentId: json['assignment_id']?.toString() ?? '',
      studentId: json['user_id']?.toString() ?? '', // V2 uses user_id
      content: json['content'] ?? '',
      attachmentUrl: json['attachment_url'],
      status: json['status'] ?? 'draft',
      submittedAt: _parseDateTime(json['submitted_at']),
      score: json['score']?.toDouble(),
      feedback: json['feedback'],
      gradedAt: _parseDateTime(json['graded_at']),
      gradedBy: json['graded_by']?.toString(),
      createdAt: null, // V2 table doesn't have created_at
      updatedAt: null, // V2 table doesn't have updated_at
      studentName: studentName,
    );
  }

  /// Create from RPC function response
  /// RPC returns flat structure with student_name directly
  factory SubmissionModel.fromRpcJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id']?.toString() ?? '',
      assignmentId: json['assignment_id']?.toString() ?? '',
      studentId: json['user_id']?.toString() ?? '',
      content: json['content'] ?? '',
      attachmentUrl: json['attachment_url'],
      status: json['status'] ?? 'draft',
      submittedAt: _parseDateTime(json['submitted_at']),
      score: json['score']?.toDouble(),
      feedback: json['feedback'],
      gradedAt: _parseDateTime(json['graded_at']),
      gradedBy: json['graded_by']?.toString(),
      createdAt: null,
      updatedAt: null,
      studentName: json['student_name'], // RPC returns this directly
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() => {
        'id': id,
        'assignment_id': assignmentId,
        'student_id': studentId,
        'content': content,
        'attachment_url': attachmentUrl,
        'status': status,
        'submitted_at': _formatDateTimeForSupabase(submittedAt),
        'score': score,
        'feedback': feedback,
        'graded_at': _formatDateTimeForSupabase(gradedAt),
        'graded_by': gradedBy,
      };

  /// Convert to JSON for creating new submission (without id)
  Map<String, dynamic> toCreateJson() => {
        'assignment_id': assignmentId,
        'student_id': studentId,
        'content': content,
        'attachment_url': attachmentUrl,
        'status': status,
        'submitted_at': _formatDateTimeForSupabase(submittedAt),
      };

  /// Convert to JSON for updating submission (student edit)
  Map<String, dynamic> toUpdateJson() => {
        'content': content,
        'attachment_url': attachmentUrl,
        'status': status,
        'submitted_at': _formatDateTimeForSupabase(submittedAt),
      };

  /// Convert to JSON for grading submission (mentor)
  Map<String, dynamic> toGradeJson() => {
        'score': score,
        'feedback': feedback,
        'status': 'graded',
        'graded_at': _formatDateTimeForSupabase(DateTime.now()),
        'graded_by': gradedBy,
      };

  @override
  SubmissionModel copyWith({
    String? id,
    String? assignmentId,
    String? studentId,
    String? content,
    String? attachmentUrl,
    String? status,
    DateTime? submittedAt,
    double? score,
    String? feedback,
    DateTime? gradedAt,
    String? gradedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? studentName,
  }) {
    return SubmissionModel(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      studentId: studentId ?? this.studentId,
      content: content ?? this.content,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      score: score ?? this.score,
      feedback: feedback ?? this.feedback,
      gradedAt: gradedAt ?? this.gradedAt,
      gradedBy: gradedBy ?? this.gradedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
