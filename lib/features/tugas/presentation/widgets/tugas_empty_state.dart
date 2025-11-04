import 'package:flutter/material.dart';

class TugasEmptyState extends StatelessWidget {
  const TugasEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Belum ada tugas yang tersedia',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}