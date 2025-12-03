// lib/features/student/presentation/pages/student_meeting_list_page.dart
// Requirements: 10.1-10.5

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../meetings/data/models/meeting_model.dart';
import '../providers/student_provider.dart';
import 'student_meeting_detail_page.dart';

/// Page to display meetings for student's enrolled classes
/// **Validates: Requirements 10.1-10.5**
class StudentMeetingListPage extends StatefulWidget {
  final String classId;
  final String className;

  const StudentMeetingListPage({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<StudentMeetingListPage> createState() => _StudentMeetingListPageState();
}

class _StudentMeetingListPageState extends State<StudentMeetingListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().loadMeetings(widget.classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pertemuan - ${widget.className}')),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.meetings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.meetings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadMeetings(widget.classId),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (provider.meetings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Belum ada pertemuan', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadMeetings(widget.classId),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.meetings.length,
              itemBuilder: (context, index) {
                final meeting = provider.meetings[index];
                return _buildMeetingCard(meeting);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMeetingCard(MeetingModel meeting) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetail(meeting.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(meeting.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  _buildStatusBadge(meeting.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(DateFormat('dd MMM yyyy, HH:mm').format(meeting.meetingDate), style: TextStyle(color: Colors.grey[600])),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(meeting.isOnline ? Icons.videocam : Icons.location_on, size: 16, color: meeting.isOnline ? Colors.purple : Colors.teal),
                  const SizedBox(width: 4),
                  Text(meeting.isOnline ? 'Online' : 'Offline', style: TextStyle(color: meeting.isOnline ? Colors.purple : Colors.teal)),
                  if (meeting.isOnline && meeting.meetingLink != null) ...[
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _openMeetingLink(meeting.meetingLink!),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Buka Meeting'),
                    ),
                  ],
                ],
              ),
            ],
          ),
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
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textColor)),
    );
  }

  void _navigateToDetail(String meetingId) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => StudentMeetingDetailPage(meetingId: meetingId)));
  }

  void _openMeetingLink(String link) {
    // TODO: Implement URL launcher
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening: $link')));
  }
}
