import 'package:flutter/material.dart';

// Diekstrak dari profile.dart
class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _namaController = TextEditingController(text: 'Melati Kusuma');
  final _whatsappController = TextEditingController(text: '081234567897');
  final _tanggalLahirController = TextEditingController(text: '2000-01-01');
  final _emailController = TextEditingController(text: 'student4@example.com');
  final _namaWaliController = TextEditingController();
  final _nomorWaliController = TextEditingController();
  final _alamatController = TextEditingController();

  String? _selectedGender = 'Perempuan';

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
              _buildLabel("Nama Orang Tua / Wali"),
              _buildTextField(_namaWaliController, hint: "Nama lengkap orang tua atau wali"),
              const SizedBox(height: 16),
              _buildLabel("Nomor HP Orang Tua / Wali"),
              _buildTextField(_nomorWaliController, hint: "Nomor HP orang tua atau wali", keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildLabel("Alamat"),
              _buildTextField(_alamatController, hint: "Masukkan alamat lengkap sesuai domisili", maxLines: 3),
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
                    onPressed: () {
                      // Logika simpan profil
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text("Profil berhasil diperbarui"),
                        ),
                      );
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

