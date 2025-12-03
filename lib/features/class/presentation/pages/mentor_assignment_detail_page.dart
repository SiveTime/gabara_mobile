// lib/features/class/presentation/pages/mentor_assignment_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../assignments/data/models/assignment_model.dart';
import '../../../assignments/data/models/submission_model.dart';
import '../../../assignments/presentation/providers/assignment_provider.dart';
import '../widgets/class_assignments_list.dart';

/// Halaman detail tugas untuk mentor
class MentorAssignmentDetailPage extends StatefulWidget {
  final AssignmentModel assignment;
  final int assignmentNumber;

  const MentorAssignmentDetailPage({
    super.key,
    required this.assignment,
    this.assignmentNumber = 1,
  });

  @override
  State<MentorAssignmentDetailPage> createState() =>
      _MentorAssignmentDetailPageState();
}

class _MentorAssignmentDetailPageState
    extends State<MentorAssignmentDetailPage> {
  List<SubmissionModel> _submissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<AssignmentProvider>();
      final submissions =
          await provider.assignmentService.fetchSubmissions(widget.assignment.id);
      if (mounted) {
        setState(() {
          _submissions = submissions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isExpired = widget.assignment.deadline.isBefore(now);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Detail Tugas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editAssignment(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteAssignment(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSubmissions,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header card
                    _buildHeaderCard(isExpired),

                    // Submissions section
                    _buildSubmissionsSection(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderCard(bool isExpired) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with status badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Tugas ${widget.assignmentNumber} - ${widget.assignment.title}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusBadge(isExpired),
            ],
          ),
          const SizedBox(height: 16),

          // Tanggal Dibuka
          _buildDateRow(
            'Tanggal Dibuka:',
            widget.assignment.createdAt ?? DateTime.now(),
            Colors.green,
          ),
          const SizedBox(height: 8),

          // Tanggal Ditutup
          _buildDateRow(
            'Tanggal Ditutup:',
            widget.assignment.deadline,
            isExpired ? Colors.red : Colors.orange,
          ),
          const SizedBox(height: 20),

          // Deskripsi
          const Text(
            'Deskripsi Tugas:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.assignment.description.isNotEmpty
                ? widget.assignment.description
                : 'Tidak ada deskripsi',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),

          // Info row
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.star_outline,
                label: 'Nilai Min: ${widget.assignment.maxScore}',
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                icon: Icons.people_outline,
                label: '${_submissions.length} Pengajuan',
                color: Colors.purple,
              ),
            ],
          ),

          // Berkas section
          if (widget.assignment.attachmentUrl != null &&
              widget.assignment.attachmentUrl!.isNotEmpty &&
              !widget.assignment.attachmentUrl!.startsWith('meeting:')) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.description_outlined,
                      color: Colors.blue.shade400),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Berkas Tugas',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      GestureDetector(
                        onTap: () =>
                            _openUrl(widget.assignment.attachmentUrl!),
                        child: Text(
                          'Lihat Berkas',
                          style: TextStyle(
                            color: primaryBlue,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isExpired) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isExpired
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        isExpired ? 'Tertutup' : 'Aktif',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isExpired ? Colors.red : Colors.green,
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime date, Color color) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14),
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: DateFormat('dd MMMM yyyy | HH.mm', 'id_ID').format(date),
            style: const TextStyle(color: Colors.black87),
          ),
          const TextSpan(
            text: ' WIB',
            style: TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
      {required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSubmissionsSection() {
    final gradedCount =
        _submissions.where((s) => s.status == 'graded').length;
    final pendingCount =
        _submissions.where((s) => s.status == 'submitted' || s.status == 'late').length;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Pengajuan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _buildCountChip('Dinilai', gradedCount, Colors.green),
                  const SizedBox(width: 8),
                  _buildCountChip('Menunggu', pendingCount, Colors.orange),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Submissions list
          if (_submissions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada pengajuan',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _submissions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final submission = _submissions[index];
                return _buildSubmissionTile(submission);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCountChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $count',
        style:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }

  Widget _buildSubmissionTile(SubmissionModel submission) {
    final hasAttachment = submission.attachmentUrl != null && 
        submission.attachmentUrl!.isNotEmpty;
    final isGraded = submission.status == 'graded';
    final score = submission.score?.toInt() ?? 0;
    final minScore = widget.assignment.maxScore; // maxScore is actually minScore (nilai minimal)
    final passedMinScore = isGraded && score >= minScore;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: isGraded 
              ? (passedMinScore ? Colors.green.shade200 : Colors.red.shade200)
              : Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(submission.status),
              child: Text(
                submission.studentName?.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              submission.studentName ?? 'Siswa',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  submission.submittedAt != null
                      ? 'Dikirim: ${DateFormat('dd MMM yyyy, HH:mm').format(submission.submittedAt!)}'
                      : 'Belum dikumpulkan',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (isGraded) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        passedMinScore ? Icons.check_circle : Icons.cancel,
                        size: 14,
                        color: passedMinScore ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        passedMinScore 
                            ? 'Lulus (≥$minScore)' 
                            : 'Tidak Lulus (<$minScore)',
                        style: TextStyle(
                          fontSize: 11,
                          color: passedMinScore ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSubmissionStatusBadge(submission),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
              ],
            ),
            onTap: () => _showGradeDialog(submission),
          ),
          // Document link section
          if (hasAttachment)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: GestureDetector(
                onTap: () => _openUrl(submission.attachmentUrl!),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.description_outlined, color: primaryBlue, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dokumen Pengajuan',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              submission.attachmentUrl!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.open_in_new, color: primaryBlue, size: 16),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
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

  void _showGradeDialog(SubmissionModel submission) {
    final scoreController = TextEditingController(
      text: submission.score?.toInt().toString() ?? '',
    );
    final feedbackController = TextEditingController(
      text: submission.feedback ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Nilai - ${submission.studentName ?? 'Siswa'}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Attachment link
              if (submission.attachmentUrl != null &&
                  submission.attachmentUrl!.isNotEmpty) ...[
                const Text('Berkas Pengajuan:',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _openUrl(submission.attachmentUrl!),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.link, color: primaryBlue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Lihat Berkas',
                            style: TextStyle(color: primaryBlue),
                          ),
                        ),
                        Icon(Icons.open_in_new, color: primaryBlue, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Score input
              Row(
                children: [
                  const Text('Nilai:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Min: ${widget.assignment.maxScore}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: scoreController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Masukkan nilai (0-100)',
                  helperText: 'Nilai minimal untuk lulus: ${widget.assignment.maxScore}',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Feedback input
              const Text('Feedback:',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: feedbackController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan feedback (opsional)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final score = double.tryParse(scoreController.text);
              if (score == null || score < 0 || score > 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nilai harus antara 0 dan 100'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext);
              await _gradeSubmission(
                submission.id,
                score,
                feedbackController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _gradeSubmission(
      String submissionId, double score, String feedback) async {
    try {
      final provider = context.read<AssignmentProvider>();
      final result = await provider.assignmentService.gradeSubmission(
        submissionId: submissionId,
        score: score,
        feedback: feedback,
      );

      if (mounted) {
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nilai berhasil disimpan'),
              backgroundColor: Colors.green,
            ),
          );
          _loadSubmissions(); // Refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menyimpan nilai'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _editAssignment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAssignmentPage(assignment: widget.assignment),
      ),
    ).then((_) {
      // Refresh if needed
      if (mounted) {
        Navigator.pop(context); // Go back to list
      }
    });
  }

  Future<void> _deleteAssignment(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content:
            Text('Apakah Anda yakin ingin menghapus "${widget.assignment.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<AssignmentProvider>();
      final success = await provider.deleteAssignment(widget.assignment.id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tugas berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal: ${provider.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _openUrl(String url) async {
    try {
      // Ensure URL has proper scheme
      String finalUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        finalUrl = 'https://$url';
      }
      
      final uri = Uri.parse(finalUrl);
      
      // Try to launch URL
      final launched = await launchUrl(
        uri, 
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched && mounted) {
        // Fallback: try with platformDefault mode
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka URL: $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Error opening URL: $e');
    }
  }
}
