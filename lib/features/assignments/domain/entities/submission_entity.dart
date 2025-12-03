// lib/features/assignments/domain/entities/submission_entity.dart
import 'package:equatable/equatable.dart';

/// Entity untuk Submission/Pengumpulan Tugas
/// Represents a student's submission for an assignment
class SubmissionEntity extends Equatable {
  final String id;
  final String assignmentId;
  final String studentId;
  final String content;
  final String? attachmentUrl;
  final String status; // 'draft' | 'submitted' | 'graded' | 'late' | 'returned'
  final DateTime? submittedAt;
  final double? score;
  final String? feedback;
  final DateTime? gradedAt;
  final String? gradedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? studentName; // Optional: for display purposes

  const SubmissionEntity({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    this.content = '',
    this.attachmentUrl,
    this.status = 'draft',
    this.submittedAt,
    this.score,
    this.feedback,
    this.gradedAt,
    this.gradedBy,
    this.createdAt,
    this.updatedAt,
    this.studentName,
  });

  /// Check if submission is draft
  bool get isDraft => status == 'draft';

  /// Check if submission is submitted
  bool get isSubmitted => status == 'submitted';

  /// Check if submission is graded
  bool get isGraded => status == 'graded';

  /// Check if submission is late
  bool get isLate => status == 'late';

  /// Check if submission is returned for revision
  bool get isReturned => status == 'returned';

  /// Check if submission has been submitted (not draft)
  bool get hasBeenSubmitted => status != 'draft';

  /// Check if submission has attachment
  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;

  /// Check if submission has feedback
  bool get hasFeedback => feedback != null && feedback!.isNotEmpty;

  /// Get score percentage (if graded)
  double? getPercentage(int maxScore) {
    if (score == null || maxScore <= 0) return null;
    return (score! / maxScore) * 100;
  }

  /// Copy with new values
  SubmissionEntity copyWith({
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
    return SubmissionEntity(
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

  @override
  List<Object?> get props => [
        id,
        assignmentId,
        studentId,
        content,
        attachmentUrl,
        status,
        submittedAt,
        score,
        feedback,
        gradedAt,
        gradedBy,
        createdAt,
        updatedAt,
        studentName,
      ];
}

/// Valid submission statuses
class SubmissionStatus {
  static const String draft = 'draft';
  static const String submitted = 'submitted';
  static const String graded = 'graded';
  static const String late = 'late';
  static const String returned = 'returned';

  static const List<String> values = [draft, submitted, graded, late, returned];

  static bool isValid(String status) => values.contains(status);
}
