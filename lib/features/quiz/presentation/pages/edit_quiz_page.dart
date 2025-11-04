// lib/features/quiz/presentation/pages/edit_quiz_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/quiz_entity.dart';
import '../providers/quiz_provider.dart';
import '../widgets/quiz_option_widget.dart';
import 'quiz_result_page.dart';

class EditQuizPage extends StatefulWidget {
  final QuizEntity quiz;
  const EditQuizPage({super.key, required this.quiz});

  @override
  State<EditQuizPage> createState() => _EditQuizPageState();
}

class _EditQuizPageState extends State<EditQuizPage> {
  final Map<String, String> selectedAnswers = {}; // questionId -> optionId

  void _onSelect(String questionId, String optionId) {
    setState(() {
      selectedAnswers[questionId] = optionId;
    });
  }

  Future<void> _submit() async {
    final prov = context.read<QuizProvider>();
    final ok = await prov.submit(widget.quiz.id, selectedAnswers);
    if (!mounted) return;
    
    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => QuizResultPage(quiz: widget.quiz, answers: selectedAnswers)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal submit jawaban')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.quiz.questions;
    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(widget.quiz.description),
            const SizedBox(height: 12),
            ...questions.map((q) {
              // Try to handle both QuestionModel or QuestionEntity
              final questionId = (q is Map) ? q['id'].toString() : (q as dynamic).id.toString();
              final questionText = (q is Map) ? q['question'].toString() : (q as dynamic).question.toString();
              final options = (q is Map)
                  ? (q['options'] as List<dynamic>).cast<Map<String, dynamic>>()
                  : (q as dynamic).options as List<dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(questionText, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...options.map((opt) {
                        final optId = (opt is Map) ? opt['id'].toString() : (opt as dynamic).id.toString();
                        final optText = (opt is Map) ? opt['text'].toString() : (opt as dynamic).text.toString();
                        return QuizOptionWidget(
                          optionId: optId,
                          text: optText,
                          isSelected: selectedAnswers[questionId] == optId,
                          onTap: () => _onSelect(questionId, optId),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: selectedAnswers.isEmpty ? null : _submit,
              child: const Text('Submit Jawaban'),
            )
          ],
        ),
      ),
    );
  }
}
