// lib/features/quiz/presentation/pages/student_quiz_result_page.dart
// Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 7.1, 7.2, 7.3, 7.4, 7.5

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/quiz_attempt_model.dart';
import '../../utils/date_formatter.dart';
import '../providers/student_quiz_provider.dart';
import '../widgets/question_result_card.dart';
import '../widgets/score_summary_modal.dart';

class StudentQuizResultPage extends StatefulWidget {
  final String? attemptId;

  const StudentQuizResultPage({super.key, this.attemptId});

  @override
  State<StudentQuizResultPage> createState() => _StudentQuizResultPageState();
}

class _StudentQuizResultPageState extends State<StudentQuizResultPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.attemptId != null) {
        context.read<StudentQuizProvider>().loadAttemptResult(
          widget.attemptId!,
        );
      }
      // Show score summary modal after quiz submission
      _showScoreSummary();
    });
  }

  void _showScoreSummary() {
    final provider = context.read<StudentQuizProvider>();
    final attempt = provider.currentAttempt;
    final quiz = provider.currentQuiz;

    if (attempt != null && quiz != null && attempt.isFinished) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ScoreSummaryModal(
          quizTitle: quiz.title,
          score: attempt.score ?? 0,
          questions: quiz.questionModels,
          answers: attempt.answerModels,
          onClose: () => Navigator.pop(context),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Go back to quiz detail
            Navigator.popUntil(context, (route) {
              return route.settings.name == '/quiz/detail' || route.isFirst;
            });
          },
        ),
        title: Image.asset(
          'assets/GabaraColor.png',
          height: 40,
          errorBuilder: (context, error, stackTrace) => const Text(
            'GARASI BELAJAR',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<StudentQuizProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final attempt = provider.currentAttempt;
          final quiz = provider.currentQuiz;

          if (attempt == null || quiz == null) {
            return const Center(child: Text('Data tidak ditemukan'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumb
                _buildBreadcrumb(quiz.title),

                // Page title
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Riwayat Attempt',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                // Attempt summary card
                _buildAttemptSummaryCard(attempt, quiz),

                // Question results
                _buildQuestionResults(provider, quiz, attempt),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBreadcrumb(String quizTitle) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to student dashboard instead of first route
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/student-dashboard',
                  (route) => false,
                );
              },
              child: const Text('Home', style: TextStyle(color: Colors.blue)),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            const Text('Kelasku', style: TextStyle(color: Colors.blue)),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            Text(
              quizTitle.length > 15
                  ? '${quizTitle.substring(0, 15)}...'
                  : quizTitle,
              style: const TextStyle(color: Colors.blue),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
            const Text(
              'Riwayat',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttemptSummaryCard(dynamic attempt, dynamic quiz) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz title and timestamps
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '1',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mulai Mengerjakan: ${QuizDateFormatter.formatQuizDate(attempt.startedAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (attempt.finishedAt != null)
                        Text(
                          'Selesai Mengerjakan: ${QuizDateFormatter.formatQuizDate(attempt.finishedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Score and status
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SCORE',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${attempt.score ?? 0}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    attempt.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Mulai Mengerjakan',
                    QuizDateFormatter.formatQuizDate(attempt.startedAt),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow('Status', attempt.status),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Selesai Mengerjakan',
                    attempt.finishedAt != null
                        ? QuizDateFormatter.formatQuizDate(attempt.finishedAt)
                        : '-',
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Waktu Pengerjaan',
                    attempt.formattedDuration,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildQuestionResults(
    StudentQuizProvider provider,
    dynamic quiz,
    dynamic attempt,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...quiz.questionModels.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;

            // Find student's answer for this question safely
            StudentAnswerModel? studentAnswer;
            try {
              studentAnswer = attempt.answerModels.firstWhere(
                (a) => a.questionId == question.id,
              );
            } catch (e) {
              // No answer found for this question
              studentAnswer = null;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: QuestionResultCard(
                questionNumber: index + 1,
                question: question,
                studentAnswer: studentAnswer,
              ),
            );
          }),
        ],
      ),
    );
  }
}
