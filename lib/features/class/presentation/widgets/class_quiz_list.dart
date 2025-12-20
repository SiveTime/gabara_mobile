// lib/features/class/presentation/widgets/class_quiz_list.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../quiz/data/models/quiz_model.dart';
import '../../../quiz/data/services/quiz_service.dart';
import '../../../../core/constants/app_colors.dart';

/// Widget untuk menampilkan daftar quiz dalam sebuah kelas
class ClassQuizList extends StatefulWidget {
  final String classId;
  final bool isMentor;

  const ClassQuizList({
    super.key,
    required this.classId,
    this.isMentor = false,
  });

  @override
  State<ClassQuizList> createState() => _ClassQuizListState();
}

class _ClassQuizListState extends State<ClassQuizList> {
  late final QuizService _quizService;
  List<QuizModel> _quizzes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _quizService = QuizService(Supabase.instance.client);
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final quizzes = await _quizService.fetchQuizzesByClass(widget.classId);
      setState(() {
        // Filter: mentor sees all, student sees only published
        _quizzes = widget.isMentor
            ? quizzes
            : quizzes.where((q) => q.isPublished).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.quiz_outlined, color: primaryBlue, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Daftar Quiz',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_quizzes.isNotEmpty)
                Text(
                  '${_quizzes.length} quiz',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
            ],
          ),
        ),

        // Content
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_errorMessage != null)
          _buildErrorState()
        else if (_quizzes.isEmpty)
          _buildEmptyState()
        else
          _buildQuizList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.quiz_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            widget.isMentor
                ? 'Belum ada quiz untuk kelas ini'
                : 'Belum ada quiz yang tersedia',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          if (widget.isMentor) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/quiz/create'),
              icon: const Icon(Icons.add),
              label: const Text('Buat Quiz'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 12),
          Text(
            'Gagal memuat quiz',
            style: TextStyle(fontSize: 14, color: Colors.red.shade700),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: _loadQuizzes, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }

  Widget _buildQuizList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _quizzes.length,
      itemBuilder: (context, index) {
        final quiz = _quizzes[index];
        return _QuizListItem(
          quiz: quiz,
          isMentor: widget.isMentor,
          onTap: () => _navigateToQuizDetail(quiz),
        );
      },
    );
  }

  void _navigateToQuizDetail(QuizModel quiz) {
    if (widget.isMentor) {
      Navigator.pushNamed(context, '/quiz/detail', arguments: quiz.id);
    } else {
      Navigator.pushNamed(context, '/student/quiz/detail', arguments: quiz.id);
    }
  }
}

/// Widget item untuk setiap quiz dalam list
class _QuizListItem extends StatelessWidget {
  final QuizModel quiz;
  final bool isMentor;
  final VoidCallback? onTap;

  const _QuizListItem({required this.quiz, required this.isMentor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.quiz, color: primaryBlue, size: 24),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.help_outline,
                          '${quiz.questionCount} soal',
                        ),
                        const SizedBox(width: 12),
                        _buildInfoChip(
                          Icons.timer_outlined,
                          '${quiz.durationMinutes} menit',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status badge
              _buildStatusBadge(),

              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final isPublished = quiz.isPublished;
    final now = DateTime.now();

    // Debug logging
    debugPrint(
      'Quiz "${quiz.title}" status check:\n'
      '  isPublished: $isPublished\n'
      '  openAt: ${quiz.openAt}\n'
      '  closeAt: ${quiz.closeAt}\n'
      '  now: $now\n'
      '  isNotStarted: ${quiz.isNotStarted}\n'
      '  isEnded: ${quiz.isEnded}\n'
      '  isOpen: ${quiz.isOpen}',
    );

    // Draft status
    if (!isPublished) {
      return _buildBadge('Draf', Colors.grey.shade200, Colors.grey.shade700);
    }

    // Check quiz timing status
    if (quiz.isNotStarted) {
      return _buildBadge(
        'Belum Dibuka',
        Colors.blue.shade100,
        Colors.blue.shade700,
      );
    }

    if (quiz.isEnded) {
      return _buildBadge('Berakhir', Colors.red.shade100, Colors.red.shade700);
    }

    // Quiz is open
    if (quiz.isOpen) {
      return _buildBadge('Aktif', Colors.green.shade100, Colors.green.shade700);
    }

    // Fallback - should not reach here normally
    return _buildBadge(
      'Tertutup',
      Colors.orange.shade100,
      Colors.orange.shade700,
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
