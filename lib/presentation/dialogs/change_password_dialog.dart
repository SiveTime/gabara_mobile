import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';

// Diekstrak dari profile.dart
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isObscure,
    VoidCallback onPressed,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            suffixIcon: IconButton(
              icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
              onPressed: onPressed,
            ),
          ),
        ),
      ],
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
        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Ganti Password", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 20),
              _buildPasswordField("Password Lama", _oldPasswordController, _obscureOld, () => setState(() => _obscureOld = !_obscureOld)),
              const SizedBox(height: 16),
              _buildPasswordField("Password Baru", _newPasswordController, _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
              const SizedBox(height: 16),
              _buildPasswordField("Konfirmasi Password Baru", _confirmPasswordController, _obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
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
                      if (_oldPasswordController.text.isEmpty ||
                          _newPasswordController.text.isEmpty ||
                          _confirmPasswordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Semua field harus diisi'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (_newPasswordController.text.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password baru minimal 6 karakter'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (_newPasswordController.text != _confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password baru tidak cocok'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Ubah password
                      final profileProvider = context.read<ProfileProvider>();
                      
                      final success = await profileProvider.changePassword(
                        _oldPasswordController.text,
                        _newPasswordController.text,
                      );

                      if (!context.mounted) return;

                      if (success) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Password berhasil diubah"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              profileProvider.errorMessage ?? 'Gagal mengubah password',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text("Simpan"),
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

