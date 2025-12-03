// lib/features/student/presentation/pages/student_assignment_detail_page.dart
// Requirements: 12.1-12.6

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../assignments/data/models/submission_model.dart';
import '../providers/student_provider.dart';

/// Page to display assignment details and allow student to submit
/// **Validates: Requirements 12.1-12.6**
class StudentAssignmentDetailPage extends StatefulWidget {
  final String assignmentId;

  const StudentAssignmentDetailPage({
    super.key,
    required this.assignmentId,
  });

  @override
  State<StudentAssignmentDetailPage> createState() => _StudentAssignmentDetailPageState();
}

class _StudentAssignmentDetailPageState extends State<StudentAssignmentDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<StudentProvider>();
    await provider.loadAssignmentDetail(widget.assignmentId);
    final submission = provider.mySubmission;
    if (submission != null && submission.content.isNotEmpty) {
      _contentController.text = submission.content;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tugas')),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currentAssignment == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.currentAssignment == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final assignment = provider.currentAssignment;
          if (assignment == null) {
            return const Center(child: Text('Tugas tidak ditemukan'));
          }

          final submission = provider.mySubmission;
          final now = DateTime.now();
          final isDeadlinePassed = assignment.deadline.isBefore(now);
          final hasSubmitted = submission != null && submission.status != 'draft';
          final isGraded = submission?.status == 'graded';
          final canEdit = !isDeadlinePassed && !isGraded;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Assignment Info Section
                _buildAssignmentInfoSection(assignment, isDeadlinePassed),
                const SizedBox(height: 24),

                // Submission Status Section
                if (hasSubmitted) ...[
                  _buildSubmissionStatusSection(submission!, isGraded),
                  const SizedBox(height: 24),
                ],

                // Grade Section (if graded)
                if (isGraded && submission != null) ...[
                  _buildGradeSection(submission, assignment.maxScore),
                  const SizedBox(height: 24),
                ],

                // Submission Form Section
                if (!isGraded) ...[
                  _buildSubmissionFormSection(submission, canEdit, hasSubmitted),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAssignmentInfoSection(dynamic assignment, bool isDeadlinePassed) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    assignment.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildDeadlineBadge(isDeadlinePassed),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            if (assignment.description.isNotEmpty) ...[
              Text(assignment.description, style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 12),
            ],

            const Divider(),

            // Deadline
            _buildInfoRow(
              Icons.schedule,
              'Deadline',
              DateFormat('EEEE, dd MMMM yyyy HH:mm', 'id').format(assignment.deadline),
              isDeadlinePassed ? Colors.red : null,
            ),

            // Max Score
            _buildInfoRow(Icons.star_outline, 'Nilai Maksimal', '${assignment.maxScore}', null),

            // Attachment
            if (assignment.attachmentUrl != null) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _openAttachment(assignment.attachmentUrl!),
                child: Row(
                  children: [
                    Icon(Icons.attach_file, size: 20, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    Text('Lihat Lampiran', style: TextStyle(color: Colors.blue[600], decoration: TextDecoration.underline)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionStatusSection(SubmissionModel submission, bool isGraded) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (submission.status) {
      case 'submitted':
        statusText = 'Menunggu Penilaian';
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'graded':
        statusText = 'Sudah Dinilai';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'late':
        statusText = 'Terlambat';
        statusColor = Colors.red;
        statusIcon = Icons.warning;
        break;
      default:
        statusText = 'Draft';
        statusColor = Colors.grey;
        statusIcon = Icons.edit_note;
    }

    return Card(
      color: statusColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status Pengumpulan', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(statusText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: statusColor)),
                  if (submission.submittedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Dikumpulkan: ${DateFormat('dd MMM yyyy, HH:mm').format(submission.submittedAt!)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeSection(SubmissionModel submission, int maxScore) {
    final percentage = (submission.score! / maxScore * 100).toStringAsFixed(1);

    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.grade, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                const Text('Nilai', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),

            // Score display
            Row(
              children: [
                Text(
                  submission.score!.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                Text(' / $maxScore', style: TextStyle(fontSize: 20, color: Colors.grey[600])),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(16)),
                  child: Text('$percentage%', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green[800])),
                ),
              ],
            ),

            // Feedback
            if (submission.feedback?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text('Feedback dari Mentor:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                child: Text(submission.feedback!, style: TextStyle(color: Colors.grey[700])),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionFormSection(SubmissionModel? submission, bool canEdit, bool hasSubmitted) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(hasSubmitted ? Icons.edit : Icons.assignment_turned_in, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Text(
                    hasSubmitted ? 'Edit Jawaban' : 'Kumpulkan Tugas',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Content input
              TextFormField(
                controller: _contentController,
                maxLines: 8,
                enabled: canEdit,
                decoration: InputDecoration(
                  labelText: 'Jawaban',
                  hintText: 'Tulis jawaban Anda di sini...',
                  border: const OutlineInputBorder(),
                  filled: !canEdit,
                  fillColor: canEdit ? null : Colors.grey[100],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Jawaban tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Warning if deadline passed
              if (!canEdit && submission?.status != 'graded') ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange[200]!)),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Deadline sudah lewat. Anda tidak dapat mengedit jawaban.',
                          style: TextStyle(color: Colors.orange[700], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Submit button
              if (canEdit) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitAssignment,
                    icon: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
                    label: Text(hasSubmitted ? 'Update Jawaban' : 'Kumpulkan'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeadlineBadge(bool isDeadlinePassed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDeadlinePassed ? Colors.red[100] : Colors.blue[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isDeadlinePassed ? 'Tertutup' : 'Aktif',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDeadlinePassed ? Colors.red[800] : Colors.blue[800]),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color? valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14, color: valueColor ?? Colors.black))),
        ],
      ),
    );
  }

  Future<void> _submitAssignment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<StudentProvider>();
    final assignment = provider.currentAssignment;
    final existingSubmission = provider.mySubmission;
    final currentUser = Supabase.instance.client.auth.currentUser;

    if (assignment == null || currentUser == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    // Determine if late submission
    final now = DateTime.now();
    final isLate = assignment.deadline.isBefore(now);
    final status = isLate ? 'late' : 'submitted';

    final submission = SubmissionModel(
      id: existingSubmission?.id ?? '',
      assignmentId: assignment.id,
      studentId: currentUser.id,
      content: _contentController.text.trim(),
      status: status,
      submittedAt: DateTime.now(),
    );

    final success = await provider.submitAssignment(submission);

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isLate ? 'Tugas dikumpulkan (terlambat)' : 'Tugas berhasil dikumpulkan'),
            backgroundColor: isLate ? Colors.orange : Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengumpulkan tugas: ${provider.errorMessage}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _openAttachment(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tidak dapat membuka: $url')));
      }
    }
  }
}
