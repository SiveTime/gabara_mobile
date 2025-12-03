// lib/features/assignments/presentation/pages/submission_detail_page.dart
// Requirements: 9.1-9.5

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/submission_model.dart';
import '../providers/assignment_provider.dart';

/// Page to view and grade a submission
/// **Validates: Requirements 9.1-9.5**
class SubmissionDetailPage extends StatefulWidget {
  final String submissionId;

  const SubmissionDetailPage({super.key, required this.submissionId});

  @override
  State<SubmissionDetailPage> createState() => _SubmissionDetailPageState();
}

class _SubmissionDetailPageState extends State<SubmissionDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _scoreController = TextEditingController();
  final _feedbackController = TextEditingController();
  bool _isGrading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSubmission();
    });
  }

  Future<void> _loadSubmission() async {
    final provider = context.read<AssignmentProvider>();
    await provider.loadSubmissionDetail(widget.submissionId);
    
    final submission = provider.currentSubmission;
    if (submission != null && submission.score != null) {
      _scoreController.text = submission.score!.toInt().toString();
      _feedbackController.text = submission.feedback ?? '';
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Submission'),
      ),
      body: Consumer<AssignmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final submission = provider.currentSubmission;
          if (submission == null) {
            return const Center(child: Text('Submission tidak ditemukan'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStudentInfo(submission),
                const SizedBox(height: 16),
                _buildSubmissionContent(submission),
                const SizedBox(height: 24),
                _buildGradingForm(submission, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStudentInfo(SubmissionModel submission) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: _getStatusColor(submission.status),
              child: Text(
                submission.studentName?.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    submission.studentName ?? 'Unknown',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    submission.submittedAt != null
                        ? 'Dikumpulkan: ${DateFormat('dd MMM yyyy, HH:mm').format(submission.submittedAt!)}'
                        : 'Belum dikumpulkan',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(submission.status),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionContent(SubmissionModel submission) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jawaban',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                submission.content.isNotEmpty
                    ? submission.content
                    : 'Tidak ada jawaban teks',
                style: TextStyle(
                  color: submission.content.isNotEmpty ? Colors.black87 : Colors.grey,
                ),
              ),
            ),
            if (submission.attachmentUrl != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Open attachment
                },
                icon: const Icon(Icons.attachment),
                label: const Text('Lihat Lampiran'),
              ),
            ],
          ],
        ),
      ),
    );
  }


  Widget _buildGradingForm(SubmissionModel submission, AssignmentProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Penilaian',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (submission.gradedAt != null)
                    Text(
                      'Dinilai: ${DateFormat('dd MMM yyyy').format(submission.gradedAt!)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Score input
              TextFormField(
                controller: _scoreController,
                decoration: InputDecoration(
                  labelText: 'Nilai *',
                  border: const OutlineInputBorder(),
                  suffixText: '/ ${provider.currentAssignment?.maxScore ?? 100}',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nilai harus diisi';
                  }
                  final score = double.tryParse(value);
                  if (score == null) {
                    return 'Nilai tidak valid';
                  }
                  final maxScore = provider.currentAssignment?.maxScore ?? 100;
                  if (score < 0 || score > maxScore) {
                    return 'Nilai harus antara 0 - $maxScore';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Feedback input
              TextFormField(
                controller: _feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Feedback',
                  border: OutlineInputBorder(),
                  hintText: 'Berikan feedback untuk siswa...',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isGrading ? null : () => _submitGrade(provider),
                  child: _isGrading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(submission.status == 'graded' ? 'Update Nilai' : 'Simpan Nilai'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    String label;
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'graded':
        label = 'Dinilai';
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'submitted':
        label = 'Menunggu';
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case 'late':
        label = 'Terlambat';
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      default:
        label = 'Draft';
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
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

  Future<void> _submitGrade(AssignmentProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGrading = true);

    final success = await provider.gradeSubmission(
      submissionId: widget.submissionId,
      score: double.parse(_scoreController.text),
      feedback: _feedbackController.text.trim(),
    );

    setState(() => _isGrading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nilai berhasil disimpan')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${provider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
