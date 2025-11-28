import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../layout/tutor_app_drawer.dart';
import 'profile_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

const double containerPadding = 16.0;
const double containerMargin = 16.0;
const double borderRadius = 12.0;

class MentorDashboardPage extends StatefulWidget {
  const MentorDashboardPage({super.key});

  @override
  State<MentorDashboardPage> createState() => _MentorDashboardPageState();
}

class _MentorDashboardPageState extends State<MentorDashboardPage> {
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
      drawer: const TutorAppDrawer(activeRoute: 'dashboard'),
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
                      icon: Icons.class_,
                      title: 'Kelas Dibuat',
                      count: '0',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.question_mark,
                      title: 'Kuis Dibuat',
                      count: '0',
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
                      icon: Icons.assignment,
                      title: 'Tugas Dibuat',
                      count: '0',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.people,
                      title: 'Total Siswa',
                      count: '0',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(
              'Pengumuman',
              padding: const EdgeInsets.symmetric(horizontal: containerMargin),
            ),
            _buildSectionWrapper(child: _buildAnnouncementSection()),
            const SizedBox(height: 16),
            _buildSectionTitle(
              'Tugas yang Perlu Dinilai',
              padding: const EdgeInsets.symmetric(horizontal: containerMargin),
            ),
            _buildSectionWrapper(child: _buildPendingGradingSection()),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/create-class');
        },
        backgroundColor: accentBlue,
        icon: const Icon(Icons.add),
        label: const Text('Buat Kelas'),
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
              backgroundColor: Colors.grey,
              child: Text(
                user.name[0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(user.name),
            subtitle: const Text('Mentor'),
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
            'Mentor',
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
                color: accentBlue.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accentBlue, size: 24),
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

  Widget _buildAnnouncementSection() {
    return Column(
      children: [
        Image.asset(
          'assets/kosong.png',
          height: 150,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox(
              height: 150,
              child: Center(
                child: Icon(
                  Icons.notifications_off,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Tidak ada pengumuman',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Belum ada pengumuman yang tersedia.',
          style: TextStyle(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPendingGradingSection() {
    return const ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        'Tidak ada tugas yang perlu dinilai.',
        style: TextStyle(color: Colors.black54),
      ),
    );
  }
}
