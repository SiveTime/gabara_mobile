import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layout/student_app_drawer.dart';
import '../dialogs/edit_profile_dialog.dart';
import '../dialogs/change_password_dialog.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

//==================================================================
//== HALAMAN UTAMA PROFIL
//==================================================================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load profile saat page dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final profileProvider = context.read<ProfileProvider>();
      
      if (authProvider.user != null) {
        profileProvider.fetchProfile(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // --- PERUBAHAN 1: Menggunakan StudentAppDrawer ---
      // Kita tidak beri 'activeRoute' agar tidak ada yang ter-highlight
      drawer: const StudentAppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black54),
        title: Image.asset(
          'assets/GabaraColor.png',
          height: 30,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black54),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBreadcrumb(context),
              const SizedBox(height: 24),
              _buildProfileCard(context),
              const SizedBox(height: 24),
              _buildPersonalInfoCard(),
              const SizedBox(height: 24),
              _buildChangePasswordCard(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- PERUBAHAN 2: _buildAppDrawer DIHAPUS ---
  // (Metode _buildAppDrawer sudah tidak ada di sini)
  
  // --- WIDGET-WIDGET LOKAL (DARI FILE LAMA) ---

  Widget _buildBreadcrumb(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            // Kembali ke halaman dashboard
            Navigator.pop(context);
          },
          // --- PERUBAHAN 3: Navigasi Breadcrumb ---
          child: Text('Dashboard', style: TextStyle(color: Colors.grey[600])),
        ),
        const SizedBox(width: 8),
        Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[600]),
        const SizedBox(width: 8),
        const Text('Profil', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    
    if (profileProvider.isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final profile = profileProvider.profile;
    final user = authProvider.user;
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFE0E0E0),
              backgroundImage: profile?.avatarUrl != null 
                ? NetworkImage(profile!.avatarUrl!) 
                : null,
              child: profile?.avatarUrl == null
                ? Text(
                    profile?.fullName.substring(0, 2).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF424242),
                    ),
                  )
                : null,
            ),
            const SizedBox(height: 16),
            Text(
              profile?.fullName ?? 'Loading...',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user?.role ?? 'student',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                // --- PERUBAHAN 4: Memanggil dialog reusable ---
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const EditProfileDialog(); // <-- Dari file import
                  },
                );
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;
    final userRole = authProvider.user?.role ?? 'student';
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informasi Pribadi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildInfoRow('Nama Lengkap', profile?.fullName ?? '-'),
            _buildInfoRow('Email', authProvider.user?.email ?? '-'),
            _buildInfoRow('WhatsApp', profile?.phone ?? '-'),
            _buildInfoRow('Gender', profile?.gender ?? '-'),
            _buildInfoRow('Tanggal Lahir', profile?.birthDate ?? '-'),
            
            // Conditional: Student vs Mentor
            if (userRole == 'student') ...[
              _buildInfoRow('Alamat', profile?.address ?? '-'),
              _buildInfoRow('Nama Orang Tua / Wali', profile?.parentName ?? '-'),
              _buildInfoRow('Nomor HP Orang Tua / Wali', profile?.parentPhone ?? '-'),
            ] else if (userRole == 'mentor' || userRole == 'admin') ...[
              _buildInfoRow('Bidang Keilmuan', profile?.expertiseField ?? '-'),
              _buildInfoRow('Pekerjaan', profile?.occupation ?? '-'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChangePasswordCard(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ganti Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Atur ulang password akun kamu untuk keamanan.', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // --- PERUBAHAN 5: Memanggil dialog reusable ---
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const ChangePasswordDialog(); // <-- Dari file import
                    });
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Ubah'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// --- PERUBAHAN 6: CLASS DIALOG DIHAPUS ---
// (Class EditProfileDialog dan ChangePasswordDialog sudah tidak ada di sini)