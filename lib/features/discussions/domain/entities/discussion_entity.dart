import 'package:equatable/equatable.dart';

/// Entity untuk Discussion (Thread Diskusi)
class DiscussionEntity extends Equatable {
  final String id;
  final String classId;
  final String title;
  final String content;
  final bool isPinned;
  final bool isClosed;
  final int viewCount;
  final String createdBy;
  final String? creatorName;
  final String? creatorInitials;
  final String? className;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int replyCount;

  const DiscussionEntity({
    required this.id,
    required this.classId,
    required this.title,
    required this.content,
    this.isPinned = false,
    this.isClosed = false,
    this.viewCount = 0,
    required this.createdBy,
    this.creatorName,
    this.creatorInitials,
    this.className,
    required this.createdAt,
    required this.updatedAt,
    this.replyCount = 0,
  });

  /// Get status text for display
  String get statusText => isClosed ? 'Closed' : 'Open';

  /// Check if discussion is open for replies
  bool get isOpen => !isClosed;

  @override
  List<Object?> get props => [
    id,
    classId,
    title,
    content,
    isPinned,
    isClosed,
    viewCount,
    createdBy,
    creatorName,
    className,
    createdAt,
    updatedAt,
    replyCount,
  ];
}
