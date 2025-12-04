import '../../domain/entities/reply_entity.dart';

/// Model untuk Reply dengan serialization
class ReplyModel extends ReplyEntity {
  const ReplyModel({
    required super.id,
    required super.discussionId,
    super.parentReplyId,
    required super.content,
    super.isEdited,
    required super.createdBy,
    super.authorName,
    super.authorInitials,
    super.mentionedUserName,
    required super.createdAt,
    required super.updatedAt,
    super.nestedReplies,
  });

  /// Create from JSON (Supabase response)
  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    final authorName =
        json['profiles']?['full_name'] as String? ??
        json['author_name'] as String?;

    // Parse nested replies if present
    List<ReplyModel> nested = [];
    if (json['nested_replies'] != null) {
      nested = (json['nested_replies'] as List)
          .map((e) => ReplyModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return ReplyModel(
      id: json['id'] as String,
      discussionId: json['discussion_id'] as String,
      parentReplyId: json['parent_reply_id'] as String?,
      content: json['content'] as String,
      isEdited: json['is_edited'] as bool? ?? false,
      createdBy: json['created_by'] as String,
      authorName: authorName,
      authorInitials: _getInitials(authorName),
      mentionedUserName: json['mentioned_user_name'] as String?,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      nestedReplies: nested,
    );
  }

  /// Convert to JSON for Supabase insert
  Map<String, dynamic> toJson() {
    return {
      'discussion_id': discussionId,
      'parent_reply_id': parentReplyId,
      'content': content,
      'is_edited': isEdited,
      'created_by': createdBy,
    };
  }

  /// Convert to JSON for insert (without id)
  Map<String, dynamic> toInsertJson() {
    return {
      'discussion_id': discussionId,
      'parent_reply_id': parentReplyId,
      'content': content,
      'created_by': createdBy,
    };
  }

  /// Create a copy with updated fields
  ReplyModel copyWith({
    String? id,
    String? discussionId,
    String? parentReplyId,
    String? content,
    bool? isEdited,
    String? createdBy,
    String? authorName,
    String? authorInitials,
    String? mentionedUserName,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ReplyModel>? nestedReplies,
  }) {
    return ReplyModel(
      id: id ?? this.id,
      discussionId: discussionId ?? this.discussionId,
      parentReplyId: parentReplyId ?? this.parentReplyId,
      content: content ?? this.content,
      isEdited: isEdited ?? this.isEdited,
      createdBy: createdBy ?? this.createdBy,
      authorName: authorName ?? this.authorName,
      authorInitials: authorInitials ?? this.authorInitials,
      mentionedUserName: mentionedUserName ?? this.mentionedUserName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nestedReplies: nestedReplies?.cast<ReplyEntity>() ?? this.nestedReplies,
    );
  }

  /// Parse DateTime from string
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed.isUtc ? parsed.toLocal() : parsed;
      }
    }
    return DateTime.now();
  }

  /// Get initials from name (e.g., "Gilang Permana" -> "GP")
  static String? _getInitials(String? name) {
    if (name == null || name.isEmpty) return null;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }
}
