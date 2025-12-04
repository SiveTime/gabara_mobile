import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/reply_model.dart';
import '../providers/discussion_provider.dart';
import '../widgets/status_badge.dart';
import '../widgets/mention_text.dart';
import '../widgets/reply_input.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Balasan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
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
        else
          ...provider.replies.map((reply) => _buildReplyItem(reply, provider)),
      ],
    );
  }

  Widget _buildReplyItem(
    ReplyModel reply,
    DiscussionProvider provider, {
    bool isNested = false,
  }) {
    final discussion = provider.currentDiscussion;
    final canReply = !widget.isMentor && !(discussion?.isClosed ?? true);
    final isReplying = provider.replyingToId == reply.id;

    return Container(
      margin: EdgeInsets.only(left: isNested ? 40 : 0, top: 8, bottom: 8),
      decoration: isNested
          ? BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey.shade300, width: 2),
              ),
            )
          : null,
      child: Padding(
        padding: EdgeInsets.only(left: isNested ? 12 : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.shade200,
                  child: Text(
                    reply.authorInitials ?? 'U',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reply.authorName ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatDateTime(reply.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Content - pass mentionedUserName untuk highlight nama lengkap
            MentionText(
              text: reply.displayContent,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              mentionedName: reply.mentionedUserName,
            ),
            const SizedBox(height: 8),
            // Actions
            if (canReply)
              TextButton(
                onPressed: isReplying
                    ? () => provider.clearReplyTarget()
                    : () => provider.setReplyTarget(reply.id, reply.authorName),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  isReplying ? 'Batal' : 'Balas',
                  style: TextStyle(
                    color: isReplying ? Colors.grey.shade600 : Colors.blue,
                    fontSize: 13,
                  ),
                ),
              ),
            // Nested replies
            if (reply.nestedReplies.isNotEmpty)
              ...reply.nestedReplies.map(
                (nested) => _buildReplyItem(
                  nested as ReplyModel,
                  provider,
                  isNested: true,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy, HH.mm.ss').format(date);
  }
}
