import 'package:equatable/equatable.dart';

/// Entity untuk Reply (Balasan Diskusi)
class ReplyEntity extends Equatable {
  final String id;
  final String discussionId;
  final String? parentReplyId;
  final String content;
  final bool isEdited;
  final String createdBy;
  final String? authorName;
  final String? authorInitials;
  final String? mentionedUserName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ReplyEntity> nestedReplies;

  const ReplyEntity({
    required this.id,
    required this.discussionId,
    this.parentReplyId,
    required this.content,
    this.isEdited = false,
    required this.createdBy,
    this.authorName,
    this.authorInitials,
    this.mentionedUserName,
    required this.createdAt,
    required this.updatedAt,
    this.nestedReplies = const [],
  });

  /// Check if this is a nested reply (reply to another reply)
  bool get isNestedReply => parentReplyId != null;

  /// Get display content with @mention if applicable
  String get displayContent {
    if (mentionedUserName != null && mentionedUserName!.isNotEmpty) {
      // Check if content already starts with @mention
      if (!content.startsWith('@$mentionedUserName')) {
        return '@$mentionedUserName $content';
      }
    }
    return content;
  }

  @override
  List<Object?> get props => [
    id,
    discussionId,
    parentReplyId,
    content,
    isEdited,
    createdBy,
    authorName,
    mentionedUserName,
    createdAt,
    updatedAt,
    nestedReplies,
  ];
}
