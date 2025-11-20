import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Widget Tombol Custom
import '../../../../core/widgets/common_button.dart';

// Import AuthProvider
import '../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Key untuk validasi form
  final _formKey = GlobalKey<FormState>();

  // Controller untuk menangkap input user
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _hpController = TextEditingController(); // Controller No HP
  final _tanggalLahirController =
      TextEditingController(); // Controller Tanggal Lahir

  // Variabel state
  bool _obscureText = true; // Untuk sembunyikan password
  String? _selectedGender; // Untuk menyimpan pilihan Gender
  String? _selectedRole; // Untuk menyimpan pilihan Role

  @override
  void dispose() {
    // Bersihkan controller saat halaman ditutup agar tidak bocor memori
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _hpController.dispose();
    _tanggalLahirController.dispose();
    super.dispose();
  }

  // Fungsi untuk memunculkan Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(
        2005,
      ), // Default tahun awal (misal asumsi umur siswa)
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        // Format tanggal menjadi YYYY-MM-DD agar sesuai standar database
        _tanggalLahirController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil instance AuthProvider dari context
    final provider = context.watch<AuthProvider>();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image
          Image.asset(
            'assets/registrasi.jpg',
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => Container(color: Colors.grey),
          ),
          // 2. Overlay Gelap
          Container(color: Colors.black.withOpacity(0.4)),
          // 3. Konten Form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Judul
                          const Text(
                            'Registrasi',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // 1. Nama Lengkap
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Lengkap',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Nama tidak boleh kosong'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // 2. Email
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty)
                                return 'Email tidak boleh kosong';
                              if (!RegExp(
                                r'^[^@]+@[^@]+\.[^@]+',
                              ).hasMatch(value)) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 3. Password
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscureText,
                            validator: (value) {
                              if (value!.isEmpty)
                                return 'Password tidak boleh kosong';
                              if (value.length < 6)
                                return 'Password minimal 6 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // 4. No HP
                          TextFormField(
                            controller: _hpController,
                            decoration: const InputDecoration(
                              labelText: 'No HP',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) => value!.isEmpty
                                ? 'No HP tidak boleh kosong'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // 5. Tanggal Lahir
                          TextFormField(
                            controller: _tanggalLahirController,
                            decoration: InputDecoration(
                              labelText: 'Tanggal Lahir',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () => _selectDate(context),
                              ),
                            ),
                            readOnly: true,
                            validator: (value) => value!.isEmpty
                                ? 'Tanggal lahir tidak boleh kosong'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // 6. Gender
                          DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Laki-laki',
                                child: Text('Laki-laki'),
                              ),
                              DropdownMenuItem(
                                value: 'Perempuan',
                                child: Text('Perempuan'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Pilih gender' : null,
                          ),

                          const SizedBox(height: 16),

                          // 7. Role
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'Role',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'student',
                                child: Text('Student'),
                              ),
                              DropdownMenuItem(
                                value: 'mentor',
                                child: Text('Mentor'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Pilih role' : null,
                          ),

                          const SizedBox(height: 24),

                          // Tombol Registrasi
                          CommonButton(
                            label: provider.isLoading
                                ? 'Mendaftarkan...'
                                : 'Registrasi',
                            onPressed: provider.isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      provider
                                          .register(
                                            _nameController.text, // 1. Nama
                                            _emailController.text, // 2. Email
                                            _passwordController
                                                .text, // 3. Password
                                            _hpController.text, // 4. No HP
                                            _selectedGender!, // 5. Gender
                                            _tanggalLahirController
                                                .text, // 6. Tgl Lahir
                                            _selectedRole!, // 7. Role
                                          )
                                          .then((success) {
                                            // Cek Hasil (Sukses / Gagal)
                                            if (success) {
                                              // Jika Sukses -> Pindah ke Dashboard
                                              Navigator.pushReplacementNamed(
                                                context,
                                                '/dashboard',
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Registrasi berhasil!',
                                                  ),
                                                ),
                                              );
                                            } else {
                                              // Jika Gagal
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    provider.errorMessage ??
                                                        'Registrasi gagal',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          });
                                    }
                                  },
                          ),

                          const SizedBox(height: 16),

                          // Link Login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Sudah punya akun?'),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                  ); // Balik ke halaman sebelumnya (Login)
                                },
                                child: const Text('Login'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
