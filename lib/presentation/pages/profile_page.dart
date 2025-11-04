import 'package:flutter/material.dart';
import '../layout/student_app_drawer.dart';
import '../dialogs/edit_profile_dialog.dart';
import '../dialogs/change_password_dialog.dart';

//==================================================================
//== HALAMAN UTAMA PROFIL
//==================================================================
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFE0E0E0),
              child: Text('MK', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF424242))),
            ),
            const SizedBox(height: 16),
            const Text('Melati Kusuma', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('student', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
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
            _buildInfoRow('Nama Lengkap', 'Melati Kusuma'),
            _buildInfoRow('Email', 'student4@example.com'),
            _buildInfoRow('WhatsApp', '081234567897'),
            _buildInfoRow('Alamat', '-'),
            _buildInfoRow('Nama Orang Tua / Wali', '-'),
            _buildInfoRow('Nomor HP Orang Tua / Wali', '-'),
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