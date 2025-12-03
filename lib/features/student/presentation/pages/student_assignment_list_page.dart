// lib/features/student/presentation/pages/student_assignment_list_page.dart
// Requirements: 11.1-11.8

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../assignments/data/models/assignment_model.dart';
import '../providers/student_provider.dart';
import 'student_assignment_detail_page.dart';

/// Page to display assignments for student's enrolled classes
/// **Validates: Requirements 11.1-11.8**
class StudentAssignmentListPage extends StatefulWidget {
  final String classId;
  final String className;

  const StudentAssignmentListPage({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<StudentAssignmentListPage> createState() => _StudentAssignmentListPageState();
}

class _StudentAssignmentListPageState extends State<StudentAssignmentListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().loadAssignments(widget.classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tugas - ${widget.className}')),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.assignments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.assignments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadAssignments(widget.classId),
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
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Belum ada tugas', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAssignments(widget.classId),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.assignments.length,
              itemBuilder: (context, index) {
                final assignment = provider.assignments[index];
                return _buildAssignmentCard(assignment);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAssignmentCard(AssignmentModel assignment) {
    final now = DateTime.now();
    final isDeadlinePassed = assignment.deadline.isBefore(now);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetail(assignment.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Status Badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      assignment.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildDeadlineBadge(isDeadlinePassed),
                ],
              ),
              const SizedBox(height: 8),

              // Description preview
              if (assignment.description.isNotEmpty) ...[
                Text(
                  assignment.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 8),
              ],

              // Deadline info
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: isDeadlinePassed ? Colors.red[600] : Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Deadline: ${DateFormat('dd MMM yyyy, HH:mm').format(assignment.deadline)}',
                    style: TextStyle(
                      color: isDeadlinePassed ? Colors.red[600] : Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Max score info
              Row(
                children: [
                  Icon(Icons.star_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Nilai Maksimal: ${assignment.maxScore}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),

              // Attachment indicator
              if (assignment.attachmentUrl != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.attach_file, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('Ada lampiran', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
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
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDeadlinePassed ? Colors.red[800] : Colors.blue[800],
        ),
      ),
    );
  }

  void _navigateToDetail(String assignmentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentAssignmentDetailPage(assignmentId: assignmentId),
      ),
    );
  }
}
