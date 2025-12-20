import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../features/class/presentation/pages/class_page.dart';

class StudentAppDrawer extends StatelessWidget {
  final String? activeRoute;

  const StudentAppDrawer({super.key, this.activeRoute});

  @override
  Widget build(BuildContext context) {
    const String dashboardRoute = 'dashboard';
    const String classRoute = 'class';

    return Drawer(
      elevation: 0,
      // Container utama berwarna Biru Penuh
      child: Container(
        color:
            primaryBlue, // Menggunakan warna biru utama (sesuai app_colors.dart)
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
                  const SizedBox(height: 8),
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
                    icon:
                        Icons.dashboard_outlined, // Icon dashboard kotak-kotak
                    title: 'Dashboard',
                    isActive: activeRoute == dashboardRoute,
                    onTap: () => _navigateTo(
                      context,
                      dashboardRoute,
                      '/student-dashboard',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.book_outlined, // Icon buku untuk kelas
                    title: 'Kelasku',
                    isActive: activeRoute == classRoute,
                    onTap: () => _navigateTo(
                      context,
                      classRoute,
                      null, // Will use MaterialPageRoute for ClassPage
                    ),
                  ),
                ],
              ),
            ),

            // Footer (Optional: Version info)
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

  void _navigateTo(BuildContext context, String routeKey, String? namedRoute) {
    Navigator.pop(context); // Close drawer
    if (activeRoute != routeKey) {
      // For dashboard, use pushAndRemoveUntil to reset navigation stack
      if (routeKey == 'dashboard') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/student-dashboard',
          (route) => false,
        );
      } else {
        // For other pages, use push to maintain back navigation to dashboard
        if (namedRoute != null) {
          Navigator.pushNamed(context, namedRoute);
        } else {
          // For ClassPage, use MaterialPageRoute
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ClassPage()),
          );
        }
      }
    }
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        // Jika aktif: Orange, Jika tidak: Transparan
        color: isActive
            ? const Color(0xFFF57C00)
            : Colors
                  .transparent, // Hardcoded orange matching mockup or use accentOrange
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
                Icon(
                  icon,
                  // Icon selalu putih karena background drawer biru
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white, // Teks selalu putih
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
