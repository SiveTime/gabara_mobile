// lib/features/assignments/presentation/pages/assignment_detail_page.dart
// Requirements: 6.1-6.6, 9.1-9.5

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/assignment_model.dart';
import '../../data/models/submission_model.dart';
import '../providers/assignment_provider.dart';
import 'create_assignment_page.dart';
import 'submission_detail_page.dart';

/// Page to display assignment details and submissions
/// **Validates: Requirements 6.1-6.6, 9.1-9.5**
class AssignmentDetailPage extends StatefulWidget {
  final String assignmentId;

  const AssignmentDetailPage({super.key, required this.assignmentId});

  @override
  State<AssignmentDetailPage> createState() => _AssignmentDetailPageState();
}

class _AssignmentDetailPageState extends State<AssignmentDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssignmentProvider>().loadAssignmentDetail(widget.assignmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(),
          ),
        ],
      ),
      body: Consumer<AssignmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final assignment = provider.currentAssignment;
          if (assignment == null) {
            return const Center(child: Text('Tugas tidak ditemukan'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAssignmentDetail(widget.assignmentId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAssignmentInfo(assignment),
                  const SizedBox(height: 24),
                  _buildSubmissionsSection(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildAssignmentInfo(AssignmentModel assignment) {
    final isExpired = assignment.deadline.isBefore(DateTime.now());
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    assignment.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildStatusBadge(isExpired),
              ],
            ),
            if (assignment.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                assignment.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
            const Divider(height: 24),
            _buildInfoRow(
              Icons.calendar_today,
              'Deadline',
              DateFormat('EEEE, dd MMMM yyyy HH:mm').format(assignment.deadline),
              isExpired ? Colors.red : null,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.star,
              'Nilai Maksimal',
              '${assignment.maxScore} poin',
              Colors.amber,
            ),
            if (assignment.attachmentUrl != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.attachment,
                'Lampiran',
                'Lihat lampiran',
                Colors.blue,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, [Color? color]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color ?? Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              Text(
                value,
                style: TextStyle(fontSize: 14, color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isExpired) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isExpired ? Colors.red[100] : Colors.green[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        isExpired ? 'Tertutup' : 'Aktif',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isExpired ? Colors.red[800] : Colors.green[800],
        ),
      ),
    );
  }

  Widget _buildSubmissionsSection(AssignmentProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Submissions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    _buildCountChip('Dinilai', provider.gradedCount, Colors.green),
                    const SizedBox(width: 8),
                    _buildCountChip('Menunggu', provider.pendingCount, Colors.orange),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (provider.submissions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Belum ada submission',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.submissions.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final submission = provider.submissions[index];
                  return _buildSubmissionTile(submission);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }

  Widget _buildSubmissionTile(SubmissionModel submission) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(submission.status),
        child: Text(
          submission.studentName?.substring(0, 1).toUpperCase() ?? '?',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(submission.studentName ?? 'Unknown'),
      subtitle: Text(
        submission.submittedAt != null
            ? DateFormat('dd MMM yyyy, HH:mm').format(submission.submittedAt!)
            : 'Belum dikumpulkan',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSubmissionStatusBadge(submission),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => _navigateToSubmissionDetail(submission.id),
    );
  }

  Widget _buildSubmissionStatusBadge(SubmissionModel submission) {
    String label;
    Color color;

    switch (submission.status) {
      case 'graded':
        label = '${submission.score?.toInt() ?? 0}';
        color = Colors.green;
        break;
      case 'submitted':
        label = 'Menunggu';
        color = Colors.orange;
        break;
      case 'late':
        label = 'Terlambat';
        color = Colors.red;
        break;
      default:
        label = 'Draft';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'graded':
        return Colors.green;
      case 'submitted':
        return Colors.orange;
      case 'late':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAssignmentPage(assignmentId: widget.assignmentId),
      ),
    ).then((_) {
      context.read<AssignmentProvider>().loadAssignmentDetail(widget.assignmentId);
    });
  }

  void _navigateToSubmissionDetail(String submissionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubmissionDetailPage(submissionId: submissionId),
      ),
    ).then((_) {
      context.read<AssignmentProvider>().loadAssignmentDetail(widget.assignmentId);
    });
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: const Text('Apakah Anda yakin ingin menghapus tugas ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context
                  .read<AssignmentProvider>()
                  .deleteAssignment(widget.assignmentId);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tugas berhasil dihapus')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
