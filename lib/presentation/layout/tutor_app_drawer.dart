import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../pages/mentor_dashboard_page.dart';
import '../../features/class/presentation/pages/class_page.dart';
import '../../features/quiz/presentation/pages/quiz_list_page.dart';
import '../../features/meetings/presentation/pages/meeting_list_page.dart';
import '../../features/assignments/presentation/pages/assignment_list_page.dart';

class TutorAppDrawer extends StatelessWidget {
  final String? activeRoute;

  const TutorAppDrawer({super.key, this.activeRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: Container(
        color: primaryBlue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Logo
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/GabaraWhite.png',
                    height: 45,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      'GABARA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: accentOrange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'MENTOR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: <Widget>[
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    routeKey: 'dashboard',
                    onTap: () => _navigateTo(
                      context,
                      'dashboard',
                      const MentorDashboardPage(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.book_outlined,
                    title: 'Kelasku',
                    routeKey: 'class',
                    onTap: () =>
                        _navigateTo(context, 'class', const ClassPage()),
                  ),
                  const SizedBox(height: 12),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.quiz_outlined,
                    title: 'Kuis',
                    routeKey: 'quiz',
                    onTap: () =>
                        _navigateTo(context, 'quiz', const QuizListPage()),
                  ),
                  const SizedBox(height: 12),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.assignment_outlined,
                    title: 'Tugas',
                    routeKey: 'assignments',
                    onTap: () => _navigateTo(
                      context,
                      'assignments',
                      const AssignmentListPage(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.video_call_outlined,
                    title: 'Pertemuan',
                    routeKey: 'meetings',
                    onTap: () => _navigateTo(
                      context,
                      'meetings',
                      const MeetingListPage(),
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                "Versi 1.0.0",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String routeKey, Widget page) {
    Navigator.pop(context);
    if (activeRoute != routeKey) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    }
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String routeKey,
    required VoidCallback onTap,
  }) {
    final isActive = activeRoute == routeKey;

    return Container(
      decoration: BoxDecoration(
        color: isActive ? accentOrange : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
