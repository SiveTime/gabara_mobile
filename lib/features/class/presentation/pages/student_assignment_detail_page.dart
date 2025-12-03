// lib/features/class/presentation/pages/student_assignment_detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../assignments/data/models/assignment_model.dart';
import '../../../assignments/data/models/submission_model.dart';
import '../../../assignments/presentation/providers/assignment_provider.dart';

/// Halaman detail tugas untuk siswa
class StudentAssignmentDetailPage extends StatefulWidget {
  final AssignmentModel assignment;
  final int assignmentNumber;

  const StudentAssignmentDetailPage({
    super.key,
    required this.assignment,
    this.assignmentNumber = 1,
  });

  @override
  State<StudentAssignmentDetailPage> createState() => _StudentAssignmentDetailPageState();
}

class _StudentAssignmentDetailPageState extends State<StudentAssignmentDetailPage> {
  SubmissionModel? _submission;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubmission();
  }

  Future<void> _loadSubmission() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<AssignmentProvider>();
      final submission = await provider.assignmentService.fetchStudentSubmission(widget.assignment.id);
      if (mounted) {
        setState(() {
          _submission = submission;
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
    final timeRemaining = widget.assignment.deadline.difference(now);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Detail Tugas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  Container(
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
                        // Title
                        Text(
                          'Tugas ${widget.assignmentNumber} - ${widget.assignment.title}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                                child: Icon(Icons.description_outlined, color: Colors.blue.shade400),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Berkas',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    GestureDetector(
                                      onTap: () => _openUrl(widget.assignment.attachmentUrl!),
                                      child: Text(
                                        'Lihat',
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
                  ),

                  // Status Pengajuan Tugas
                  Container(
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
                        const Text(
                          'Status Pengajuan Tugas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStatusTable(timeRemaining, isExpired),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100), // Space for button
                ],
              ),
            ),
      bottomNavigationBar: _isLoading
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: _submission != null && _submission!.status != 'graded'
                    ? Row(
                        children: [
                          // Delete button
                          Expanded(
                            flex: 1,
                            child: OutlinedButton(
                              onPressed: () => _showDeleteConfirmation(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Icon(Icons.delete_outline),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Update button
                          Expanded(
                            flex: 3,
                            child: ElevatedButton(
                              onPressed: isExpired ? null : () => _showSubmitDialog(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                disabledBackgroundColor: Colors.grey.shade400,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Update Pengajuan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: (_submission?.status == 'graded' || isExpired) 
                            ? null 
                            : () => _showSubmitDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          disabledBackgroundColor: Colors.grey.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _submission?.status == 'graded' 
                              ? 'Pengajuan Sudah Dinilai' 
                              : 'Kirim Pengajuan',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  Widget _buildStatusTable(Duration timeRemaining, bool isExpired) {
    String statusPengajuan = 'Belum ada pengajuan';
    Color statusColor = Colors.red;
    String statusPenilaian = 'Belum dinilai';
    String terakhirDiubah = '-';

    if (_submission != null) {
      statusPengajuan = _submission!.status == 'submitted' 
          ? 'Sudah dikirim' 
          : _submission!.status == 'graded' 
              ? 'Sudah dinilai' 
              : _submission!.status == 'late'
                  ? 'Terlambat'
                  : 'Draft';
      statusColor = _submission!.status == 'graded' 
          ? Colors.green 
          : _submission!.status == 'late'
              ? Colors.orange
              : Colors.blue;
      
      if (_submission!.status == 'graded' && _submission!.score != null) {
        statusPenilaian = 'Nilai: ${_submission!.score!.toInt()}/${widget.assignment.maxScore}';
      }
      
      if (_submission!.submittedAt != null) {
        terakhirDiubah = DateFormat('dd MMM yyyy, HH:mm').format(_submission!.submittedAt!);
      }
    }

    String waktuTersisa = isExpired 
        ? 'Waktu habis' 
        : '${timeRemaining.inDays} hari ${timeRemaining.inHours % 24} jam ${timeRemaining.inMinutes % 60} menit';

    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableRow('Status pengajuan', statusPengajuan, statusColor),
        _buildTableRow('Status penilaian', statusPenilaian, Colors.black87),
        _buildTableRow('Waktu tersisa', waktuTersisa, isExpired ? Colors.red : Colors.black87),
        _buildTableRow('Terakhir diubah', terakhirDiubah, Colors.black87),
      ],
    );
  }

  TableRow _buildTableRow(String label, String value, Color valueColor) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            value,
            style: TextStyle(fontSize: 13, color: valueColor, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Pengajuan'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus pengajuan ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _deleteSubmission();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSubmission() async {
    if (_submission == null) return;

    try {
      final provider = context.read<AssignmentProvider>();
      await provider.assignmentService.deleteSubmission(_submission!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengajuan berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _submission = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSubmitDialog(BuildContext context) {
    final urlController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Kirim Pengajuan', style: TextStyle(fontSize: 18)),
            IconButton(
              onPressed: () => Navigator.pop(dialogContext),
              icon: const Icon(Icons.close),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengajuan Berkas',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                hintText: 'Masukkan URL file (Google Drive, dll)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 8),
            Text(
              'Atau upload file ke Google Drive dan paste link-nya',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (urlController.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext);
                await _submitAssignment(urlController.text.trim());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Masukkan URL file terlebih dahulu')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            child: const Text('Kirim', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAssignment(String fileUrl) async {
    try {
      final provider = context.read<AssignmentProvider>();
      final submission = SubmissionModel(
        id: '',
        assignmentId: widget.assignment.id,
        studentId: '',
        content: 'Pengajuan tugas',
        attachmentUrl: fileUrl,
        status: 'submitted',
      );

      final result = await provider.assignmentService.submitAssignment(submission);

      if (mounted) {
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengajuan berhasil dikirim'),
              backgroundColor: Colors.green,
            ),
          );
          _loadSubmission(); // Refresh submission status
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengirim pengajuan'),
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
