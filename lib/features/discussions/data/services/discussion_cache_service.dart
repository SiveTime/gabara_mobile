import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/discussion_model.dart';
import '../models/reply_model.dart';

/// Service untuk caching discussions secara lokal
class DiscussionCacheService {
  static const String _discussionsKey = 'cached_discussions';
  static const String _repliesKeyPrefix = 'cached_replies_';
  static const String _lastSyncKey = 'discussions_last_sync';
  static const String _pendingDiscussionsKey = 'pending_discussions';

  /// Get fresh SharedPreferences instance every time to ensure data is current
  Future<SharedPreferences> get prefs async {
    // Always get fresh instance to ensure we read latest data
    return await SharedPreferences.getInstance();
  }

  /// Cache discussions untuk class tertentu
  Future<void> cacheDiscussions(
    String classId,
    List<DiscussionModel> discussions,
  ) async {
    try {
      final p = await prefs;
      final key = '${_discussionsKey}_$classId';
      final jsonList = discussions.map((d) => _discussionToJson(d)).toList();
      final jsonString = jsonEncode(jsonList);
      final success = await p.setString(key, jsonString);
      await p.setString(
        '${_lastSyncKey}_$classId',
        DateTime.now().toIso8601String(),
      );
      debugPrint(
        'Cache save success: $success, ${discussions.length} discussions with key: $key',
      );

      // Verify save
      final verify = p.getString(key);
      debugPrint(
        'Cache verify: ${verify != null ? 'OK (${verify.length} chars)' : 'FAILED'}',
      );
    } catch (e) {
      debugPrint('Error caching discussions: $e');
    }
  }

  /// Get cached discussions untuk class tertentu
  Future<List<DiscussionModel>> getCachedDiscussions(String classId) async {
    try {
      final p = await prefs;
      // Reload to get fresh data from disk
      await p.reload();

      final key = '${_discussionsKey}_$classId';
      final jsonString = p.getString(key);
      debugPrint(
        'Getting cached discussions with key: $key, found: ${jsonString != null}, length: ${jsonString?.length ?? 0}',
      );
      if (jsonString == null || jsonString.isEmpty) return [];

      final jsonList = jsonDecode(jsonString) as List;
      final discussions = jsonList
          .map((json) => DiscussionModel.fromJson(json as Map<String, dynamic>))
          .toList();
      debugPrint('Parsed ${discussions.length} discussions from cache');
      return discussions;
    } catch (e) {
      debugPrint('Error getting cached discussions: $e');
      return [];
    }
  }

  /// Cache replies untuk discussion tertentu
  Future<void> cacheReplies(
    String discussionId,
    List<ReplyModel> replies,
  ) async {
    try {
      final p = await prefs;
      final key = '$_repliesKeyPrefix$discussionId';
      final jsonList = replies.map((r) => _replyToJson(r)).toList();
      await p.setString(key, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error caching replies: $e');
    }
  }

  /// Get cached replies untuk discussion tertentu
  Future<List<ReplyModel>> getCachedReplies(String discussionId) async {
    try {
      final p = await prefs;
      final key = '$_repliesKeyPrefix$discussionId';
      final jsonString = p.getString(key);
      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => ReplyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting cached replies: $e');
      return [];
    }
  }

  /// Cache single discussion
  Future<void> cacheSingleDiscussion(DiscussionModel discussion) async {
    try {
      final p = await prefs;
      final key = 'cached_discussion_${discussion.id}';
      await p.setString(key, jsonEncode(_discussionToJson(discussion)));
    } catch (e) {
      debugPrint('Error caching single discussion: $e');
    }
  }

  /// Get cached single discussion
  Future<DiscussionModel?> getCachedDiscussion(String discussionId) async {
    try {
      final p = await prefs;
      final key = 'cached_discussion_$discussionId';
      final jsonString = p.getString(key);
      if (jsonString == null) return null;

      return DiscussionModel.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('Error getting cached discussion: $e');
      return null;
    }
  }

  /// Get last sync time
  Future<DateTime?> getLastSyncTime(String classId) async {
    try {
      final p = await prefs;
      final timeString = p.getString('${_lastSyncKey}_$classId');
      if (timeString == null) return null;
      return DateTime.parse(timeString);
    } catch (e) {
      return null;
    }
  }

  /// Clear all cache
  Future<void> clearCache() async {
    try {
      final p = await prefs;
      final keys = p.getKeys();
      for (final key in keys) {
        if (key.startsWith(_discussionsKey) ||
            key.startsWith(_repliesKeyPrefix) ||
            key.startsWith(_lastSyncKey) ||
            key.startsWith('cached_discussion_') ||
            key.startsWith(_pendingDiscussionsKey)) {
          await p.remove(key);
        }
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  // ============================================
  // PENDING DISCUSSIONS (Offline Queue)
  // ============================================

  /// Save pending discussion to be synced when online
  Future<void> savePendingDiscussion(
    Map<String, dynamic> discussionData,
  ) async {
    try {
      final p = await prefs;
      final pending = await getPendingDiscussions();
      pending.add(discussionData);
      await p.setString(_pendingDiscussionsKey, jsonEncode(pending));
      debugPrint('Saved pending discussion, total: ${pending.length}');
    } catch (e) {
      debugPrint('Error saving pending discussion: $e');
    }
  }

  /// Get all pending discussions
  Future<List<Map<String, dynamic>>> getPendingDiscussions() async {
    try {
      final p = await prefs;
      final jsonString = p.getString(_pendingDiscussionsKey);
      if (jsonString == null) return [];

      final list = jsonDecode(jsonString) as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('Error getting pending discussions: $e');
      return [];
    }
  }

  /// Remove a pending discussion after successful sync
  Future<void> removePendingDiscussion(String tempId) async {
    try {
      final p = await prefs;
      final pending = await getPendingDiscussions();
      pending.removeWhere((d) => d['temp_id'] == tempId);
      await p.setString(_pendingDiscussionsKey, jsonEncode(pending));
    } catch (e) {
      debugPrint('Error removing pending discussion: $e');
    }
  }

  /// Clear all pending discussions
  Future<void> clearPendingDiscussions() async {
    try {
      final p = await prefs;
      await p.remove(_pendingDiscussionsKey);
    } catch (e) {
      debugPrint('Error clearing pending discussions: $e');
    }
  }

  /// Convert DiscussionModel to JSON map for caching
  /// Format matches what fromJson expects
  Map<String, dynamic> _discussionToJson(DiscussionModel d) {
    return {
      'id': d.id,
      'class_id': d.classId,
      'title': d.title,
      'content': d.content,
      'is_pinned': d.isPinned,
      'is_closed': d.isClosed,
      'view_count': d.viewCount,
      'created_by': d.createdBy,
      'created_at': d.createdAt.toIso8601String(),
      'updated_at': d.updatedAt.toIso8601String(),
      'reply_count': d.replyCount,
      // Store in format that fromJson expects
      'profiles': d.creatorName != null ? {'full_name': d.creatorName} : null,
      'class_name': d.className,
    };
  }

  /// Convert ReplyModel to JSON map for caching
  /// Format matches what fromJson expects
  Map<String, dynamic> _replyToJson(ReplyModel r) {
    return {
      'id': r.id,
      'discussion_id': r.discussionId,
      'parent_reply_id': r.parentReplyId,
      'content': r.content,
      'is_edited': r.isEdited,
      'created_by': r.createdBy,
      'created_at': r.createdAt.toIso8601String(),
      'updated_at': r.updatedAt.toIso8601String(),
      // Store in format that fromJson expects
      'profiles': r.authorName != null ? {'full_name': r.authorName} : null,
      'mentioned_user_name': r.mentionedUserName,
    };
  }
}
