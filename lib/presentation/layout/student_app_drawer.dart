import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../pages/dashboard_page.dart';
// import '../pages/profile_page.dart'; // Nanti ini akan diganti ke class_page

Widget getStudentClassPagePlaceholder() => Scaffold(
  appBar: AppBar(title: const Text("Kelasku (Placeholder)")),
  body: const Center(child: Text("Class Page")),
);


class StudentAppDrawer extends StatelessWidget {
  final String? activeRoute;

  const StudentAppDrawer({super.key, this.activeRoute});

  @override
  Widget build(BuildContext context) {
    const String dashboardRoute = 'dashboard';
    const String classRoute = 'class';

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
                    'assets/GabaraWhite.png', // Pastikan path ini benar
                    height: 50,
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
                Navigator.pop(context); // Tutup drawer
                if (activeRoute != dashboardRoute) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardPage()),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            _buildDrawerItem(
              context: context,
              icon: Icons.class_,
              title: 'Kelasku',
              isActive: activeRoute == classRoute,
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                // TODO: Ganti ini ke halaman ClassPage sesungguhnya saat sudah dibuat
                // Untuk sementara, ini akan navigasi ke placeholder
                if (activeRoute != classRoute) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => getStudentClassPagePlaceholder()),
                  );
                }
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

