// lib/features/assignments/presentation/widgets/assignment_card.dart
// Requirements: 6.1-6.6

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/assignment_model.dart';

/// Card widget to display assignment information
/// **Validates: Requirements 6.1-6.6**
class AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  final int? submissionCount;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AssignmentCard({
    super.key,
    required this.assignment,
    this.submissionCount,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = assignment.deadline.isBefore(DateTime.now());
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      assignment.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusBadge(isExpired),
                ],
              ),
              if (assignment.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  assignment.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Deadline: ${DateFormat('dd MMM yyyy, HH:mm').format(assignment.deadline)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isExpired ? Colors.red : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.star,
                    'Max: ${assignment.maxScore}',
                    Colors.amber,
                  ),
                  const SizedBox(width: 8),
                  if (submissionCount != null)
                    _buildInfoChip(
                      Icons.assignment_turned_in,
                      '$submissionCount dikumpulkan',
                      Colors.blue,
                    ),
                  const Spacer(),
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onEdit,
                      tooltip: 'Edit',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: onDelete,
                      tooltip: 'Hapus',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isExpired) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isExpired ? Colors.red[100] : Colors.green[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isExpired ? 'Tertutup' : 'Aktif',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isExpired ? Colors.red[800] : Colors.green[800],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }
}
