// lib/features/assignments/presentation/pages/assignment_list_page.dart
// Requirements: 6.1-6.6

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/assignment_provider.dart';
import '../widgets/assignment_card.dart';
import 'create_assignment_page.dart';
import 'assignment_detail_page.dart';

/// Page to display list of assignments created by mentor
/// **Validates: Requirements 6.1-6.6**
class AssignmentListPage extends StatefulWidget {
  const AssignmentListPage({super.key});

  @override
  State<AssignmentListPage> createState() => _AssignmentListPageState();
}

class _AssignmentListPageState extends State<AssignmentListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssignmentProvider>().loadAssignments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AssignmentProvider>().loadAssignments(),
          ),
        ],
      ),
      body: Consumer<AssignmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.assignments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.assignments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.errorMessage}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadAssignments(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (provider.assignments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada tugas',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap tombol + untuk membuat tugas baru',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAssignments(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.assignments.length,
              itemBuilder: (context, index) {
                final assignment = provider.assignments[index];
                return AssignmentCard(
                  assignment: assignment,
                  onTap: () => _navigateToDetail(assignment.id),
                  onEdit: () => _navigateToEdit(assignment.id),
                  onDelete: () => _showDeleteConfirmation(assignment.id),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        icon: const Icon(Icons.add),
        label: const Text('Buat Tugas'),
      ),
    );
  }

  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateAssignmentPage()),
    ).then((_) => context.read<AssignmentProvider>().loadAssignments());
  }

  void _navigateToDetail(String assignmentId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AssignmentDetailPage(assignmentId: assignmentId)),
    ).then((_) => context.read<AssignmentProvider>().loadAssignments());
  }

  void _navigateToEdit(String assignmentId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateAssignmentPage(assignmentId: assignmentId)),
    ).then((_) => context.read<AssignmentProvider>().loadAssignments());
  }

  void _showDeleteConfirmation(String assignmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus tugas ini? '
          'Semua submission akan ikut terhapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<AssignmentProvider>().deleteAssignment(assignmentId);
              if (success && mounted) {
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
