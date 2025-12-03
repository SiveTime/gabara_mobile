// lib/features/student/presentation/pages/student_meeting_detail_page.dart
// Requirements: 10.1-10.5

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/student_provider.dart';

/// Page to display meeting details for students
/// **Validates: Requirements 10.1-10.5**
class StudentMeetingDetailPage extends StatefulWidget {
  final String meetingId;

  const StudentMeetingDetailPage({
    super.key,
    required this.meetingId,
  });

  @override
  State<StudentMeetingDetailPage> createState() => _StudentMeetingDetailPageState();
}

class _StudentMeetingDetailPageState extends State<StudentMeetingDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().loadMeetingDetail(widget.meetingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pertemuan')),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currentMeeting == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.currentMeeting == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadMeetingDetail(widget.meetingId),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final meeting = provider.currentMeeting;
          if (meeting == null) {
            return const Center(child: Text('Pertemuan tidak ditemukan'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        meeting.title,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildStatusBadge(meeting.status),
                  ],
                ),
                const SizedBox(height: 16),

                // Meeting Type Badge
                _buildMeetingTypeBadge(meeting.isOnline),
                const SizedBox(height: 24),

                // Description
                if (meeting.description.isNotEmpty) ...[
                  const Text('Deskripsi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(meeting.description, style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 24),
                ],

                // Meeting Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.calendar_today, 'Tanggal', DateFormat('EEEE, dd MMMM yyyy', 'id').format(meeting.meetingDate)),
                        const Divider(),
                        _buildInfoRow(Icons.access_time, 'Waktu', DateFormat('HH:mm').format(meeting.meetingDate)),
                        const Divider(),
                        _buildInfoRow(Icons.timer, 'Durasi', '${meeting.durationMinutes} menit'),
                        if (meeting.isOnline && meeting.meetingLink != null) ...[
                          const Divider(),
                          _buildInfoRow(Icons.link, 'Link Meeting', meeting.meetingLink!, isLink: true),
                        ],
                        if (!meeting.isOnline && meeting.location != null) ...[
                          const Divider(),
                          _buildInfoRow(Icons.location_on, 'Lokasi', meeting.location!),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Open Meeting Button (for online meetings)
                if (meeting.isOnline && meeting.meetingLink != null && _canJoinMeeting(meeting.status)) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openMeetingLink(meeting.meetingLink!),
                      icon: const Icon(Icons.videocam),
                      label: const Text('Buka Meeting'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
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
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(16)),
      child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
    );
  }

  Widget _buildMeetingTypeBadge(bool isOnline) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOnline ? Colors.purple[100] : Colors.teal[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isOnline ? Icons.videocam : Icons.location_on, size: 16, color: isOnline ? Colors.purple[800] : Colors.teal[800]),
          const SizedBox(width: 4),
          Text(isOnline ? 'Online' : 'Offline', style: TextStyle(color: isOnline ? Colors.purple[800] : Colors.teal[800], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 2),
                isLink
                    ? GestureDetector(
                        onTap: () => _openMeetingLink(value),
                        child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.blue, decoration: TextDecoration.underline)),
                      )
                    : Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canJoinMeeting(String status) {
    return status == 'scheduled' || status == 'ongoing';
  }

  Future<void> _openMeetingLink(String link) async {
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka link: $link')),
        );
      }
    }
  }
}
