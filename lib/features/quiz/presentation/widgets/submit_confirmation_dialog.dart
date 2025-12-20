// lib/features/quiz/presentation/widgets/submit_confirmation_dialog.dart
// Requirements: 5.1, 5.2, 5.3, 5.4

import 'package:flutter/material.dart';

class SubmitConfirmationDialog extends StatelessWidget {
  final int answeredCount;
  final int totalQuestions;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const SubmitConfirmationDialog({
    super.key,
    required this.answeredCount,
    required this.totalQuestions,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05, // 5% margin from screen edges
        vertical: screenHeight * 0.1, // 10% margin from top/bottom
      ),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 400, // Maximum width for larger screens
          maxHeight: screenHeight * 0.8, // Maximum 80% of screen height
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Konfirmasi Pengiriman Jawaban',
                        style: TextStyle(
                          fontSize: screenWidth < 360 ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onCancel,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Answered count
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: screenWidth < 360 ? 13 : 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'Kamu telah menjawab '),
                      TextSpan(
                        text: '$answeredCount',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' dari '),
                      TextSpan(
                        text: '$totalQuestions',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' soal.'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Warning message
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: screenWidth < 360 ? 13 : 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                    children: const [
                      TextSpan(text: 'Setelah kamu menekan '),
                      TextSpan(
                        text: 'Kirim Jawaban',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            ', jawaban tidak bisa diubah. Pastikan semuanya sudah benar sebelum mengirim.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons - Stack vertically on very small screens
                screenWidth < 320
                    ? Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: onCancel,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Kembali',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: onSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Kirim Jawaban',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onCancel,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Kembali',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: screenWidth < 360 ? 13 : 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Kirim Jawaban',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: screenWidth < 360 ? 13 : 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
