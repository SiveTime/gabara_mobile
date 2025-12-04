import 'package:flutter/foundation.dart';
import '../../data/models/discussion_model.dart';
import '../../data/models/reply_model.dart';
import '../../data/services/discussion_service.dart';
import '../../data/services/discussion_cache_service.dart';
import '../../../../core/services/connectivity_service.dart';

/// Provider untuk state management Forum Diskusi dengan offline support
class DiscussionProvider extends ChangeNotifier {
  final DiscussionService _discussionService;
  final DiscussionCacheService _cacheService;
  final ConnectivityService _connectivityService;

  DiscussionProvider(
    this._discussionService,
    this._cacheService,
    this._connectivityService,
  ) {
    // Listen to connectivity changes
    _connectivityService.addListener(_onConnectivityChanged);
  }

  // State
  List<DiscussionModel> _discussions = [];
  DiscussionModel? _currentDiscussion;
  List<ReplyModel> _replies = [];
  List<Map<String, dynamic>> _enrolledClasses = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _replyingToId;
  String? _replyingToName;
  bool _isOffline = false;
  String? _currentClassId;

  // Getters
  List<DiscussionModel> get discussions => _discussions;
  DiscussionModel? get currentDiscussion => _currentDiscussion;
  List<ReplyModel> get replies => _replies;
  List<Map<String, dynamic>> get enrolledClasses => _enrolledClasses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get replyingToId => _replyingToId;
  String? get replyingToName => _replyingToName;
  String? get currentUserId => _discussionService.currentUserId;
  bool get isOffline => _isOffline;

  void _onConnectivityChanged() {
    final wasOffline = _isOffline;
    _isOffline = !_connectivityService.isConnected;

    if (wasOffline && !_isOffline) {
      // Back online - sync pending and refresh data
      syncPendingDiscussions();
    }
    notifyListeners();
  }

  // ============================================
  // DISCUSSION METHODS
  // ============================================

  /// Load discussions for student (enrolled classes)
  Future<void> loadDiscussionsForStudent() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _discussions = await _discussionService.fetchDiscussionsForStudent();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load discussions for mentor (teaching classes)
  Future<void> loadDiscussionsForMentor() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _discussions = await _discussionService.fetchDiscussionsForMentor();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load discussions by class ID with offline support
  Future<void> loadDiscussionsByClass(String classId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentClassId = classId;
    notifyListeners();

    try {
      // ALWAYS load from cache first for instant display
      final cachedData = await _cacheService.getCachedDiscussions(classId);
      if (cachedData.isNotEmpty) {
        _discussions = cachedData;
        debugPrint('Loaded ${cachedData.length} discussions from cache first');
        _isLoading = false;
        notifyListeners(); // Show cached data immediately
      }

      // Then check connectivity and try to fetch fresh data
      final isConnected = await _connectivityService.checkConnectivity();
      _isOffline = !isConnected;

      if (isConnected) {
        _isLoading = true;
        notifyListeners();

        // Online - fetch from server
        final fetchedDiscussions = await _discussionService
            .fetchDiscussionsByClass(classId);

        // Only update and cache if fetch was successful
        if (fetchedDiscussions.isNotEmpty) {
          _discussions = fetchedDiscussions;
          debugPrint('Caching ${_discussions.length} fresh discussions');
          await _cacheService.cacheDiscussions(classId, _discussions);
        }
        // If fetch empty but cache has data, keep using cache
      } else {
        // Offline - already loaded from cache above
        if (_discussions.isEmpty) {
          _errorMessage =
              'Tidak ada koneksi internet dan tidak ada data tersimpan';
        }
      }
    } catch (e) {
      debugPrint('Error loadDiscussionsByClass: $e');
      // On error, keep using cached data (already loaded above)
      if (_discussions.isEmpty) {
        _errorMessage = 'Gagal memuat diskusi';
      }
      _isOffline = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load single discussion detail with replies (with offline support)
  Future<void> loadDiscussionDetail(String discussionId) async {
    _isLoading = true;
    _errorMessage = null;
    _replyingToId = null;
    _replyingToName = null;
    notifyListeners();

    try {
      final isConnected = await _connectivityService.checkConnectivity();
      _isOffline = !isConnected;

      if (isConnected) {
        // Online - fetch from server
        _currentDiscussion = await _discussionService.fetchDiscussionById(
          discussionId,
        );
        if (_currentDiscussion != null) {
          _replies = await _discussionService.fetchRepliesByDiscussion(
            discussionId,
          );
          // Cache the data
          await _cacheService.cacheSingleDiscussion(_currentDiscussion!);
          await _cacheService.cacheReplies(discussionId, _replies);
        }
      } else {
        // Offline - load from cache
        _currentDiscussion = await _cacheService.getCachedDiscussion(
          discussionId,
        );
        if (_currentDiscussion != null) {
          _replies = await _cacheService.getCachedReplies(discussionId);
        } else {
          _errorMessage =
              'Tidak ada koneksi internet dan tidak ada data tersimpan';
        }
      }
    } catch (e) {
      debugPrint('Error loadDiscussionDetail: $e');
      // Try to load from cache on error
      _currentDiscussion = await _cacheService.getCachedDiscussion(
        discussionId,
      );
      if (_currentDiscussion != null) {
        _replies = await _cacheService.getCachedReplies(discussionId);
        _isOffline = true;
      } else {
        _errorMessage = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new discussion (Student only) - supports offline with pending queue
  Future<DiscussionModel?> createDiscussion({
    required String classId,
    required String title,
    required String content,
    String? className,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final isConnected = await _connectivityService.checkConnectivity();
      final userId = _discussionService.currentUserId ?? '';
      final now = DateTime.now();

      if (isConnected) {
        // Online - create on server
        final discussion = DiscussionModel(
          id: '',
          classId: classId,
          title: title,
          content: content,
          createdBy: userId,
          createdAt: now,
          updatedAt: now,
        );

        final created = await _discussionService.createDiscussion(discussion);
        if (created != null) {
          _discussions.insert(0, created);
          await _cacheService.cacheDiscussions(classId, _discussions);
          notifyListeners();
        }
        return created;
      } else {
        // Offline - save to pending queue and show locally
        final tempId = 'pending_${now.millisecondsSinceEpoch}';

        // Create a temporary discussion for local display
        final pendingDiscussion = DiscussionModel(
          id: tempId,
          classId: classId,
          title: title,
          content: content,
          createdBy: userId,
          creatorName: 'Anda (Pending)',
          className: className,
          createdAt: now,
          updatedAt: now,
        );

        // Save to pending queue for later sync
        await _cacheService.savePendingDiscussion({
          'temp_id': tempId,
          'class_id': classId,
          'title': title,
          'content': content,
          'created_by': userId,
          'created_at': now.toIso8601String(),
        });

        // Add to local list
        _discussions.insert(0, pendingDiscussion);
        await _cacheService.cacheDiscussions(classId, _discussions);

        _errorMessage = 'Diskusi akan dikirim saat online';
        notifyListeners();
        return pendingDiscussion;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sync pending discussions when back online
  Future<void> syncPendingDiscussions() async {
    final isConnected = await _connectivityService.checkConnectivity();
    if (!isConnected) return;

    final pending = await _cacheService.getPendingDiscussions();
    if (pending.isEmpty) return;

    debugPrint('Syncing ${pending.length} pending discussions');

    for (final data in pending) {
      try {
        final discussion = DiscussionModel(
          id: '',
          classId: data['class_id'] as String,
          title: data['title'] as String,
          content: data['content'] as String,
          createdBy: data['created_by'] as String,
          createdAt: DateTime.parse(data['created_at'] as String),
          updatedAt: DateTime.now(),
        );

        final created = await _discussionService.createDiscussion(discussion);
        if (created != null) {
          await _cacheService.removePendingDiscussion(
            data['temp_id'] as String,
          );
          debugPrint('Synced pending discussion: ${data['temp_id']}');
        }
      } catch (e) {
        debugPrint('Failed to sync pending discussion: $e');
      }
    }

    // Refresh the list
    if (_currentClassId != null) {
      await loadDiscussionsByClass(_currentClassId!);
    }
  }

  /// Toggle discussion status (open/close) - requires online
  Future<bool> toggleDiscussionStatus(String discussionId) async {
    // Check connectivity first
    final isConnected = await _connectivityService.checkConnectivity();
    if (!isConnected) {
      _errorMessage = 'Tidak dapat mengubah status saat offline';
      notifyListeners();
      return false;
    }

    try {
      bool currentIsClosed = false;
      if (_currentDiscussion != null &&
          _currentDiscussion!.id == discussionId) {
        currentIsClosed = _currentDiscussion!.isClosed;
      } else {
        final found = _discussions.where((d) => d.id == discussionId);
        if (found.isNotEmpty) {
          currentIsClosed = found.first.isClosed;
        }
      }

      final newStatus = !currentIsClosed;
      final updated = await _discussionService.updateDiscussionStatus(
        discussionId,
        newStatus,
      );

      if (updated != null) {
        if (_currentDiscussion?.id == discussionId) {
          _currentDiscussion = updated;
          await _cacheService.cacheSingleDiscussion(updated);
        }

        final index = _discussions.indexWhere((d) => d.id == discussionId);
        if (index != -1) {
          _discussions = List.from(_discussions);
          _discussions[index] = updated;
          if (_currentClassId != null) {
            await _cacheService.cacheDiscussions(
              _currentClassId!,
              _discussions,
            );
          }
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error toggleDiscussionStatus: $e');
      notifyListeners();
      return false;
    }
  }

  /// Delete discussion - requires online
  Future<bool> deleteDiscussion(String discussionId) async {
    final isConnected = await _connectivityService.checkConnectivity();
    if (!isConnected) {
      _errorMessage = 'Tidak dapat menghapus saat offline';
      notifyListeners();
      return false;
    }

    try {
      await _discussionService.deleteDiscussion(discussionId);
      _discussions.removeWhere((d) => d.id == discussionId);
      if (_currentDiscussion?.id == discussionId) {
        _currentDiscussion = null;
      }
      // Update cache
      if (_currentClassId != null) {
        await _cacheService.cacheDiscussions(_currentClassId!, _discussions);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // REPLY METHODS
  // ============================================

  void setReplyTarget(String? replyId, String? authorName) {
    _replyingToId = replyId;
    _replyingToName = authorName;
    notifyListeners();
  }

  void clearReplyTarget() {
    _replyingToId = null;
    _replyingToName = null;
    notifyListeners();
  }

  /// Create new reply - requires online
  Future<ReplyModel?> createReply({
    required String discussionId,
    required String content,
  }) async {
    final isConnected = await _connectivityService.checkConnectivity();
    if (!isConnected) {
      _errorMessage = 'Tidak dapat membalas saat offline';
      notifyListeners();
      return null;
    }

    try {
      final reply = await _discussionService.createReply(
        discussionId: discussionId,
        content: content,
        parentReplyId: _replyingToId,
      );

      if (reply != null) {
        _replies = await _discussionService.fetchRepliesByDiscussion(
          discussionId,
        );
        // Update cache
        await _cacheService.cacheReplies(discussionId, _replies);

        if (_currentDiscussion != null) {
          _currentDiscussion = _currentDiscussion!.copyWith(
            replyCount: _currentDiscussion!.replyCount + 1,
          );
          await _cacheService.cacheSingleDiscussion(_currentDiscussion!);
        }

        clearReplyTarget();
        notifyListeners();
      }
      return reply;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Delete reply - requires online
  Future<bool> deleteReply(String replyId) async {
    final isConnected = await _connectivityService.checkConnectivity();
    if (!isConnected) {
      _errorMessage = 'Tidak dapat menghapus saat offline';
      notifyListeners();
      return false;
    }

    try {
      await _discussionService.deleteReply(replyId);

      if (_currentDiscussion != null) {
        _replies = await _discussionService.fetchRepliesByDiscussion(
          _currentDiscussion!.id,
        );
        await _cacheService.cacheReplies(_currentDiscussion!.id, _replies);

        _currentDiscussion = _currentDiscussion!.copyWith(
          replyCount: _currentDiscussion!.replyCount - 1,
        );
        await _cacheService.cacheSingleDiscussion(_currentDiscussion!);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  Future<void> loadEnrolledClasses() async {
    try {
      _enrolledClasses = await _discussionService.getEnrolledClasses();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loadEnrolledClasses: $e');
    }
  }

  Future<void> loadMentorClasses() async {
    try {
      _enrolledClasses = await _discussionService.getMentorClasses();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loadMentorClasses: $e');
    }
  }

  Future<bool> isDiscussionCreator(String discussionId) async {
    return await _discussionService.isDiscussionCreator(discussionId);
  }

  Future<bool> isMentorOfDiscussion(String discussionId) async {
    return await _discussionService.isMentorOfDiscussion(discussionId);
  }

  List<DiscussionModel> filterByStatus(String? status) {
    if (status == null || status == 'all') {
      return _discussions;
    }
    if (status == 'open') {
      return _discussions.where((d) => !d.isClosed).toList();
    }
    if (status == 'closed') {
      return _discussions.where((d) => d.isClosed).toList();
    }
    return _discussions;
  }

  List<DiscussionModel> sortDiscussions(
    String sortBy,
    List<DiscussionModel> list,
  ) {
    final sorted = List<DiscussionModel>.from(list);
    switch (sortBy) {
      case 'newest':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case 'oldest':
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case 'most_replies':
        sorted.sort((a, b) => b.replyCount.compareTo(a.replyCount));
    }
    return sorted;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _discussions = [];
    _currentDiscussion = null;
    _replies = [];
    _enrolledClasses = [];
    _isLoading = false;
    _errorMessage = null;
    _replyingToId = null;
    _replyingToName = null;
    _isOffline = false;
    _currentClassId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivityService.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}
