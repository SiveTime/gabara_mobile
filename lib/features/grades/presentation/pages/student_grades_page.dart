// lib/features/grades/presentation/pages/student_grades_page.dart
// Requirements: 13.1-13.5

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/models/grade_model.dart';
import '../../domain/entities/grade_entity.dart';
import '../providers/grades_provider.dart';

/// Page to display student's grades dashboard with modern UI
/// **Validates: Requirements 13.1-13.5**
class StudentGradesPage extends StatefulWidget {
  const StudentGradesPage({super.key});

  @override
  State<StudentGradesPage> createState() => _StudentGradesPageState();
}

class _StudentGradesPageState extends State<StudentGradesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 3);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GradesProvider>().loadMyGrades();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Kelas Detail',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/grades/analytics');
            },
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Analisis Detail',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
              tabs: const [
                Tab(text: 'Kursus'),
                Tab(text: 'Peserta'),
                Tab(text: 'Diskusi'),
                Tab(text: 'Nilai'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Kursus Tab
          const Center(child: Text('Kursus Content')),
          // Peserta Tab
          const Center(child: Text('Peserta Content')),
          // Diskusi Tab
          const Center(child: Text('Diskusi Content')),
          // Nilai Tab (Main Content)
          _buildGradesContent(),
        ],
      ),
    );
  }

  Widget _buildGradesContent() {
    return Consumer<GradesProvider>(
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

        return RefreshIndicator(
          onRefresh: () => provider.loadMyGrades(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nilai Section
                _buildNilaiSection(provider),
                const SizedBox(height: 20),

                // Ringkasan Nilai Section
                _buildRingkasanNilaiSection(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build Nilai Section - Table of grades
  Widget _buildNilaiSection(GradesProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Nilai',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Item Penilaian',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Nilai',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Umpan Balik',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Table Rows
          if (provider.grades.isEmpty)
            _buildEmptyGradeRow()
          else
            ...provider.grades.take(5).map((grade) => _buildGradeRow(grade)),

          // Show more button if there are more grades
          if (provider.grades.length > 5)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: TextButton(
                  onPressed: () => _showAllGrades(context, provider.grades),
                  child: Text(
                    'Lihat Semua (${provider.grades.length})',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyGradeRow() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('Tugas 1', style: TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '-',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '-',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeRow(GradeModel grade) {
    final itemName =
        grade.itemTitle ??
        (grade.isQuizGrade
            ? 'Kuis ${grade.itemId.substring(0, 8)}'
            : 'Tugas ${grade.itemId.substring(0, 8)}');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(itemName, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${grade.score.toStringAsFixed(0)}/${grade.maxScore.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _getFeedbackText(grade.percentage),
              style: TextStyle(
                fontSize: 14,
                color: _getGradeColor(grade.percentage),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Ringkasan Nilai Section - Chart
  Widget _buildRingkasanNilaiSection(GradesProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with menu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ringkasan Nilai',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Icon(Icons.more_horiz, color: Colors.grey[600]),
              ],
            ),
          ),

          // Chart
          SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildGradesChart(provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradesChart(GradesProvider provider) {
    final quizAverage = provider.quizGrades.isNotEmpty
        ? GradeCalculator.calculateAverage(provider.quizGrades)
        : 0.0;
    final assignmentAverage = provider.assignmentGrades.isNotEmpty
        ? GradeCalculator.calculateAverage(provider.assignmentGrades)
        : 0.0;

    return Column(
      children: [
        // Chart area with proper grid alignment
        Expanded(
          child: Row(
            children: [
              // Y-axis labels with proper positioning
              SizedBox(
                width: 40,
                child: Stack(
                  children: [
                    // 100% label
                    Positioned(
                      top: 0,
                      right: 8,
                      child: Text(
                        '100',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                    // 75% label
                    Positioned(
                      top: 150 * 0.25,
                      right: 8,
                      child: Text(
                        '75',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                    // 50% label
                    Positioned(
                      top: 150 * 0.5,
                      right: 8,
                      child: Text(
                        '50',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                    // 25% label
                    Positioned(
                      top: 150 * 0.75,
                      right: 8,
                      child: Text(
                        '25',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                    // 0% label
                    Positioned(
                      bottom: 0,
                      right: 8,
                      child: Text(
                        '0',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              // Chart area with grid lines
              Expanded(
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Stack(
                    children: [
                      // Grid lines
                      ...List.generate(5, (index) {
                        final position = (150 * index / 4).toDouble();
                        return Positioned(
                          top: position,
                          left: 0,
                          right: 0,
                          child: Container(height: 1, color: Colors.grey[300]),
                        );
                      }),
                      // Bars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Assignment bar
                          _buildBar('Tugas', assignmentAverage, 150),
                          // Quiz bar
                          _buildBar('Kuis', quizAverage, 150),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // X-axis labels
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Tugas',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                'Kuis',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBar(String label, double value, double maxHeight) {
    // Scale percentage (0-100) to chart height
    final barHeight = (value / 100.0) * maxHeight;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: barHeight,
          decoration: BoxDecoration(
            color: Colors.blue[400],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ),
      ],
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
          Text(
            '${grade.score.toStringAsFixed(0)}/${grade.maxScore.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            '${grade.percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              color: _getGradeColor(grade.percentage),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllGrades(BuildContext context, List<GradeModel> grades) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Semua Nilai',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: grades.length,
                  itemBuilder: (context, index) {
                    final grade = grades[index];
                    return _buildGradeItem(grade);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFeedbackText(double percentage) {
    if (percentage >= 90) return 'Sangat Baik';
    if (percentage >= 80) return 'Baik';
    if (percentage >= 70) return 'Cukup';
    if (percentage >= 60) return 'Kurang';
    return 'Sangat Kurang';
  }

  Color _getGradeColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}
