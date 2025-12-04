import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/discussion_model.dart';
import '../models/reply_model.dart';

/// Service untuk operasi CRUD Discussion dan Reply
class DiscussionService {
  final SupabaseClient _supabaseClient;

  DiscussionService(this._supabaseClient);

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get profile by user ID
  Future<Map<String, dynamic>?> _getProfileByUserId(String userId) async {
    try {
      final response = await _supabaseClient
          .from('profiles')
          .select('full_name')
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Error _getProfileByUserId: $e');
      return null;
    }
  }

  /// Get class name by class ID
  Future<String?> _getClassNameById(String classId) async {
    try {
      final response = await _supabaseClient
          .from('classes')
          .select('name')
          .eq('id', classId)
          .maybeSingle();
      return response?['name'] as String?;
    } catch (e) {
      debugPrint('Error _getClassNameById: $e');
      return null;
    }
  }

  /// Get reply count for discussion
  Future<int> _getReplyCount(String discussionId) async {
    try {
      final response = await _supabaseClient
          .from('discussion_replies')
          .select('id')
          .eq('discussion_id', discussionId);
      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  // ============================================
  // DISCUSSION CRUD OPERATIONS
  // ============================================

  /// Create new discussion (Student only)
  Future<DiscussionModel?> createDiscussion(DiscussionModel discussion) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User tidak login');

      final data = <String, dynamic>{
        'class_id': discussion.classId,
        'title': discussion.title,
        'content': discussion.content,
        'is_pinned': discussion.isPinned,
        'is_closed': discussion.isClosed,
        'created_by': user.id,
      };

      final insertResponse = await _supabaseClient
          .from('discussions')
          .insert(data)
          .select('id')
          .single();

      final discussionId = insertResponse['id'] as String;
      return await fetchDiscussionById(discussionId);
    } catch (e) {
      debugPrint('Error createDiscussion: $e');
      rethrow;
    }
  }

  /// Fetch discussions by class ID - NO RELATIONSHIPS
  Future<List<DiscussionModel>> fetchDiscussionsByClass(String classId) async {
    try {
      // Fetch discussions without any joins
      final response = await _supabaseClient
          .from('discussions')
          .select(
            'id, class_id, title, content, is_pinned, is_closed, view_count, created_by, created_at, updated_at',
          )
          .eq('class_id', classId)
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false);

      // Get class name once
      final className = await _getClassNameById(classId);

      final discussions = <DiscussionModel>[];
      for (final item in response as List) {
        final data = Map<String, dynamic>.from(item as Map<String, dynamic>);

        // Get creator profile separately
        final profile = await _getProfileByUserId(data['created_by'] as String);
        data['profiles'] = profile;
        data['class_name'] = className;

        final discussion = DiscussionModel.fromJson(data);
        final count = await _getReplyCount(discussion.id);
        discussions.add(discussion.copyWith(replyCount: count));
      }

      return discussions;
    } catch (e) {
      debugPrint('Error fetchDiscussionsByClass: $e');
      return [];
    }
  }

  /// Fetch discussions for student (enrolled classes) - NO RELATIONSHIPS
  Future<List<DiscussionModel>> fetchDiscussionsForStudent() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User tidak login');

      // Get enrolled class IDs
      final enrollments = await _supabaseClient
          .from('class_enrollments')
          .select('class_id')
          .eq('user_id', user.id)
          .eq('status', 'active');

      final classIds = (enrollments as List)
          .map((e) => e['class_id'] as String)
          .toList();

      if (classIds.isEmpty) return [];

      // Fetch discussions without any joins
      final response = await _supabaseClient
          .from('discussions')
          .select(
            'id, class_id, title, content, is_pinned, is_closed, view_count, created_by, created_at, updated_at',
          )
          .inFilter('class_id', classIds)
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false);

      // Cache class names
      final classNames = <String, String?>{};

      final discussions = <DiscussionModel>[];
      for (final item in response as List) {
        final data = Map<String, dynamic>.from(item as Map<String, dynamic>);
        final itemClassId = data['class_id'] as String;

        // Get class name (cached)
        if (!classNames.containsKey(itemClassId)) {
          classNames[itemClassId] = await _getClassNameById(itemClassId);
        }

        // Get creator profile separately
        final profile = await _getProfileByUserId(data['created_by'] as String);
        data['profiles'] = profile;
        data['class_name'] = classNames[itemClassId];

        final discussion = DiscussionModel.fromJson(data);
        final count = await _getReplyCount(discussion.id);
        discussions.add(discussion.copyWith(replyCount: count));
      }

      return discussions;
    } catch (e) {
      debugPrint('Error fetchDiscussionsForStudent: $e');
      return [];
    }
  }

  /// Fetch discussions for mentor (teaching classes) - NO RELATIONSHIPS
  Future<List<DiscussionModel>> fetchDiscussionsForMentor() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User tidak login');

      // Get class IDs where user is tutor
      final classes = await _supabaseClient
          .from('classes')
          .select('id, name')
          .eq('tutor_id', user.id);

      final classIds = (classes as List).map((e) => e['id'] as String).toList();
      final classNames = <String, String?>{
        for (final c in classes as List)
          c['id'] as String: c['name'] as String?,
      };

      if (classIds.isEmpty) return [];

      // Fetch discussions without any joins
      final response = await _supabaseClient
          .from('discussions')
          .select(
            'id, class_id, title, content, is_pinned, is_closed, view_count, created_by, created_at, updated_at',
          )
          .inFilter('class_id', classIds)
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false);

      final discussions = <DiscussionModel>[];
      for (final item in response as List) {
        final data = Map<String, dynamic>.from(item as Map<String, dynamic>);
        final itemClassId = data['class_id'] as String;

        // Get creator profile separately
        final profile = await _getProfileByUserId(data['created_by'] as String);
        data['profiles'] = profile;
        data['class_name'] = classNames[itemClassId];

        final discussion = DiscussionModel.fromJson(data);
        final count = await _getReplyCount(discussion.id);
        discussions.add(discussion.copyWith(replyCount: count));
      }

      return discussions;
    } catch (e) {
      debugPrint('Error fetchDiscussionsForMentor: $e');
      return [];
    }
  }

  /// Fetch single discussion by ID - NO RELATIONSHIPS
  Future<DiscussionModel?> fetchDiscussionById(String discussionId) async {
    try {
      final response = await _supabaseClient
          .from('discussions')
          .select(
            'id, class_id, title, content, is_pinned, is_closed, view_count, created_by, created_at, updated_at',
          )
          .eq('id', discussionId)
          .maybeSingle();

      if (response == null) return null;

      final data = Map<String, dynamic>.from(response);

      // Get creator profile separately
      final profile = await _getProfileByUserId(data['created_by'] as String);
      data['profiles'] = profile;

      // Get class name separately
      final className = await _getClassNameById(data['class_id'] as String);
      data['class_name'] = className;

      final discussion = DiscussionModel.fromJson(data);
      final count = await _getReplyCount(discussionId);
      return discussion.copyWith(replyCount: count);
    } catch (e) {
      debugPrint('Error fetchDiscussionById: $e');
      return null;
    }
  }

  /// Update discussion status (open/close) - NO RELATIONSHIPS
  Future<DiscussionModel?> updateDiscussionStatus(
    String discussionId,
    bool isClosed,
  ) async {
    try {
      final response = await _supabaseClient
          .from('discussions')
          .update({
            'is_closed': isClosed,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', discussionId)
          .select(
            'id, class_id, title, content, is_pinned, is_closed, view_count, created_by, created_at, updated_at',
          )
          .single();

      final data = Map<String, dynamic>.from(response);

      // Get creator profile separately
      final profile = await _getProfileByUserId(data['created_by'] as String);
      data['profiles'] = profile;

      // Get class name separately
      final className = await _getClassNameById(data['class_id'] as String);
      data['class_name'] = className;

      return DiscussionModel.fromJson(data);
    } catch (e) {
      debugPrint('Error updateDiscussionStatus: $e');
      rethrow;
    }
  }

  /// Delete discussion
  Future<void> deleteDiscussion(String discussionId) async {
    try {
      await _supabaseClient.from('discussions').delete().eq('id', discussionId);
    } catch (e) {
      debugPrint('Error deleteDiscussion: $e');
      rethrow;
    }
  }

  // ============================================
  // REPLY CRUD OPERATIONS
  // ============================================

  /// Create new reply (Student only)
  Future<ReplyModel?> createReply({
    required String discussionId,
    required String content,
    String? parentReplyId,
  }) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User tidak login');

      final discussion = await fetchDiscussionById(discussionId);
      if (discussion == null) throw Exception('Diskusi tidak ditemukan');
      if (discussion.isClosed) throw Exception('Diskusi sudah ditutup');

      String? mentionedUserName;
      String finalContent = content;

      if (parentReplyId != null) {
        final parentReply = await _getReplyById(parentReplyId);
        if (parentReply != null && parentReply.authorName != null) {
          mentionedUserName = parentReply.authorName;
          final fullName = parentReply.authorName!;
          if (!content.startsWith('@$fullName')) {
            finalContent = '@$fullName $content';
          }
        }
      }

      final data = {
        'discussion_id': discussionId,
        'parent_reply_id': parentReplyId,
        'content': finalContent,
        'created_by': user.id,
      };

      final response = await _supabaseClient
          .from('discussion_replies')
          .insert(data)
          .select(
            'id, discussion_id, parent_reply_id, content, is_edited, created_by, created_at, updated_at',
          )
          .single();

      final replyData = Map<String, dynamic>.from(response);
      final profile = await _getProfileByUserId(user.id);
      replyData['profiles'] = profile;

      final reply = ReplyModel.fromJson(replyData);
      return reply.copyWith(mentionedUserName: mentionedUserName);
    } catch (e) {
      debugPrint('Error createReply: $e');
      rethrow;
    }
  }

  /// Fetch replies for discussion - NO RELATIONSHIPS
  Future<List<ReplyModel>> fetchRepliesByDiscussion(String discussionId) async {
    try {
      final response = await _supabaseClient
          .from('discussion_replies')
          .select(
            'id, discussion_id, parent_reply_id, content, is_edited, created_by, created_at, updated_at',
          )
          .eq('discussion_id', discussionId)
          .order('created_at', ascending: true);

      final allReplies = <ReplyModel>[];
      for (final item in response as List) {
        final data = Map<String, dynamic>.from(item as Map<String, dynamic>);
        final profile = await _getProfileByUserId(data['created_by'] as String);
        data['profiles'] = profile;
        allReplies.add(ReplyModel.fromJson(data));
      }

      return _buildNestedReplies(allReplies);
    } catch (e) {
      debugPrint('Error fetchRepliesByDiscussion: $e');
      return [];
    }
  }

  List<ReplyModel> _buildNestedReplies(List<ReplyModel> allReplies) {
    // First, set mentionedUserName for all replies that have parentReplyId
    final repliesWithMentions = allReplies.map((reply) {
      if (reply.parentReplyId != null) {
        // Find parent reply to get the mentioned name
        final parent = allReplies.firstWhere(
          (r) => r.id == reply.parentReplyId,
          orElse: () => reply,
        );
        return reply.copyWith(mentionedUserName: parent.authorName);
      }
      return reply;
    }).toList();

    // Then build nested structure
    final topLevel = repliesWithMentions
        .where((r) => r.parentReplyId == null)
        .toList();
    return topLevel.map((reply) {
      final nested = _findNestedReplies(reply.id, repliesWithMentions);
      return reply.copyWith(nestedReplies: nested);
    }).toList();
  }

  List<ReplyModel> _findNestedReplies(
    String parentId,
    List<ReplyModel> allReplies,
  ) {
    final children = allReplies
        .where((r) => r.parentReplyId == parentId)
        .toList();
    return children.map((child) {
      final nested = _findNestedReplies(child.id, allReplies);
      // mentionedUserName already set in _buildNestedReplies
      return child.copyWith(nestedReplies: nested);
    }).toList();
  }

  Future<ReplyModel?> _getReplyById(String replyId) async {
    try {
      final response = await _supabaseClient
          .from('discussion_replies')
          .select(
            'id, discussion_id, parent_reply_id, content, is_edited, created_by, created_at, updated_at',
          )
          .eq('id', replyId)
          .maybeSingle();

      if (response == null) return null;

      final data = Map<String, dynamic>.from(response);
      final profile = await _getProfileByUserId(data['created_by'] as String);
      data['profiles'] = profile;

      return ReplyModel.fromJson(data);
    } catch (e) {
      debugPrint('Error _getReplyById: $e');
      return null;
    }
  }

  Future<ReplyModel?> updateReply(String replyId, String content) async {
    try {
      final response = await _supabaseClient
          .from('discussion_replies')
          .update({
            'content': content,
            'is_edited': true,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', replyId)
          .select(
            'id, discussion_id, parent_reply_id, content, is_edited, created_by, created_at, updated_at',
          )
          .single();

      final data = Map<String, dynamic>.from(response);
      final profile = await _getProfileByUserId(data['created_by'] as String);
      data['profiles'] = profile;

      return ReplyModel.fromJson(data);
    } catch (e) {
      debugPrint('Error updateReply: $e');
      rethrow;
    }
  }

  Future<void> deleteReply(String replyId) async {
    try {
      await _supabaseClient
          .from('discussion_replies')
          .delete()
          .eq('id', replyId);
    } catch (e) {
      debugPrint('Error deleteReply: $e');
      rethrow;
    }
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  Future<List<Map<String, dynamic>>> getEnrolledClasses() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return [];

      // Get enrollments first
      final enrollments = await _supabaseClient
          .from('class_enrollments')
          .select('class_id')
          .eq('user_id', user.id)
          .eq('status', 'active');

      final classIds = (enrollments as List)
          .map((e) => e['class_id'] as String)
          .toList();
      if (classIds.isEmpty) return [];

      // Get class details separately
      final classes = await _supabaseClient
          .from('classes')
          .select('id, name')
          .inFilter('id', classIds);

      return (classes as List)
          .map(
            (c) => {
              'id': c['id'] as String,
              'name': c['name'] as String? ?? 'Unknown Class',
            },
          )
          .toList();
    } catch (e) {
      debugPrint('Error getEnrolledClasses: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMentorClasses() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return [];

      final response = await _supabaseClient
          .from('classes')
          .select('id, name')
          .eq('tutor_id', user.id)
          .eq('is_active', true);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error getMentorClasses: $e');
      return [];
    }
  }

  Future<bool> isDiscussionCreator(String discussionId) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return false;
      final discussion = await fetchDiscussionById(discussionId);
      return discussion?.createdBy == user.id;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isMentorOfDiscussion(String discussionId) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return false;

      final discussion = await fetchDiscussionById(discussionId);
      if (discussion == null) return false;

      final classData = await _supabaseClient
          .from('classes')
          .select('tutor_id')
          .eq('id', discussion.classId)
          .maybeSingle();

      return classData?['tutor_id'] == user.id;
    } catch (e) {
      return false;
    }
  }

  String? get currentUserId => _supabaseClient.auth.currentUser?.id;
}
