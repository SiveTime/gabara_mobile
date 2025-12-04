import 'package:flutter/material.dart';

/// Widget untuk menampilkan status badge (Open/Closed)
class StatusBadge extends StatelessWidget {
  final bool isClosed;
  final double? fontSize;

  const StatusBadge({super.key, required this.isClosed, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isClosed ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isClosed ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Text(
        isClosed ? 'Closed' : 'Open',
        style: TextStyle(
          color: isClosed ? Colors.red.shade700 : Colors.green.shade700,
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
