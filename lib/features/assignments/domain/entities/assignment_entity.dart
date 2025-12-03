// lib/features/assignments/domain/entities/assignment_entity.dart
import 'package:equatable/equatable.dart';

/// Entity untuk Assignment/Tugas
/// Represents an assignment given by mentor to students
class AssignmentEntity extends Equatable {
  final String id;
  final String classId;
  final String? meetingId; // Optional link to meeting
  final String title;
  final String description;
  final DateTime deadline;
  final int maxScore;
  final String? attachmentUrl;
  final bool isActive;
  final String createdBy; // mentor user_id
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AssignmentEntity({
    required this.id,
    required this.classId,
    this.meetingId,
    required this.title,
    this.description = '',
    required this.deadline,
    this.maxScore = 100,
    this.attachmentUrl,
    this.isActive = true,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  /// Check if assignment is still open for submission
  bool get isOpen => DateTime.now().isBefore(deadline) && isActive;

  /// Check if assignment deadline has passed
  bool get isClosed => DateTime.now().isAfter(deadline) || !isActive;

  /// Check if assignment has attachment
  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;

  /// Get remaining time until deadline
  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(deadline)) return Duration.zero;
    return deadline.difference(now);
  }

  /// Check if deadline is approaching (within 24 hours)
  bool get isDeadlineApproaching {
    final remaining = remainingTime;
    return remaining > Duration.zero && remaining <= const Duration(hours: 24);
  }

  /// Check if assignment is linked to a meeting
  bool get hasLinkedMeeting => meetingId != null && meetingId!.isNotEmpty;

  /// Copy with new values
  AssignmentEntity copyWith({
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
    return AssignmentEntity(
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

  @override
  List<Object?> get props => [
        id,
        classId,
        meetingId,
        title,
        description,
        deadline,
        maxScore,
        attachmentUrl,
        isActive,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
