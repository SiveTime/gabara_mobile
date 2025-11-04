import 'package:flutter/material.dart';
import '../../../../presentation/dialogs/confirmation_dialog.dart';
import '../widgets/quiz_detail_view.dart';
import '../widgets/quiz_progress_view.dart';

// Ini adalah halaman kuis_page.dart yang sudah direfaktor.
// Widget _buildQuizDetailView dan _buildQuizInProgressView dipindahkan
// ke file-file terpisah dalam folder widgets/

class KuisPage extends StatefulWidget {
  const KuisPage({super.key});

  @override
  State<KuisPage> createState() => _KuisPageState();
}

class _KuisPageState extends State<KuisPage> {
  bool _isQuizStarted = false;

  void _startQuiz() {
    Navigator.of(context).pop(); // Tutup dialog
    setState(() {
      _isQuizStarted = true; // Mulai kuis
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Selamat mengerjakan! Waktu telah dimulai."),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showStartQuizConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: "Mulai Kuis?", 
          content: 'Waktu akan mulai berjalan setelah Anda menekan tombol "Mulai". Anda tidak dapat menjeda kuis ini.', 
          onConfirm: _startQuiz,
          confirmText: "Mulai",
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          _isQuizStarted ? 'Kuis Berlangsung' : 'Detail Kuis',
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                 GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text('Kelasku', style: TextStyle(color: Colors.blue))),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                const SizedBox(width: 8),
                const Text('Kuis 1', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
      body: _isQuizStarted 
        ? const QuizProgressView() // Widget yang sudah diekstrak
        : QuizDetailView(onStartQuiz: _showStartQuizConfirmationDialog), // Widget yang sudah diekstrak
    );
  }
}
