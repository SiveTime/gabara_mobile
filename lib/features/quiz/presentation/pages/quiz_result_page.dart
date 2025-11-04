// lib/features/quiz/presentation/pages/quiz_result_page.dart
import 'package:flutter/material.dart';
import '../../domain/entities/quiz_entity.dart';

class QuizResultPage extends StatelessWidget {
  final QuizEntity quiz;
  final Map<String, String> answers; // questionId -> selectedOptionId

  const QuizResultPage({super.key, required this.quiz, required this.answers});

  @override
  Widget build(BuildContext context) {
    // For simplicity: show selected answers. Real app should compute score by comparing with correct flags.
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Kuis')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text('Quiz: ${quiz.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: quiz.questions.map((q) {
                  final qid = (q is Map) ? q['id'].toString() : (q as dynamic).id.toString();
                  final qtext = (q is Map) ? q['question'].toString() : (q as dynamic).question.toString();
                  final selectedId = answers[qid];
                  final options = (q is Map) ? (q['options'] as List<dynamic>) : (q as dynamic).options as List<dynamic>;

                  String selectedText = selectedId == null ? 'Belum memilih' : '';
                  for (final o in options) {
                    final oid = (o is Map) ? o['id'].toString() : (o as dynamic).id.toString();
                    final otext = (o is Map) ? o['text'].toString() : (o as dynamic).text.toString();
                    if (oid == selectedId) selectedText = otext;
                  }

                  return Card(
                    child: ListTile(
                      title: Text(qtext),
                      subtitle: Text('Jawaban: $selectedText'),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
