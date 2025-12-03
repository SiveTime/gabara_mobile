// lib/features/grades/presentation/pages/student_grades_page.dart
// Requirements: 13.1-13.5

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/grade_model.dart';
import '../../domain/entities/grade_entity.dart';
import '../providers/grades_provider.dart';

/// Page to display student's grades dashboard
/// **Validates: Requirements 13.1-13.5**
class StudentGradesPage extends StatefulWidget {
  const StudentGradesPage({super.key});

  @override
  State<StudentGradesPage> createState() => _StudentGradesPageState();
}

class _StudentGradesPageState extends State<StudentGradesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GradesProvider>().loadMyGrades();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nilai Saya')),
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
                    onPressed: () => provider.loadMyGrades(),
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
            onRefresh: () => provider.loadMyGrades(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GPA Summary Card
                  _buildGPASummaryCard(provider),
                  const SizedBox(height: 24),

                  // Statistics Row
                  _buildStatisticsRow(provider),
                  const SizedBox(height: 24),

                  // Grades by Class
                  const Text('Nilai per Kelas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...provider.gradesByClass.entries.map((entry) => _buildClassGradesSection(entry.key, entry.value)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGPASummaryCard(GradesProvider provider) {
    final gpa = provider.overallGPA;
    final average = provider.currentAverage;
    final letterGrade = _getLetterGrade(average);

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // GPA Circle
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getGradeColor(average),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(gpa.toStringAsFixed(1), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Text('GPA', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rata-rata: ${average.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Grade: $letterGrade', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                  const SizedBox(height: 4),
                  Text('Total ${provider.totalItems} item dinilai', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsRow(GradesProvider provider) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Quiz', provider.quizCount, Icons.quiz, Colors.purple)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Tugas', provider.assignmentCount, Icons.assignment, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Lulus', provider.passingGrades.length, Icons.check_circle, Colors.green)),
      ],
    );
  }

  Widget _buildStatCard(String label, int count, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildClassGradesSection(String classId, List<GradeModel> grades) {
    final className = grades.isNotEmpty ? (grades.first.className ?? 'Kelas') : 'Kelas';
    final classAverage = GradeCalculator.calculateAverage(grades);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(className, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Rata-rata: ${classAverage.toStringAsFixed(1)}% • ${grades.length} item'),
        leading: CircleAvatar(
          backgroundColor: _getGradeColor(classAverage),
          child: Text(_getLetterGrade(classAverage), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        children: grades.map((grade) => _buildGradeItem(grade)).toList(),
      ),
    );
  }

  Widget _buildGradeItem(GradeModel grade) {
    return ListTile(
      leading: Icon(
        grade.isQuizGrade ? Icons.quiz : Icons.assignment,
        color: grade.isQuizGrade ? Colors.purple : Colors.orange,
      ),
      title: Text(grade.itemTitle ?? (grade.isQuizGrade ? 'Quiz' : 'Tugas')),
      subtitle: Text(DateFormat('dd MMM yyyy').format(grade.recordedAt)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${grade.score.toStringAsFixed(0)}/${grade.maxScore.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('${grade.percentage.toStringAsFixed(1)}%', style: TextStyle(fontSize: 12, color: _getGradeColor(grade.percentage))),
        ],
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
