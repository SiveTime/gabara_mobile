// lib/features/quiz/presentation/widgets/quiz_option_widget.dart
import 'package:flutter/material.dart';

class QuizOptionWidget extends StatelessWidget {
  final String optionId;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const QuizOptionWidget({
    super.key,
    required this.optionId,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black54),
                color: isSelected ? Colors.blue : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
