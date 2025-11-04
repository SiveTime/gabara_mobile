// lib/features/tugas/presentation/pages/submission_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tugas_provider.dart';
import 'package:gabara_mobile/core/widgets/common_button.dart';
import 'package:gabara_mobile/core/constants/app_colors.dart';

class SubmissionPage extends StatefulWidget {
  final String tugasId;
  final bool isTutorView;

  const SubmissionPage({
    super.key,
    required this.tugasId,
    this.isTutorView = false,
  });

  @override
  State<SubmissionPage> createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<TugasProvider>();
    provider.fetchSubmissions(widget.tugasId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TugasProvider>(
      builder: (context, provider, _) {
        final tugas = provider.getTugasById(widget.tugasId);
        final submissions = provider.submissions;

  return Scaffold(
          appBar: AppBar(
            title: Text(tugas?.title ?? 'Detail Tugas'),
            backgroundColor: primaryBlue,
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Header ---
                      Text(
                        tugas?.title ?? 'Tugas',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tugas?.description ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Divider(height: 32),

                      // --- Submissions Section ---
                      Expanded(
                        child: submissions.isEmpty
                            ? const Center(
                                child: Text('Belum ada pengumpulan tugas.'),
                              )
                            : ListView.builder(
                                itemCount: submissions.length,
                                itemBuilder: (context, index) {
                                  final submission = submissions[index];
                                  return ListTile(
                                    title: Text(submission['studentName'] ?? ''),
                                    subtitle: Text('Dikumpulkan pada ${submission['submittedAt'] ?? ''}'),
                                    trailing: widget.isTutorView
                                        ? IconButton(
                                            icon: const Icon(Icons.grade),
                                            onPressed: () {
                                              _showGradeDialog(submission['id'] ?? '');
                                            },
                                          )
                                        : null,
                                    onTap: () {
                                      _openSubmissionDetail(submission['id'] ?? '');
                                    },
                                  );
                                },
                              ),
                      ),

                      // --- Action Button for Student ---
                      if (!widget.isTutorView)
                        CommonButton(
                          label: 'Kumpulkan Tugas',
                          onPressed: () {
                            _showUploadDialog(context);
                          },
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  void _openSubmissionDetail(String submissionId) {
    // TODO: Navigate to detail view or file preview
  }

  void _showUploadDialog(BuildContext context) {
    // TODO: Upload submission logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Tugas'),
        content: const Text('Fitur upload tugas akan ditambahkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showGradeDialog(String submissionId) {
    // TODO: Add grading feature for tutor
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Beri Nilai'),
        content: const Text('Fitur penilaian akan ditambahkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              // context.read<TugasProvider>().gradeSubmission(submissionId, score);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
