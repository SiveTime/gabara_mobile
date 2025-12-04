import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/reply_model.dart';
import 'mention_text.dart';

/// Widget card untuk menampilkan reply dengan nested structure
class ReplyCard extends StatelessWidget {
  final ReplyModel reply;
  final bool isNested;
  final bool canReply;
  final VoidCallback? onReply;
  final VoidCallback? onCancel;
  final bool isReplying;

  const ReplyCard({
    super.key,
    required this.reply,
    this.isNested = false,
    this.canReply = true,
    this.onReply,
    this.onCancel,
    this.isReplying = false,
  });

  @override
  Widget build(BuildContext context) {
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
            // Header: Avatar, Name, Date
            Row(
              children: [
                _buildAvatar(),
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
            // Content with @mention
            MentionText(
              text: reply.displayContent,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            // Actions
            if (canReply)
              Row(
                children: [
                  if (isReplying)
                    TextButton(
                      onPressed: onCancel,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: onReply,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Balas',
                        style: TextStyle(color: Colors.blue, fontSize: 13),
                      ),
                    ),
                ],
              ),
            // Nested replies
            if (reply.nestedReplies.isNotEmpty)
              ...reply.nestedReplies.map(
                (nested) => ReplyCard(
                  reply: nested as ReplyModel,
                  isNested: true,
                  canReply: canReply,
                  onReply: () {
                    // Handle nested reply
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
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
    );
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy, HH.mm.ss').format(date);
  }
}
