// lib/features/meetings/presentation/pages/meeting_detail_page.dart
// Requirements: 2.1-2.9, 15.1-15.5

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/meeting_model.dart';
import '../providers/meeting_provider.dart';
import 'create_meeting_page.dart';

/// Page to display meeting details and attendance
/// **Validates: Requirements 2.1-2.9, 15.1-15.5**
class MeetingDetailPage extends StatefulWidget {
  final String meetingId;

  const MeetingDetailPage({super.key, required this.meetingId});

  @override
  State<MeetingDetailPage> createState() => _MeetingDetailPageState();
}

class _MeetingDetailPageState extends State<MeetingDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeetingProvider>().loadMeetingDetail(widget.meetingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pertemuan'),
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
      body: Consumer<MeetingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final meeting = provider.currentMeeting;
          if (meeting == null) {
            return const Center(child: Text('Pertemuan tidak ditemukan'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadMeetingDetail(widget.meetingId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMeetingInfo(meeting),
                  const SizedBox(height: 24),
                  _buildStatusSection(meeting, provider),
                  const SizedBox(height: 24),
                  _buildAttendanceSection(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMeetingInfo(MeetingModel meeting) {
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
                    meeting.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(meeting.status),
              ],
            ),
            if (meeting.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                meeting.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
            const Divider(height: 24),
            _buildInfoRow(
              Icons.calendar_today,
              'Tanggal',
              DateFormat('EEEE, dd MMMM yyyy').format(meeting.meetingDate),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time,
              'Waktu',
              '${DateFormat('HH:mm').format(meeting.meetingDate)} - '
                  '${DateFormat('HH:mm').format(meeting.endTime)} '
                  '(${meeting.durationMinutes} menit)',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              meeting.isOnline ? Icons.videocam : Icons.location_on,
              meeting.isOnline ? 'Meeting Link' : 'Lokasi',
              meeting.isOnline
                  ? (meeting.meetingLink ?? '-')
                  : (meeting.location ?? '-'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection(MeetingModel meeting, MeetingProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Pertemuan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                if (meeting.status == 'scheduled')
                  ElevatedButton.icon(
                    onPressed: () => _updateStatus('ongoing'),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Mulai'),
                  ),
                if (meeting.status == 'ongoing')
                  ElevatedButton.icon(
                    onPressed: () => _updateStatus('completed'),
                    icon: const Icon(Icons.check),
                    label: const Text('Selesai'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                if (meeting.status != 'cancelled' &&
                    meeting.status != 'completed')
                  OutlinedButton.icon(
                    onPressed: () => _updateStatus('cancelled'),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Batalkan'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSection(MeetingProvider provider) {
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
                  'Kehadiran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${provider.attendanceList.length} siswa',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (provider.attendanceList.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Belum ada data kehadiran',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.attendanceList.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final attendance = provider.attendanceList[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: _getAttendanceColor(attendance.status),
                      child: Text(
                        attendance.studentName?.substring(0, 1).toUpperCase() ??
                            '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(attendance.studentName ?? 'Unknown'),
                    trailing: PopupMenuButton<String>(
                      initialValue: attendance.status,
                      onSelected: (status) => _markAttendance(
                        attendance.studentId,
                        status,
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'present',
                          child: Text('Hadir'),
                        ),
                        const PopupMenuItem(
                          value: 'absent',
                          child: Text('Tidak Hadir'),
                        ),
                        const PopupMenuItem(
                          value: 'late',
                          child: Text('Terlambat'),
                        ),
                        const PopupMenuItem(
                          value: 'excused',
                          child: Text('Izin'),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getAttendanceColor(attendance.status)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _getAttendanceLabel(attendance.status),
                          style: TextStyle(
                            color: _getAttendanceColor(attendance.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case 'scheduled':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        label = 'Dijadwalkan';
        break;
      case 'ongoing':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        label = 'Berlangsung';
        break;
      case 'completed':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        label = 'Selesai';
        break;
      case 'cancelled':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        label = 'Dibatalkan';
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Color _getAttendanceColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      case 'excused':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getAttendanceLabel(String status) {
    switch (status) {
      case 'present':
        return 'Hadir';
      case 'absent':
        return 'Tidak Hadir';
      case 'late':
        return 'Terlambat';
      case 'excused':
        return 'Izin';
      default:
        return status;
    }
  }

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateMeetingPage(meetingId: widget.meetingId),
      ),
    ).then((_) {
      context.read<MeetingProvider>().loadMeetingDetail(widget.meetingId);
    });
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pertemuan'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus pertemuan ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context
                  .read<MeetingProvider>()
                  .deleteMeeting(widget.meetingId);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pertemuan berhasil dihapus')),
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

  Future<void> _updateStatus(String newStatus) async {
    final success = await context
        .read<MeetingProvider>()
        .updateMeetingStatus(widget.meetingId, newStatus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Status berhasil diperbarui' : 'Gagal memperbarui status',
          ),
          backgroundColor: success ? null : Colors.red,
        ),
      );
    }
  }

  Future<void> _markAttendance(String studentId, String status) async {
    final success = await context.read<MeetingProvider>().markAttendance(
          meetingId: widget.meetingId,
          studentId: studentId,
          status: status,
        );

    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui kehadiran'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
