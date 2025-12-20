// lib/features/quiz/presentation/pages/student_quiz_detail_page.dart
// Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/date_formatter.dart';
import '../providers/student_quiz_provider.dart';
import '../widgets/start_quiz_dialog.dart';
import '../widgets/attempt_history_card.dart';
import 'student_quiz_taking_page.dart';

class StudentQuizDetailPage extends StatefulWidget {
  final String quizId;

  const StudentQuizDetailPage({super.key, required this.quizId});

  @override
  State<StudentQuizDetailPage> createState() => _StudentQuizDetailPageState();
}

class _StudentQuizDetailPageState extends State<StudentQuizDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentQuizProvider>().loadQuizWithAttempts(widget.quizId);
    });
  }

  void _showStartQuizDialog() {
    final provider = context.read<StudentQuizProvider>();
    final quiz = provider.currentQuiz;
    if (quiz == null) return;

    final isResume = provider.hasInProgressAttempt();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StartQuizDialog(
        quizTitle: quiz.title,
        duration: quiz.durationMinutes,
        openAt: quiz.openAt,
        closeAt: quiz.closeAt,
        isResume: isResume,
        onStart: () async {
          // Pop dialog first
          if (mounted) {
            Navigator.pop(dialogContext);
          }

          // Start or resume quiz attempt
          final success = await provider.startQuizAttempt();

          // Check mounted before accessing context
          if (success && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: provider,
                  child: const StudentQuizTakingPage(),
                ),
              ),
            );
          }
        },
        onCancel: () => Navigator.pop(dialogContext),
      ),
    );
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
          onPressed: () => Navigator.pop(context),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<StudentQuizProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final quiz = provider.currentQuiz;
          if (quiz == null) {
            return const Center(child: Text('Quiz tidak ditemukan'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumb
                _buildBreadcrumb(quiz.title),

                // Quiz info card
                _buildQuizInfoCard(provider),

                // Attempt history section
                _buildAttemptHistorySection(provider),

                const SizedBox(height: 16),
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
          Expanded(
            child: Text(
              quizTitle.length > 20
                  ? '${quizTitle.substring(0, 20)}...'
                  : quizTitle,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizInfoCard(StudentQuizProvider provider) {
    final quiz = provider.currentQuiz!;
    final canStartOrResume = provider.canStartOrResumeQuiz();
    final cannotStartReason = provider.getCannotStartReason();
    final buttonText = provider.getStartButtonText();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              quiz.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              quiz.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),

            // Badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusBadge(quiz.isPublished),
                _buildBadge(
                  QuizDateFormatter.formatDuration(quiz.durationMinutes),
                ),
                _buildBadge(
                  QuizDateFormatter.formatQuestionCount(quiz.questionCount),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Student status
            Row(
              children: [
                const Text('Status Anda: ', style: TextStyle(fontSize: 14)),
                Text(
                  provider.getStudentStatus(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: provider.getStudentStatus() == 'Selesai'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Start/Resume Quiz button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canStartOrResume ? _showStartQuizDialog : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: provider.hasInProgressAttempt()
                      ? Colors.orange
                      : Colors.blue,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  canStartOrResume
                      ? buttonText
                      : (cannotStartReason ?? 'Tidak tersedia'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: canStartOrResume
                        ? Colors.white
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quiz details
            _buildInfoRow(
              'Dibuka',
              QuizDateFormatter.formatQuizDate(quiz.openAt),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Ditutup',
              QuizDateFormatter.formatQuizDate(quiz.closeAt),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Kesempatan Mengerjakan',
              QuizDateFormatter.formatAttempts(quiz.attemptsAllowed),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Waktu Pengerjaan',
              QuizDateFormatter.formatDuration(quiz.durationMinutes),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttemptHistorySection(StudentQuizProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riwayat Mengerjakan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (provider.attemptHistory.isEmpty)
              Text(
                'Anda belum pernah mengerjakan kuis ini. Tekan Mulai untuk memulai attempt.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ...provider.attemptHistory.asMap().entries.map((entry) {
                final index = entry.key;
                final attempt = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AttemptHistoryCard(
                    attemptNumber: provider.attemptHistory.length - index,
                    attempt: attempt,
                    onViewResult: () {
                      // Navigate to result page
                      Navigator.pushNamed(
                        context,
                        '/quiz/result',
                        arguments: {
                          'attemptId': attempt.id,
                          'quizId': provider.currentQuiz!.id,
                        },
                      );
                    },
                  ),
                );
              }),

            if (provider.attemptHistory.isNotEmpty)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to full history
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Lihat Selengkapnya',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isPublished) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPublished ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isPublished ? null : Border.all(color: Colors.grey.shade400),
      ),
      child: Text(
        isPublished ? 'Diterbitkan' : 'Draf',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isPublished ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
