import '../../domain/entities/discussion_entity.dart';

/// Model untuk Discussion dengan serialization
class DiscussionModel extends DiscussionEntity {
  const DiscussionModel({
    required super.id,
    required super.classId,
    required super.title,
    required super.content,
    super.isPinned,
    super.isClosed,
    super.viewCount,
    required super.createdBy,
    super.creatorName,
    super.creatorInitials,
    super.className,
    required super.createdAt,
    required super.updatedAt,
    super.replyCount,
  });

  /// Create from JSON (Supabase response)
  factory DiscussionModel.fromJson(Map<String, dynamic> json) {
    final creatorName =
        json['profiles']?['full_name'] as String? ??
        json['creator_name'] as String?;

    return DiscussionModel(
      id: json['id'] as String,
      classId: json['class_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      isPinned: json['is_pinned'] as bool? ?? false,
      isClosed: json['is_closed'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
      createdBy: json['created_by'] as String,
      creatorName: creatorName,
      creatorInitials: _getInitials(creatorName),
      className:
          json['classes']?['name'] as String? ?? json['class_name'] as String?,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      replyCount: json['reply_count'] as int? ?? 0,
    );
  }

  /// Convert to JSON for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'title': title,
      'content': content,
      'is_pinned': isPinned,
      'is_closed': isClosed,
      'created_by': createdBy,
    };
  }

  /// Convert to JSON for insert (without id)
  Map<String, dynamic> toInsertJson() {
    return {
      'class_id': classId,
      'title': title,
      'content': content,
      'is_pinned': isPinned,
      'is_closed': isClosed,
      'created_by': createdBy,
    };
  }

  /// Create a copy with updated fields
  DiscussionModel copyWith({
    String? id,
    String? classId,
    String? title,
    String? content,
    bool? isPinned,
    bool? isClosed,
    int? viewCount,
    String? createdBy,
    String? creatorName,
    String? creatorInitials,
    String? className,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? replyCount,
  }) {
    return DiscussionModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      title: title ?? this.title,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      isClosed: isClosed ?? this.isClosed,
      viewCount: viewCount ?? this.viewCount,
      createdBy: createdBy ?? this.createdBy,
      creatorName: creatorName ?? this.creatorName,
      creatorInitials: creatorInitials ?? this.creatorInitials,
      className: className ?? this.className,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replyCount: replyCount ?? this.replyCount,
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

  /// Get initials from name (e.g., "Dian Maharanis" -> "DM")
  static String? _getInitials(String? name) {
    if (name == null || name.isEmpty) return null;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }
}
