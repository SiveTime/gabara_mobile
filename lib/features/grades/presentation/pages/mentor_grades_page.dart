// lib/features/grades/presentation/pages/mentor_grades_page.dart
// Requirements: 14.1-14.5

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/grades_provider.dart';
import 'student_grades_detail_page.dart';

/// Page to display mentor's view of class grades
/// **Validates: Requirements 14.1-14.5**
class MentorGradesPage extends StatefulWidget {
  const MentorGradesPage({super.key});

  @override
  State<MentorGradesPage> createState() => _MentorGradesPageState();
}

class _MentorGradesPageState extends State<MentorGradesPage> {
  List<Map<String, dynamic>> _myClasses = [];
  String? _selectedClassId;
  bool _isLoadingClasses = true;

  @override
  void initState() {
    super.initState();
    _loadMyClasses();
  }

  Future<void> _loadMyClasses() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('classes')
          .select('id, name')
          .eq('tutor_id', user.id)
          .eq('is_active', true)
          .order('name', ascending: true);

      setState(() {
        _myClasses = List<Map<String, dynamic>>.from(response);
        _isLoadingClasses = false;
        if (_myClasses.isNotEmpty && _selectedClassId == null) {
          _selectedClassId = _myClasses.first['id'];
          _loadClassGrades();
        }
      });
    } catch (e) {
      setState(() => _isLoadingClasses = false);
    }
  }

  void _loadClassGrades() {
    if (_selectedClassId != null) {
      context.read<GradesProvider>().loadClassGradesSummary(_selectedClassId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nilai Kelas')),
      body: Column(
        children: [
          // Class Selector
          _buildClassSelector(),
          const Divider(height: 1),
          // Student List
          Expanded(child: _buildStudentList()),
        ],
      ),
    );
  }

  Widget _buildClassSelector() {
    if (_isLoadingClasses) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_myClasses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Tidak ada kelas', style: TextStyle(color: Colors.grey[600])),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedClassId,
        decoration: const InputDecoration(
          labelText: 'Pilih Kelas',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: _myClasses.map((cls) {
          return DropdownMenuItem<String>(
            value: cls['id'],
            child: Text(cls['name']),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedClassId = value);
          _loadClassGrades();
        },
      ),
    );
  }

  Widget _buildStudentList() {
    return Consumer<GradesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.studentSummaries.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null && provider.studentSummaries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${provider.errorMessage}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadClassGrades,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (provider.studentSummaries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('Belum ada siswa atau nilai', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadClassGrades(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.studentSummaries.length,
            itemBuilder: (context, index) {
              final summary = provider.studentSummaries[index];
              return _buildStudentCard(summary);
            },
          ),
        );
      },
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> summary) {
    final studentName = summary['student_name'] ?? 'Unknown';
    final average = (summary['average'] as double?) ?? 0;
    final quizCount = summary['quiz_count'] ?? 0;
    final assignmentCount = summary['assignment_count'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToStudentDetail(summary),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar with grade
              CircleAvatar(
                radius: 28,
                backgroundColor: _getGradeColor(average),
                child: Text(
                  _getLetterGrade(average),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(width: 16),
              // Student info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(studentName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Rata-rata: ${average.toStringAsFixed(1)}%', style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildInfoChip(Icons.quiz, '$quizCount Quiz', Colors.purple),
                        const SizedBox(width: 8),
                        _buildInfoChip(Icons.assignment, '$assignmentCount Tugas', Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  void _navigateToStudentDetail(Map<String, dynamic> summary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentGradesDetailPage(
          studentId: summary['student_id'],
          studentName: summary['student_name'] ?? 'Unknown',
          classId: _selectedClassId!,
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
