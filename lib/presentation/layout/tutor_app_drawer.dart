import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// Halaman-halaman ini perlu di-import dari lokasi baru mereka
// import '../../features/quiz/presentation/pages/edit_quiz_page.dart';
// import '../../features/class/presentation/pages/tutor_class_page.dart';
// import '../pages/tutor_dashboard_page.dart';

// Placeholder untuk halaman yang belum di-import
Widget getTutorDashboardPage() => const Scaffold(body: Center(child: Text("Tutor Dashboard Page")));
Widget getTutorClassPage() => const Scaffold(body: Center(child: Text("Tutor Class Page")));
Widget getTutorQuizPage() => const Scaffold(body: Center(child: Text("Tutor Quiz Page")));


class TutorAppDrawer extends StatelessWidget {
  final String? activeRoute;

  const TutorAppDrawer({super.key, this.activeRoute});

  @override
  Widget build(BuildContext context) {
    const String dashboardRoute = 'dashboard';
    const String classRoute = 'class';
    const String quizRoute = 'quiz';

    return Drawer(
      elevation: 0,
      child: Container(
        color: accentBlue,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Image.asset(
                    'assets/GabaraWhite.png',
                    height: 50,
                     errorBuilder: (context, error, stackTrace) =>
                        const Text('GARASI BELAJAR', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.dashboard,
              title: 'Dashboard',
              isActive: activeRoute == dashboardRoute,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => getTutorDashboardPage()),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildDrawerItem(
              context: context,
              icon: Icons.class_,
              title: 'Kelasku',
              isActive: activeRoute == classRoute,
              onTap: () {
                 Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => getTutorClassPage()),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildDrawerItem(
              context: context,
              icon: Icons.question_mark,
              title: 'Kuis',
              isActive: activeRoute == quizRoute,
              onTap: () {
                 Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => getTutorQuizPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? accentOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          onTap: onTap,
        ),
      ),
    );
  }
}
