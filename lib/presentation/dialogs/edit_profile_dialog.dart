import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

// Diekstrak dari profile.dart
class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _namaController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _emailController = TextEditingController();
  
  // Student fields
  final _namaWaliController = TextEditingController();
  final _nomorWaliController = TextEditingController();
  final _alamatController = TextEditingController();
  
  // Mentor fields
  final _bidangKeilmuanController = TextEditingController();
  final _pekerjaanController = TextEditingController();

  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    // Load data dari provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      final authProvider = context.read<AuthProvider>();
      final profile = profileProvider.profile;
      
      if (profile != null) {
        _namaController.text = profile.fullName;
        _whatsappController.text = profile.phone ?? '';
        _tanggalLahirController.text = profile.birthDate ?? '';
        _emailController.text = authProvider.user?.email ?? '';
        
        // Student fields
        _namaWaliController.text = profile.parentName ?? '';
        _nomorWaliController.text = profile.parentPhone ?? '';
        _alamatController.text = profile.address ?? '';
        
        // Mentor fields
        _bidangKeilmuanController.text = profile.expertiseField ?? '';
        _pekerjaanController.text = profile.occupation ?? '';
        
        setState(() {
          _selectedGender = profile.gender;
        });
      }
    });
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          children: const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, {String? hint, TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Edit Profil", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Foto Profil", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () { /* Logika pilih file */ },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey.shade400),
                      elevation: 0,
                    ),
                    child: const Text("Choose File"),
                  ),
                  const SizedBox(width: 12),
                  const Text("No file chosen", style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),
              _buildLabel("Nama Lengkap"),
              _buildTextField(_namaController),
              const SizedBox(height: 16),
              _buildLabel("WhatsApp"),
              _buildTextField(_whatsappController, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildLabel("Jenis Kelamin"),
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                items: ['Perempuan', 'Laki-laki'].map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(),
                onChanged: (value) {
                  setState(() {_selectedGender = value;});
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel("Tanggal Lahir"),
              _buildTextField(_tanggalLahirController, keyboardType: TextInputType.datetime),
              const SizedBox(height: 16),
              const Text("Email", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
              ),
              const SizedBox(height: 16),
              
              // Conditional fields based on role
              Builder(
                builder: (context) {
                  final authProvider = context.read<AuthProvider>();
                  final userRole = authProvider.user?.role ?? 'student';
                  
                  if (userRole == 'student') {
                    // Student fields
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLabel("Alamat"),
                        _buildTextField(_alamatController, hint: "Masukkan alamat lengkap sesuai domisili", maxLines: 3),
                        const SizedBox(height: 16),
                        _buildLabel("Nama Orang Tua / Wali"),
                        _buildTextField(_namaWaliController, hint: "Nama lengkap orang tua atau wali"),
                        const SizedBox(height: 16),
                        _buildLabel("Nomor HP Orang Tua / Wali"),
                        _buildTextField(_nomorWaliController, hint: "Nomor HP orang tua atau wali", keyboardType: TextInputType.phone),
                      ],
                    );
                  } else {
                    // Mentor/Admin fields
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLabel("Bidang Keilmuan"),
                        _buildTextField(_bidangKeilmuanController, hint: "Contoh: Matematika, Fisika, Bahasa Indonesia"),
                        const SizedBox(height: 16),
                        _buildLabel("Pekerjaan"),
                        _buildTextField(_pekerjaanController, hint: "Contoh: Guru, Dosen, Profesional"),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.black54, side: BorderSide(color: Colors.grey.shade400)),
                    child: const Text("Batal"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      // Validasi input
                      if (_namaController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nama tidak boleh kosong'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Simpan profil
                      final profileProvider = context.read<ProfileProvider>();
                      final authProvider = context.read<AuthProvider>();
                      final userRole = authProvider.user?.role ?? 'student';
                      
                      // Base data
                      final data = {
                        'full_name': _namaController.text,
                        'phone': _whatsappController.text,
                        'gender': _selectedGender,
                        'birth_date': _tanggalLahirController.text,
                      };
                      
                      // Conditional data based on role
                      if (userRole == 'student') {
                        data['address'] = _alamatController.text;
                        data['parent_name'] = _namaWaliController.text;
                        data['parent_phone'] = _nomorWaliController.text;
                      } else {
                        data['expertise_field'] = _bidangKeilmuanController.text;
                        data['occupation'] = _pekerjaanController.text;
                      }

                      final success = await profileProvider.updateProfile(
                        authProvider.user!.id,
                        data,
                      );

                      if (!context.mounted) return;

                      if (success) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.green,
                            content: Text("Profil berhasil diperbarui"),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              profileProvider.errorMessage ?? 'Gagal memperbarui profil',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text("Simpan Perubahan"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

