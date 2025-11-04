import 'package:flutter/material.dart';
import 'quiz_option_widget.dart'; // Import widget opsi yang sudah dibuat

// Diekstrak dari kuis_page.dart
// Ini adalah tampilan SAAT kuis sedang berlangsung.
class QuizProgressView extends StatefulWidget {
  const QuizProgressView({super.key});

  @override
  State<QuizProgressView> createState() => _QuizProgressViewState();
}

class _QuizProgressViewState extends State<QuizProgressView> {
  String? _selectedOption; // State untuk mengelola pilihan

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Pertanyaan 1 dari 5', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Kuis 1: Pemahaman Teks'),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                // TODO: Hubungkan ini dengan timer provider
                child: Row(
                  children: const [
                    Icon(Icons.timer_outlined, size: 18, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('14:52', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
          const Divider(height: 32),
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Apa fungsi utama dari Bahasa Indonesia sesuai dengan Sumpah Pemuda?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    // Menggunakan QuizOptionWidget yang reusable
                    QuizOptionWidget(
                      optionId: 'A',
                      text: 'Bahasa pergaulan antar suku.',
                      isSelected: _selectedOption == 'A',
                      onTap: () => setState(() => _selectedOption = 'A'),
                    ),
                    QuizOptionWidget(
                      optionId: 'B',
                      text: 'Bahasa resmi kenegaraan.',
                      isSelected: _selectedOption == 'B',
                      onTap: () => setState(() => _selectedOption = 'B'),
                    ),
                    QuizOptionWidget(
                      optionId: 'C',
                      text: 'Bahasa persatuan.',
                      isSelected: _selectedOption == 'C',
                      onTap: () => setState(() => _selectedOption = 'C'),
                    ),
                    QuizOptionWidget(
                      optionId: 'D',
                      text: 'Bahasa pengantar pendidikan.',
                      isSelected: _selectedOption == 'D',
                      onTap: () => setState(() => _selectedOption = 'D'),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(onPressed: () {}, child: const Text('Sebelumnya')),
                        ElevatedButton(onPressed: () {}, child: const Text('Selanjutnya')),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
