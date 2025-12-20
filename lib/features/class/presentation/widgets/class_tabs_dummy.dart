import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'class_quiz_list.dart';
import 'class_meetings_list.dart';
import '../../../discussions/presentation/pages/discussion_list_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../class/presentation/providers/class_provider.dart';
import '../../../grades/presentation/providers/grades_provider.dart';
import '../../../grades/data/models/grade_model.dart';
import '../../../grades/domain/entities/grade_entity.dart';

// =================================================================
// TAB 1: KURSUS (QUIZ + MATERI & PERTEMUAN)
// =================================================================
class ClassCourseTab extends StatelessWidget {
  final String? classId;
  final bool isMentor;

  const ClassCourseTab({super.key, this.classId, this.isMentor = false});

  @override
  Widget build(BuildContext context) {
    // Jika classId null, tampilkan empty state
    if (classId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              "Materi Kursus",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Belum ada materi atau pertemuan.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Tampilkan layout dengan Quiz di atas dan Meetings di bawah
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Section 1: Daftar Quiz
          ClassQuizList(classId: classId!, isMentor: isMentor),

          const SizedBox(height: 24),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.grey.shade300),
          ),

          const SizedBox(height: 8),

          // Section 2: Daftar Pertemuan & Materi
          ClassMeetingsList(classId: classId!, isMentor: isMentor),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// =================================================================
// TAB 2: PESERTA - Real Data with Navigation
// =================================================================
class ClassParticipantsTab extends StatefulWidget {
  final String? classId;

  const ClassParticipantsTab({super.key, this.classId});

  @override
  State<ClassParticipantsTab> createState() => _ClassParticipantsTabState();
}

class _ClassParticipantsTabState extends State<ClassParticipantsTab> {
  @override
  void initState() {
    super.initState();
    if (widget.classId != null) {
      _loadMembers();
    }
  }

  void _loadMembers() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final classProvider = Provider.of<ClassProvider>(context, listen: false);
      classProvider.fetchClassMembers(widget.classId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.classId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              "Peserta Kelas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Belum ada peserta terdaftar.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Consumer<ClassProvider>(
      builder: (context, classProvider, child) {
        if (classProvider.isMembersLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (classProvider.classMembers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Peserta Kelas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Belum ada peserta terdaftar.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Show preview of members with "View All" button
        final members = classProvider.classMembers;
        final previewMembers = members.take(3).toList();

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Peserta Kelas (${members.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (members.length > 3)
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/class/members',
                            arguments: {
                              'classId': widget.classId!,
                              'className': 'Kelas',
                            },
                          );
                        },
                        child: const Text('Lihat Semua'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Preview list
                ...previewMembers.map(
                  (member) => _buildMemberPreviewCard(member),
                ),

                if (members.length > 3)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 12),
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/class/members',
                          arguments: {
                            'classId': widget.classId!,
                            'className': 'Kelas',
                          },
                        );
                      },
                      child: Text(
                        'Lihat ${members.length - 3} peserta lainnya',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMemberPreviewCard(member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: _getAvatarColor(member.initials),
          backgroundImage: member.profilePicture != null
              ? NetworkImage(member.profilePicture!)
              : null,
          child: member.profilePicture == null
              ? Text(
                  member.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                member.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            if (member.role == 'mentor')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Mentor',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(String initials) {
    final colors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.red.shade400,
      Colors.teal.shade400,
    ];

    final hash = initials.codeUnits.fold(0, (prev, curr) => prev + curr);
    return colors[hash % colors.length];
  }
}

// =================================================================
// TAB 3: DISKUSI - Integrated with DiscussionListPage
// =================================================================
class ClassDiscussionTab extends StatelessWidget {
  final String? classId;

  const ClassDiscussionTab({super.key, this.classId});

  @override
  Widget build(BuildContext context) {
    if (classId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              "Forum Diskusi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Belum ada diskusi yang dimulai.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Get user role and class name
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final isMentor = authProvider.user?.role == 'mentor';

    // Find class name from provider
    String className = 'Kelas';
    try {
      final classEntity = classProvider.classes.firstWhere(
        (c) => c.id == classId,
      );
      className = classEntity.name;
    } catch (_) {
      // Class not found in list, use default
    }

    return DiscussionListPage(
      classId: classId!,
      className: className,
      isMentor: isMentor,
    );
  }
}

// =================================================================
// TAB 4: NILAI - Dynamic Data from Database
// =================================================================
class ClassGradesTab extends StatefulWidget {
  final String? classId;

  const ClassGradesTab({super.key, this.classId});

  @override
  State<ClassGradesTab> createState() => _ClassGradesTabState();
}

class _ClassGradesTabState extends State<ClassGradesTab> {
  Map<String, dynamic>? gradesData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.classId != null) {
      _loadGrades();
    }
  }

  void _loadGrades() async {
    setState(() => isLoading = true);

    try {
      final gradesProvider = Provider.of<GradesProvider>(
        context,
        listen: false,
      );
      await gradesProvider.loadStudentGrades(widget.classId!);
      // Data akan diambil dari Consumer di build method
    } catch (e) {
      debugPrint('Error loading grades: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.classId == null) {
      return _buildEmptyState();
    }

    return Consumer<GradesProvider>(
      builder: (context, gradesProvider, child) {
        if (gradesProvider.isLoading || isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final quizGrades = gradesProvider.quizGrades;
        final assignmentGrades = gradesProvider.assignmentGrades;
        final allGrades = gradesProvider.allGrades;

        if (allGrades.isEmpty) {
          return _buildEmptyState();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grades Table
              _buildGradesTable(allGrades),

              const SizedBox(height: 24),

              // Grades Summary Chart
              _buildGradesSummary(quizGrades, assignmentGrades),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grade_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "Nilai",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Belum ada nilai yang tersedia.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildGradesTable(List<GradeModel> grades) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Nilai',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
                bottom: BorderSide(color: Colors.grey.shade200),
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
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Nilai',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
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
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Table Rows
          ...grades.map((grade) => _buildGradeRow(grade)),
        ],
      ),
    );
  }

  Widget _buildGradeRow(GradeModel grade) {
    final score = grade.score;
    final maxScore = grade.maxScore;
    final percentage = grade.percentage;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          // Item Name
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grade.itemTitle ?? (grade.isQuizGrade ? 'Kuis' : 'Tugas'),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  grade.isQuizGrade ? 'Kuis' : 'Tugas',
                  style: TextStyle(
                    fontSize: 12,
                    color: grade.isQuizGrade
                        ? Colors.blue.shade600
                        : Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Score
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Text(
                  '${score.toStringAsFixed(0)}/${maxScore.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getScoreColor(percentage),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Feedback
          Expanded(
            flex: 2,
            child: Text(
              _getFeedbackText(percentage),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradesSummary(
    List<GradeModel> quizGrades,
    List<GradeModel> assignmentGrades,
  ) {
    // Calculate averages using GradeCalculator
    final quizAverage = quizGrades.isNotEmpty
        ? GradeCalculator.calculateAverage(quizGrades)
        : 0.0;
    final assignmentAverage = assignmentGrades.isNotEmpty
        ? GradeCalculator.calculateAverage(assignmentGrades)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ringkasan Nilai',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.more_horiz, color: Colors.grey.shade400),
              ],
            ),

            const SizedBox(height: 24),

            // Chart Area with proper alignment
            SizedBox(
              height: 200,
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
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        // 75% label
                        Positioned(
                          top: 150 * 0.25,
                          right: 8,
                          child: Text(
                            '75',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        // 50% label
                        Positioned(
                          top: 150 * 0.5,
                          right: 8,
                          child: Text(
                            '50',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        // 25% label
                        Positioned(
                          top: 150 * 0.75,
                          right: 8,
                          child: Text(
                            '25',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        // 0% label
                        Positioned(
                          bottom: 0,
                          right: 8,
                          child: Text(
                            '0',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
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
                              child: Container(
                                height: 1,
                                color: Colors.grey[300],
                              ),
                            );
                          }),
                          // Bars
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildBarChart(
                                'Tugas',
                                assignmentAverage,
                                Colors.green.shade400,
                              ),
                              _buildBarChart(
                                'Kuis',
                                quizAverage,
                                Colors.blue.shade400,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

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
        ),
      ),
    );
  }

  Widget _buildBarChart(String label, double value, Color color) {
    final height = (value / 100) * 150; // Max height 150px

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Value label
        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),

        // Bar
        Container(
          width: 40,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),

        const SizedBox(height: 8),

        // Label
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 75) return Colors.green.shade600;
    if (percentage >= 50) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  String _getFeedbackText(double percentage) {
    if (percentage >= 90) return 'Sangat Baik';
    if (percentage >= 80) return 'Baik';
    if (percentage >= 70) return 'Cukup';
    if (percentage >= 60) return 'Kurang';
    return 'Sangat Kurang';
  }
}
