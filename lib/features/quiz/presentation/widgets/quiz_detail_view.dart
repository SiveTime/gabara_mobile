import 'package:flutter/material.dart';

// Diekstrak dari kuis_page.dart
// Ini adalah tampilan SEBELUM kuis dimulai.
class QuizDetailView extends StatelessWidget {
  final VoidCallback onStartQuiz;

  const QuizDetailView({super.key, required this.onStartQuiz});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          'Kuis 1: Pemahaman Teks',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: onStartQuiz,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Mulai'),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Kuis ini dirancang untuk menguji pemahaman Anda terkait konsep-konsep dasar dalam teks yang berkaitan dengan materi sebelumnya.',
                    style: TextStyle(height: 1.5, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildTag('published', Colors.green),
                      const SizedBox(width: 8),
                      _buildTag('15 menit', Colors.blue),
                      const SizedBox(width: 8),
                      _buildTag('5 soal', Colors.orange),
                    ],
                  ),
                  const Divider(height: 32),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(3),
                    },
                    children: [
                      _buildInfoTableRow('Status Anda', 'Belum mengerjakan'),
                      _buildInfoTableRow('Dibuka', '14 Oktober 2025, 19.17'),
                      _buildInfoTableRow('Ditutup', '24 Oktober 2025, 19.17'),
                      _buildInfoTableRow('Attempts Allowed', '1'),
                      _buildInfoTableRow('Waktu Pengerjaan', '15 menit'),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard('Attempt Anda', 'Anda belum memulai kuis ini. Tekan Mulai untuk memulai attempt.'),
          const SizedBox(height: 16),
          _buildInfoCard('Riwayat Attempts', 'Belum ada riwayat attempt.'),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25), // 0.1 opacity = 25 alpha (255 * 0.1)
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: HSLColor.fromColor(color).withLightness(0.3).toColor(), 
          fontSize: 12, 
          fontWeight: FontWeight.w500
        ),
      ),
    );
  }

  TableRow _buildInfoTableRow(String title, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            Text(content, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}