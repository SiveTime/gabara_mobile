import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../layout/tutor_app_drawer.dart';
import 'profile_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/class/presentation/providers/class_provider.dart';

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
  void initState() {
    super.initState();
    // Fetch kelas mentor
    Future.microtask(() {
      Provider.of<ClassProvider>(context, listen: false).fetchMyClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final classProvider = Provider.of<ClassProvider>(context);

    if (authProvider.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final classCount = classProvider.classes.length;

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
      body: RefreshIndicator(
        onRefresh: () => classProvider.fetchMyClasses(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: containerMargin,
                ),
                child: _buildWelcomeSection(context),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: containerMargin,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        icon: Icons.class_,
                        title: 'Kelas Dibuat',
                        count: classProvider.isLoading ? '-' : '$classCount',
                        onTap: () => Navigator.pushNamed(context, '/class'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        icon: Icons.quiz_outlined,
                        title: 'Kuis Dibuat',
                        count: '0',
                        onTap: () => Navigator.pushNamed(context, '/quiz'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: containerMargin,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        icon: Icons.assignment_outlined,
                        title: 'Tugas Dibuat',
                        count: '0',
                        onTap: () => Navigator.pushNamed(context, '/assignments'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        icon: Icons.video_call_outlined,
                        title: 'Pertemuan',
                        count: '0',
                        onTap: () => Navigator.pushNamed(context, '/meetings'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Kelas Terbaru
              _buildSectionTitle(
                'Kelas Terbaru',
                padding: const EdgeInsets.symmetric(
                  horizontal: containerMargin,
                ),
              ),
              _buildRecentClassesSection(classProvider),
              const SizedBox(height: 16),
              _buildSectionTitle(
                'Tugas yang Perlu Dinilai',
                padding: const EdgeInsets.symmetric(
                  horizontal: containerMargin,
                ),
              ),
              _buildSectionWrapper(child: _buildPendingGradingSection()),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-class'),
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
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
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
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentClassesSection(ClassProvider classProvider) {
    if (classProvider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (classProvider.classes.isEmpty) {
      return _buildSectionWrapper(
        child: Column(
          children: [
            Icon(Icons.school_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text(
              'Belum ada kelas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            const Text(
              'Buat kelas pertama Anda',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Tampilkan maksimal 3 kelas terbaru
    final recentClasses = classProvider.classes.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: containerMargin),
      child: Column(
        children: [
          ...recentClasses.map(
            (classItem) => Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: ListTile(
                onTap: () => Navigator.pushNamed(
                  context,
                  '/class-detail',
                  arguments: classItem,
                ),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentOrange.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.class_, color: accentOrange),
                ),
                title: Text(
                  classItem.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  classItem.subjectName,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                trailing: classItem.classCode != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentBlue.withAlpha(20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          classItem.classCode!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: accentBlue,
                            letterSpacing: 1,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
          if (classProvider.classes.length > 3)
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/class'),
              child: const Text('Lihat Semua Kelas'),
            ),
        ],
      ),
    );
  }

  Widget _buildPendingGradingSection() {
    return Column(
      children: [
        Icon(
          Icons.assignment_turned_in_outlined,
          size: 40,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 8),
        const Text(
          'Tidak ada tugas yang perlu dinilai',
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}
