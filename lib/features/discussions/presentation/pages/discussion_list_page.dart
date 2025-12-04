import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/discussion_provider.dart';
import '../widgets/status_badge.dart';
import 'create_discussion_page.dart';
import 'discussion_detail_page.dart';

/// Halaman daftar diskusi (untuk Student dan Mentor)
class DiscussionListPage extends StatefulWidget {
  final String classId;
  final String className;
  final bool isMentor;

  const DiscussionListPage({
    super.key,
    required this.classId,
    required this.className,
    this.isMentor = false,
  });

  @override
  State<DiscussionListPage> createState() => _DiscussionListPageState();
}

class _DiscussionListPageState extends State<DiscussionListPage> {
  final String _filterStatus = 'all';
  final String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDiscussions();
    });
  }

  void _loadDiscussions() {
    final provider = context.read<DiscussionProvider>();
    // Always load - provider will handle caching
    provider.loadDiscussionsByClass(widget.classId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscussionProvider>(
      builder: (context, provider, child) {
        final filteredDiscussions = provider.filterByStatus(_filterStatus);
        final sortedDiscussions = provider.sortDiscussions(
          _sortBy,
          filteredDiscussions,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and create button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Forum Diskusi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Only show create button for students
                  if (!widget.isMentor)
                    OutlinedButton.icon(
                      onPressed: () => _navigateToCreate(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Buat Topik'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                ],
              ),
            ),

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
                        'Mode offline - menampilkan data tersimpan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Content
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : sortedDiscussions.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () async => _loadDiscussions(),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: sortedDiscussions.length,
                        itemBuilder: (context, index) {
                          final discussion = sortedDiscussions[index];
                          return _buildDiscussionItem(context, discussion);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDiscussionItem(BuildContext context, discussion) {
    final provider = context.read<DiscussionProvider>();
    final isCreator = discussion.createdBy == provider.currentUserId;
    final isPending = discussion.id.startsWith('pending_');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPending ? Colors.orange.shade300 : Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(context, discussion.id),
        onLongPress: isCreator
            ? () => _showDeleteDialog(context, discussion)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: isPending
                    ? Colors.orange.shade100
                    : Colors.grey.shade200,
                child: isPending
                    ? Icon(
                        Icons.schedule,
                        color: Colors.orange.shade700,
                        size: 20,
                      )
                    : Text(
                        discussion.creatorInitials ?? 'U',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            discussion.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(isClosed: discussion.isClosed),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Creator info
                    Text(
                      'oleh ${discussion.creatorName ?? 'Unknown'} • ${_formatDate(discussion.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Content preview
                    Text(
                      discussion.content,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Belum ada diskusi',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          if (!widget.isMentor) ...[
            const SizedBox(height: 8),
            Text(
              'Mulai diskusi pertama!',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateDiscussionPage(
          classId: widget.classId,
          className: widget.className,
        ),
      ),
    ).then((_) => _loadDiscussions());
  }

  void _navigateToDetail(BuildContext context, String discussionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiscussionDetailPage(
          discussionId: discussionId,
          isMentor: widget.isMentor,
        ),
      ),
    ).then((_) => _loadDiscussions());
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hari ini';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, discussion) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Diskusi'),
        content: Text(
          'Apakah Anda yakin ingin menghapus diskusi "${discussion.title}"?\n\nSemua balasan juga akan dihapus.',
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
      final provider = context.read<DiscussionProvider>();
      final success = await provider.deleteDiscussion(discussion.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Diskusi berhasil dihapus'
                  : (provider.errorMessage ?? 'Gagal menghapus diskusi'),
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
