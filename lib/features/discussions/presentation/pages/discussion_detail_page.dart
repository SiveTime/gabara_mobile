import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/reply_model.dart';
import '../providers/discussion_provider.dart';
import '../widgets/status_badge.dart';
import '../widgets/mention_text.dart';
import '../widgets/reply_input.dart';
import '../widgets/scrollable_reply_thread.dart';

/// Halaman detail diskusi dengan replies
class DiscussionDetailPage extends StatefulWidget {
  final String discussionId;
  final bool isMentor;

  const DiscussionDetailPage({
    super.key,
    required this.discussionId,
    this.isMentor = false,
  });

  @override
  State<DiscussionDetailPage> createState() => _DiscussionDetailPageState();
}

class _DiscussionDetailPageState extends State<DiscussionDetailPage> {
  bool _isSubmitting = false;
  bool _useHorizontalView = false; // Toggle for horizontal scroll view

  @override
  void initState() {
    super.initState();
    _loadDiscussion();
  }

  void _loadDiscussion() {
    context.read<DiscussionProvider>().loadDiscussionDetail(
      widget.discussionId,
    );
  }

  Future<void> _handleToggleStatus() async {
    final provider = context.read<DiscussionProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Consumer<DiscussionProvider>(
          builder: (context, provider, _) {
            final isClosed = provider.currentDiscussion?.isClosed ?? false;
            return Text(
              isClosed
                  ? 'Apakah Anda yakin ingin membuka diskusi ini?'
                  : 'Apakah Anda yakin ingin menutup diskusi ini?',
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await provider.toggleDiscussionStatus(
        widget.discussionId,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status diskusi berhasil diubah'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteDiscussion() async {
    final provider = context.read<DiscussionProvider>();
    final discussion = provider.currentDiscussion;

    if (discussion == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Diskusi'),
        content: Text(
          'Apakah Anda yakin ingin menghapus diskusi "${discussion.title}"?\n\nSemua balasan juga akan dihapus. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await provider.deleteDiscussion(widget.discussionId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Diskusi berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Go back to list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Gagal menghapus diskusi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleSubmitReply(String content) async {
    if (content.trim().isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<DiscussionProvider>();
      await provider.createReply(
        discussionId: widget.discussionId,
        content: content,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim balasan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Diskusi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Consumer<DiscussionProvider>(
            builder: (context, provider, _) {
              final discussion = provider.currentDiscussion;
              if (discussion == null) return const SizedBox();

              // Show menu for creator or mentor
              final isCreator = discussion.createdBy == provider.currentUserId;
              if (isCreator || widget.isMentor) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'toggle') {
                      _handleToggleStatus();
                    } else if (value == 'delete') {
                      _handleDeleteDiscussion();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            discussion.isClosed ? Icons.lock_open : Icons.lock,
                            size: 20,
                            color: discussion.isClosed
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            discussion.isClosed
                                ? 'Buka Diskusi'
                                : 'Tutup Diskusi',
                          ),
                        ],
                      ),
                    ),
                    if (isCreator) // Only creator can delete
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Hapus Diskusi',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                  ],
                  icon: const Icon(Icons.more_vert),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: Consumer<DiscussionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final discussion = provider.currentDiscussion;
          if (discussion == null) {
            return const Center(child: Text('Diskusi tidak ditemukan'));
          }

          return Column(
            children: [
              // Offline indicator
              if (provider.isOffline)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  color: Colors.orange.shade100,
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_off,
                        size: 16,
                        color: Colors.orange.shade800,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mode offline - tidak dapat membalas',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Discussion content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _loadDiscussion(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Discussion header
                        _buildDiscussionHeader(discussion, provider),
                        const SizedBox(height: 16),
                        // Discussion content
                        Text(
                          discussion.content,
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 24),
                        // Replies section
                        _buildRepliesSection(provider),
                      ],
                    ),
                  ),
                ),
              ),
              // Reply input (student only, if discussion is open and online)
              if (!widget.isMentor &&
                  !discussion.isClosed &&
                  !provider.isOffline)
                ReplyInput(
                  replyingToName: provider.replyingToName,
                  isLoading: _isSubmitting,
                  onSubmit: _handleSubmitReply,
                  onCancel: () => provider.clearReplyTarget(),
                )
              else if (discussion.isClosed)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Diskusi ini telah ditutup',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDiscussionHeader(discussion, DiscussionProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey.shade200,
          child: Text(
            discussion.creatorInitials ?? 'U',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                discussion.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'oleh ${discussion.creatorName ?? 'Unknown'} • ${_formatDateTime(discussion.createdAt)}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              StatusBadge(isClosed: discussion.isClosed),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRepliesSection(DiscussionProvider provider) {
    final hasDeepReplies = _hasDeepNesting(provider.replies);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with view toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Balasan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            // Show toggle only if there are deep nested replies
            if (hasDeepReplies)
              Row(
                children: [
                  Text(
                    'Tampilan:',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 8),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('Vertikal', style: TextStyle(fontSize: 12)),
                        icon: Icon(Icons.view_list, size: 16),
                      ),
                      ButtonSegment<bool>(
                        value: true,
                        label: Text(
                          'Horizontal',
                          style: TextStyle(fontSize: 12),
                        ),
                        icon: Icon(Icons.view_column, size: 16),
                      ),
                    ],
                    selected: {_useHorizontalView},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() {
                        _useHorizontalView = newSelection.first;
                      });
                    },
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Replies content
        if (provider.replies.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Belum ada balasan',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
          )
        else if (_useHorizontalView && hasDeepReplies)
          // Horizontal scrollable view for deep threads
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tampilan horizontal untuk thread panjang. Scroll ke kanan untuk melihat balasan lanjutan.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ScrollableReplyThread(
                replies: provider.replies,
                provider: provider,
                isMentor: widget.isMentor,
                canReply:
                    !widget.isMentor &&
                    !(provider.currentDiscussion?.isClosed ?? true),
              ),
            ],
          )
        else
          // Standard vertical view with smart nesting
          ...provider.replies.map(
            (reply) => _buildReplyItem(reply, provider, nestLevel: 0),
          ),
      ],
    );
  }

  /// Check if replies have deep nesting (more than 2 levels)
  bool _hasDeepNesting(List<ReplyModel> replies, {int currentLevel = 0}) {
    if (currentLevel >= 2) return true;

    for (final reply in replies) {
      if (reply.nestedReplies.isNotEmpty) {
        if (_hasDeepNesting(
          reply.nestedReplies.cast<ReplyModel>(),
          currentLevel: currentLevel + 1,
        )) {
          return true;
        }
      }
    }
    return false;
  }

  Widget _buildReplyItem(
    ReplyModel reply,
    DiscussionProvider provider, {
    int nestLevel = 0,
    String? parentAuthor,
  }) {
    // More aggressive overflow detection for vertical view
    final screenWidth = MediaQuery.of(context).size.width;
    final indentWidth = (nestLevel * 40.0) + (nestLevel > 0 ? 12.0 : 0.0);

    // Trigger horizontal scroll earlier - at 50% screen width or level 3+
    final willOverflow = indentWidth > (screenWidth * 0.5) || nestLevel >= 3;

    // If will overflow, use horizontal scroll
    if (willOverflow) {
      return _buildHorizontalScrollReply(
        reply,
        provider,
        nestLevel,
        parentAuthor,
      );
    }

    // Normal vertical nesting with proper constraints
    return _buildVerticalReply(reply, provider, nestLevel, parentAuthor);
  }

  /// Build horizontal scrollable reply for overflow prevention
  Widget _buildHorizontalScrollReply(
    ReplyModel reply,
    DiscussionProvider provider,
    int nestLevel,
    String? parentAuthor,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced overflow indicator with gradient background
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade50, Colors.orange.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.shade300, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.swipe_left_outlined,
                    size: 18,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thread Panjang Terdeteksi',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Scroll horizontal untuk navigasi yang lebih baik →',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Horizontal scrollable content with enhanced styling
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 320, // Increased height for better content display
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics:
                    const BouncingScrollPhysics(), // More natural scrolling
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildHorizontalReplyChain(
                      reply,
                      provider,
                      nestLevel,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build vertical reply (normal nesting)
  Widget _buildVerticalReply(
    ReplyModel reply,
    DiscussionProvider provider,
    int nestLevel,
    String? parentAuthor,
  ) {
    final isNested = nestLevel > 0;
    final shouldFlatten = nestLevel >= 2;

    return Container(
      margin: EdgeInsets.only(
        left: shouldFlatten ? 40 : (isNested ? 40 : 0),
        top: 8,
        bottom: 8,
      ),
      decoration: isNested
          ? BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: shouldFlatten
                      ? _getLevelColor(nestLevel)
                      : Colors.grey.shade300,
                  width: shouldFlatten ? 3 : 2,
                ),
              ),
            )
          : null,
      child: Padding(
        padding: EdgeInsets.only(left: isNested ? 12 : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced parent context for flattened deep replies
            if (shouldFlatten && parentAuthor != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getLevelColor(nestLevel).withValues(alpha: 0.1),
                      _getLevelColor(nestLevel).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getLevelColor(nestLevel).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _getLevelColor(nestLevel).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.reply_rounded,
                        size: 14,
                        color: _getLevelColor(nestLevel),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Membalas $parentAuthor',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getLevelColor(nestLevel),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            _buildReplyContent(reply, provider, nestLevel),

            // Nested replies (only if not overflowing)
            if (reply.nestedReplies.isNotEmpty)
              ...reply.nestedReplies.map(
                (nested) => _buildReplyItem(
                  nested as ReplyModel,
                  provider,
                  nestLevel: nestLevel + 1,
                  parentAuthor: nestLevel >= 1 ? reply.authorName : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build horizontal chain of replies
  List<Widget> _buildHorizontalReplyChain(
    ReplyModel reply,
    DiscussionProvider provider,
    int startLevel,
  ) {
    List<Widget> chain = [];

    // Flatten all nested replies into horizontal chain
    void addReplyToChain(ReplyModel currentReply, int level, String? parent) {
      chain.add(
        Container(
          width: 280, // Fixed width for each reply card
          margin: const EdgeInsets.only(right: 16),
          child: _buildReplyCard(currentReply, provider, level, parent),
        ),
      );

      // Add nested replies to chain
      for (final nested in currentReply.nestedReplies) {
        addReplyToChain(
          nested as ReplyModel,
          level + 1,
          currentReply.authorName,
        );
      }
    }

    addReplyToChain(reply, startLevel, null);
    return chain;
  }

  /// Build reply card for horizontal scroll
  Widget _buildReplyCard(
    ReplyModel reply,
    DiscussionProvider provider,
    int nestLevel,
    String? parentAuthor,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      constraints: const BoxConstraints(
        maxHeight: 280, // Optimized height
        maxWidth: 300, // Slightly wider for better readability
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: nestLevel > 0
              ? _getLevelColor(nestLevel)
              : Colors.grey.shade300,
          width: nestLevel > 0 ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: nestLevel > 0
                ? _getLevelColor(nestLevel).withValues(alpha: 0.1)
                : Colors.transparent,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Enhanced parent context for nested replies
          if (parentAuthor != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getLevelColor(nestLevel).withValues(alpha: 0.1),
                    _getLevelColor(nestLevel).withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getLevelColor(nestLevel).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _getLevelColor(nestLevel).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.reply_rounded,
                      size: 14,
                      color: _getLevelColor(nestLevel),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Membalas $parentAuthor',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getLevelColor(nestLevel),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Content with flexible height and proper constraints
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 180, // Increased content height
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _buildReplyContent(reply, provider, nestLevel),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get color based on nesting level for better visual hierarchy
  Color _getLevelColor(int level) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[level % colors.length];
  }

  /// Build reply content (shared between vertical and horizontal)
  Widget _buildReplyContent(
    ReplyModel reply,
    DiscussionProvider provider,
    int nestLevel,
  ) {
    final discussion = provider.currentDiscussion;
    final canReply = !widget.isMentor && !(discussion?.isClosed ?? true);
    final isReplying = provider.replyingToId == reply.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: nestLevel > 0
              ? _getLevelColor(nestLevel).withValues(alpha: 0.3)
              : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Enhanced header
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade100, Colors.grey.shade200],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.transparent,
                  child: Text(
                    reply.authorInitials ?? 'U',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            reply.authorName ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Enhanced level indicator
                        if (nestLevel > 1)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getLevelColor(
                                    nestLevel,
                                  ).withValues(alpha: 0.2),
                                  _getLevelColor(
                                    nestLevel,
                                  ).withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getLevelColor(
                                  nestLevel,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'L${nestLevel + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                color: _getLevelColor(nestLevel),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(reply.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Enhanced content with proper constraints
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: MentionText(
              text: reply.displayContent,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
              mentionedName: reply.mentionedUserName,
            ),
          ),

          const SizedBox(height: 12),

          // Enhanced actions
          if (canReply)
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: isReplying
                    ? () => provider.clearReplyTarget()
                    : () => provider.setReplyTarget(reply.id, reply.authorName),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  backgroundColor: isReplying
                      ? Colors.grey.shade100
                      : Colors.blue.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isReplying
                          ? Colors.grey.shade300
                          : Colors.blue.shade200,
                    ),
                  ),
                ),
                icon: Icon(
                  isReplying ? Icons.close_rounded : Icons.reply_rounded,
                  size: 16,
                  color: isReplying
                      ? Colors.grey.shade600
                      : Colors.blue.shade700,
                ),
                label: Text(
                  isReplying ? 'Batal' : 'Balas',
                  style: TextStyle(
                    color: isReplying
                        ? Colors.grey.shade600
                        : Colors.blue.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy, HH.mm.ss').format(date);
  }
}
