// lib/features/meetings/presentation/pages/meeting_list_page.dart
// Requirements: 2.1-2.9

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meeting_provider.dart';
import '../widgets/meeting_card.dart';
import 'create_meeting_page.dart';
import 'meeting_detail_page.dart';

/// Page to display list of meetings created by mentor
/// **Validates: Requirements 2.1-2.9**
class MeetingListPage extends StatefulWidget {
  const MeetingListPage({super.key});

  @override
  State<MeetingListPage> createState() => _MeetingListPageState();
}

class _MeetingListPageState extends State<MeetingListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeetingProvider>().loadMeetings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pertemuan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<MeetingProvider>().loadMeetings(),
          ),
        ],
      ),
      body: Consumer<MeetingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.meetings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.meetings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.errorMessage}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadMeetings(),
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
                  Icon(
                    Icons.event_note,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pertemuan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap tombol + untuk membuat pertemuan baru',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadMeetings(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.meetings.length,
              itemBuilder: (context, index) {
                final meeting = provider.meetings[index];
                return MeetingCard(
                  meeting: meeting,
                  onTap: () => _navigateToDetail(meeting.id),
                  onEdit: () => _navigateToEdit(meeting.id),
                  onDelete: () => _showDeleteConfirmation(meeting.id),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        icon: const Icon(Icons.add),
        label: const Text('Buat Pertemuan'),
      ),
    );
  }

  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateMeetingPage()),
    ).then((_) => context.read<MeetingProvider>().loadMeetings());
  }

  void _navigateToDetail(String meetingId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MeetingDetailPage(meetingId: meetingId),
      ),
    ).then((_) => context.read<MeetingProvider>().loadMeetings());
  }

  void _navigateToEdit(String meetingId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateMeetingPage(meetingId: meetingId),
      ),
    ).then((_) => context.read<MeetingProvider>().loadMeetings());
  }

  void _showDeleteConfirmation(String meetingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pertemuan'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus pertemuan ini? '
          'Tindakan ini tidak dapat dibatalkan.',
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
                  .deleteMeeting(meetingId);
              if (success && mounted) {
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
}
