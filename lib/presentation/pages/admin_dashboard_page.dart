import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import 'profile_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

const double containerPadding = 16.0;
const double containerMargin = 16.0;
const double borderRadius = 12.0;

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context);

    if (provider.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildAdminDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Image.asset('assets/GabaraColor.png', height: 30),
        centerTitle: true,
        actions: [_buildProfilePopupMenu()],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: containerMargin),
              child: _buildWelcomeSection(context),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: containerMargin),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.people,
                      title: 'Total User',
                      count: '0',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.school,
                      title: 'Total Mentor',
                      count: '0',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: containerMargin),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.person,
                      title: 'Total Siswa',
                      count: '0',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.class_,
                      title: 'Total Kelas',
                      count: '0',
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(
              'Manajemen Sistem',
              padding: const EdgeInsets.symmetric(horizontal: containerMargin),
            ),
            _buildSectionWrapper(child: _buildManagementSection()),
            const SizedBox(height: 16),
            _buildSectionTitle(
              'Aktivitas Terbaru',
              padding: const EdgeInsets.symmetric(horizontal: containerMargin),
            ),
            _buildSectionWrapper(child: _buildActivitySection()),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: accentBlue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/GabaraWhite.png',
                  height: 40,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'GABARA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Admin Panel',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Manajemen User'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to user management
            },
          ),
          ListTile(
            leading: const Icon(Icons.class_),
            title: const Text('Manajemen Kelas'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to class management
            },
          ),
          ListTile(
            leading: const Icon(Icons.subject),
            title: const Text('Manajemen Mata Pelajaran'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to subject management
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Pengaturan'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePopupMenu() {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    final user = provider.user!;

    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit_profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        } else if (value == 'logout') {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          provider.logout();
        }
      },
      icon: const Icon(Icons.more_vert, color: Colors.black),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          enabled: false,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red,
              child: Text(
                user.name[0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(user.name),
            subtitle: const Text('Administrator'),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'edit_profile',
          child: ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Edit Profil'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: ListTile(leading: Icon(Icons.logout), title: Text('Keluar')),
        ),
      ],
    );
  }

  Widget _buildSectionWrapper({required Widget child, EdgeInsets? padding}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: containerMargin),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(containerPadding),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {EdgeInsets? padding}) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    final user = provider.user!;

    return Container(
      padding: const EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: lightGreyBackground.withAlpha(128),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat datang, ${user.name}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Administrator',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(containerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementSection() {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.people, color: accentBlue),
          title: const Text('Kelola User'),
          subtitle: const Text('Tambah, edit, atau hapus user'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Navigate to user management
          },
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.class_, color: accentBlue),
          title: const Text('Kelola Kelas'),
          subtitle: const Text('Atur kelas dan enrollment'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Navigate to class management
          },
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.subject, color: accentBlue),
          title: const Text('Kelola Mata Pelajaran'),
          subtitle: const Text('Tambah atau edit mata pelajaran'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Navigate to subject management
          },
        ),
      ],
    );
  }

  Widget _buildActivitySection() {
    return const ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        'Belum ada aktivitas terbaru.',
        style: TextStyle(color: Colors.black54),
      ),
    );
  }
}
