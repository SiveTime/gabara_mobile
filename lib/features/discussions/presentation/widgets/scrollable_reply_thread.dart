// lib/features/discussions/presentation/widgets/scrollable_reply_thread.dart
// Scrollable horizontal reply thread for deep nested discussions

import 'package:flutter/material.dart';
import '../../data/models/reply_model.dart';
import '../providers/discussion_provider.dart';
import 'mention_text.dart';
import 'package:intl/intl.dart';

/// Widget untuk menampilkan thread reply yang dapat di-scroll horizontal
/// untuk mengatasi masalah nested reply yang terlalu dalam
class ScrollableReplyThread extends StatelessWidget {
  final List<ReplyModel> replies;
  final DiscussionProvider provider;
  final bool isMentor;
  final bool canReply;

  const ScrollableReplyThread({
    super.key,
    required this.replies,
    required this.provider,
    required this.isMentor,
    required this.canReply,
  });

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) return const SizedBox.shrink();

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 400, // Fixed height for horizontal scroll
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildThreadColumns(replies, 0),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildThreadColumns(List<ReplyModel> replies, int level) {
    List<Widget> columns = [];

    for (int i = 0; i < replies.length; i++) {
      final reply = replies[i];

      // Create column for current reply with proper constraints
      columns.add(
        Container(
          width: 280, // Fixed width per column
          margin: const EdgeInsets.only(right: 16),
          child: _buildReplyCard(reply, level),
        ),
      );

      // Add nested replies recursively as separate columns
      if (reply.nestedReplies.isNotEmpty) {
        columns.addAll(
          _buildThreadColumns(
            reply.nestedReplies.cast<ReplyModel>(),
            level + 1,
          ),
        );
      }
    }

    return columns;
  }

  Widget _buildReplyCard(ReplyModel reply, int level) {
    final isReplying = provider.replyingToId == reply.id;

    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(
        maxHeight: 380, // Increased height for better content display
        maxWidth: 300, // Slightly wider
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: level == 0 ? Colors.grey.shade300 : _getLevelColor(level),
          width: level == 0 ? 1.5 : 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: level > 0
                ? _getLevelColor(level).withValues(alpha: 0.1)
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
          // Enhanced header with level indicator
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
                        Expanded(
                          child: Text(
                            reply.authorName ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (level > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getLevelColor(level).withValues(alpha: 0.2),
                                  _getLevelColor(level).withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getLevelColor(
                                  level,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'L${level + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                color: _getLevelColor(level),
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

          // Content with flexible height and enhanced styling
          Flexible(
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 220, // Increased content height
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
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
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Enhanced actions with better styling
          if (canReply)
            Container(
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

  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy, HH.mm.ss').format(date);
  }
}
