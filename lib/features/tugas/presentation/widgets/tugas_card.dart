import 'package:flutter/material.dart';
import '../../data/models/tugas_model.dart';

class TugasCard extends StatelessWidget {
  final TugasModel tugas;
  final bool isTutor;
  final VoidCallback onTap;

  const TugasCard({
    super.key,
    required this.tugas,
    required this.onTap,
    this.isTutor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(tugas.title),
        subtitle: Text('Deadline: ${tugas.deadlineFormatted}'),
        trailing: isTutor
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  // confirm delete
                },
              )
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
