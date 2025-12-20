// lib/features/grades/presentation/pages/grades_analytics_page.dart
// Comprehensive analytics page for grades with multiple views

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/grade_model.dart';
import '../providers/grades_provider.dart';
import '../widgets/grades_analytics_dashboard.dart';

class GradesAnalyticsPage extends StatefulWidget {
  const GradesAnalyticsPage({super.key});

  @override
  State<GradesAnalyticsPage> createState() => _GradesAnalyticsPageState();
}

class _GradesAnalyticsPageState extends State<GradesAnalyticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          'Analisis Nilai',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
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
                Tab(text: 'Dashboard'),
                Tab(text: 'Tren'),
                Tab(text: 'Laporan'),
              ],
            ),
          ),
        ),
      ),
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

          return TabBarView(
            controller: _tabController,
            children: [
              // Dashboard Tab
              _buildDashboardTab(provider),
              // Trends Tab
              _buildTrendsTab(provider),
              // Reports Tab
              _buildReportsTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDashboardTab(GradesProvider provider) {
    return GradesAnalyticsDashboard(
      grades: provider.grades,
      gradesByClass: provider.gradesByClass,
      studentName: _getStudentName(),
      studentId: _getStudentId(),
    );
  }

  Widget _buildTrendsTab(GradesProvider provider) {
    if (provider.grades.isEmpty) {
      return _buildEmptyState('Belum ada data untuk analisis tren');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance over time
          _buildPerformanceOverTimeCard(provider),
          const SizedBox(height: 20),

          // Subject comparison
          _buildSubjectComparisonCard(provider),
          const SizedBox(height: 20),

          // Monthly breakdown
          _buildMonthlyBreakdownCard(provider),
        ],
      ),
    );
  }

  Widget _buildReportsTab(GradesProvider provider) {
    if (provider.grades.isEmpty) {
      return _buildEmptyState('Belum ada data untuk membuat laporan');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Export options
          _buildExportOptionsCard(provider),
          const SizedBox(height: 20),

          // Summary statistics
          _buildSummaryStatisticsCard(provider),
          const SizedBox(height: 20),

          // Detailed breakdown
          _buildDetailedBreakdownCard(provider),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceOverTimeCard(GradesProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performa dari Waktu ke Waktu',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Add performance timeline visualization here
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('Timeline Chart akan ditampilkan di sini'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectComparisonCard(GradesProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perbandingan Mata Pelajaran',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...provider.gradesByClass.entries.map((entry) {
            final className = entry.value.isNotEmpty
                ? entry.value.first.className ?? 'Unknown'
                : 'Unknown';
            final average = entry.value.isNotEmpty
                ? provider.grades
                          .where((g) => g.classId == entry.key)
                          .fold(0.0, (sum, g) => sum + g.percentage) /
                      entry.value.length
                : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      className,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: LinearProgressIndicator(
                      value: average / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getGradeColor(average),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${average.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getGradeColor(average),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMonthlyBreakdownCard(GradesProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Breakdown Bulanan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Group grades by month and show statistics
          ..._getMonthlyStats(provider.grades).entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(fontSize: 14)),
                  Row(
                    children: [
                      Text(
                        '${entry.value['count']} nilai',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${entry.value['average'].toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getGradeColor(entry.value['average']),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExportOptionsCard(GradesProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Laporan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Export to PDF functionality will be handled by the analytics dashboard
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Export to Excel functionality will be handled by the analytics dashboard
                  },
                  icon: const Icon(Icons.table_chart),
                  label: const Text('Export Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatisticsCard(GradesProvider provider) {
    final totalGrades = provider.grades.length;
    final averageScore = provider.currentAverage;
    final quizCount = provider.quizCount;
    final assignmentCount = provider.assignmentCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik Ringkasan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Total Nilai', totalGrades.toString()),
              ),
              Expanded(
                child: _buildStatItem(
                  'Rata-rata',
                  '${averageScore.toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatItem('Quiz', quizCount.toString())),
              Expanded(
                child: _buildStatItem('Tugas', assignmentCount.toString()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDetailedBreakdownCard(GradesProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Breakdown Detail',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Show detailed breakdown by class
          ...provider.gradesByClass.entries.map((entry) {
            final className = entry.value.isNotEmpty
                ? entry.value.first.className ?? 'Unknown'
                : 'Unknown';
            final classGrades = entry.value;

            return ExpansionTile(
              title: Text(className),
              subtitle: Text('${classGrades.length} nilai'),
              children: classGrades.map((grade) {
                return ListTile(
                  dense: true,
                  title: Text(
                    grade.itemTitle ?? (grade.isQuizGrade ? 'Quiz' : 'Tugas'),
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: Text(
                    '${grade.percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _getGradeColor(grade.percentage),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Map<String, Map<String, dynamic>> _getMonthlyStats(List<GradeModel> grades) {
    final Map<String, List<GradeModel>> gradesByMonth = {};

    for (final grade in grades) {
      final monthKey =
          '${grade.recordedAt.year}-${grade.recordedAt.month.toString().padLeft(2, '0')}';
      gradesByMonth[monthKey] ??= [];
      gradesByMonth[monthKey]!.add(grade);
    }

    final Map<String, Map<String, dynamic>> monthlyStats = {};
    gradesByMonth.forEach((month, monthGrades) {
      final average =
          monthGrades.fold(0.0, (sum, g) => sum + g.percentage) /
          monthGrades.length;
      monthlyStats[month] = {'count': monthGrades.length, 'average': average};
    });

    return monthlyStats;
  }

  Color _getGradeColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getStudentName() {
    // Get from user profile or return default
    return 'Student'; // This should be fetched from user profile
  }

  String _getStudentId() {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.id ?? 'unknown';
  }
}
