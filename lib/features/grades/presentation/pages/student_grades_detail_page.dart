// lib/features/grades/presentation/pages/student_grades_detail_page.dart
// Requirements: 13.1-13.5

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/grade_model.dart';
import '../providers/grades_provider.dart';

/// Page to display detailed grades for a specific student in a class
/// **Validates: Requirements 13.1-13.5**
class StudentGradesDetailPage extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String classId;

  const StudentGradesDetailPage({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.classId,
  });

  @override
  State<StudentGradesDetailPage> createState() => _StudentGradesDetailPageState();
}

class _StudentGradesDetailPageState extends State<StudentGradesDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GradesProvider>().loadStudentGrades(widget.studentId, widget.classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nilai - ${widget.studentName}')),
      body: Consumer<GradesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.grades.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.grades.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadStudentGrades(widget.studentId, widget.classId),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (provider.grades.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grade_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Belum ada nilai', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadStudentGrades(widget.studentId, widget.classId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Card
                  _buildSummaryCard(provider),
                  const SizedBox(height: 24),

                  // Quiz Grades Section
                  if (provider.quizGrades.isNotEmpty) ...[
                    _buildSectionHeader('Quiz', Icons.quiz, Colors.purple, provider.quizGrades.length),
                    const SizedBox(height: 8),
                    ...provider.quizGrades.map((grade) => _buildGradeCard(grade)),
                    const SizedBox(height: 16),
                  ],

                  // Assignment Grades Section
                  if (provider.assignmentGrades.isNotEmpty) ...[
                    _buildSectionHeader('Tugas', Icons.assignment, Colors.orange, provider.assignmentGrades.length),
                    const SizedBox(height: 8),
                    ...provider.assignmentGrades.map((grade) => _buildGradeCard(grade)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(GradesProvider provider) {
    final average = provider.classAverage;
    final letterGrade = _getLetterGrade(average);

    return Card(
      color: _getGradeColor(average).withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: _getGradeColor(average),
              child: Text(letterGrade, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.studentName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Rata-rata: ${average.toStringAsFixed(1)}%', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatChip('${provider.quizCount} Quiz', Colors.purple),
                      const SizedBox(width: 8),
                      _buildStatChip('${provider.assignmentCount} Tugas', Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color, int count) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Text('$count item', style: TextStyle(fontSize: 12, color: color)),
        ),
      ],
    );
  }

  Widget _buildGradeCard(GradeModel grade) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getGradeColor(grade.percentage),
          child: Text(_getLetterGrade(grade.percentage), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(grade.itemTitle ?? (grade.isQuizGrade ? 'Quiz' : 'Tugas')),
        subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(grade.recordedAt)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${grade.score.toStringAsFixed(0)}/${grade.maxScore.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${grade.percentage.toStringAsFixed(1)}%', style: TextStyle(fontSize: 12, color: _getGradeColor(grade.percentage))),
          ],
        ),
      ),
    );
  }

  String _getLetterGrade(double percentage) {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'E';
  }

  Color _getGradeColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}
