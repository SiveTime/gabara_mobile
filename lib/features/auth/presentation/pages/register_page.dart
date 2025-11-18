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
  final _tanggalLahirController = TextEditingController(); // Controller Tanggal Lahir

  // Variabel state
  bool _obscureText = true; // Untuk sembunyikan password
  String? _selectedGender; // Untuk menyimpan pilihan Gender

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
      initialDate: DateTime(2005), // Default tahun awal (misal asumsi umur siswa)
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
          
          // 2. Overlay Hitam Transparan (Supaya tulisan terbaca)
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
                          // Tombol Back
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.maybePop(context),
                            ),
                          ),

                          // Logo
                          Center(
                            child: Image.asset(
                              'assets/GabaraColor.png',
                              height: 40,
                              errorBuilder: (c, e, s) => const Text('Gabara',
                                  style: TextStyle(
                                      fontSize: 24, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          const Text(
                            'Registrasi',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 24),

                          // --- INPUT FIELDS ---

                          // 1. Nama Lengkap
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Lengkap',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12))),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),

                          // 2. Email
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12))),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Email wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),

                          // 3. No HP (Yang sebelumnya error karena hilang)
                          TextFormField(
                            controller: _hpController,
                            decoration: const InputDecoration(
                              labelText: 'No HP',
                              prefixIcon: Icon(Icons.phone_android),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12))),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'No HP wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),

                          // 4. Jenis Kelamin Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: const InputDecoration(
                              labelText: 'Jenis Kelamin',
                              prefixIcon: Icon(Icons.wc),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12))),
                            ),
                            items: ['Laki-laki', 'Perempuan']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedGender = v),
                            validator: (v) => v == null ? 'Pilih jenis kelamin' : null,
                          ),
                          const SizedBox(height: 16),

                          // 5. Tanggal Lahir
                          TextFormField(
                            controller: _tanggalLahirController,
                            readOnly: true, // Tidak bisa diketik manual, harus lewat picker
                            decoration: const InputDecoration(
                              labelText: 'Tanggal Lahir',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12))),
                            ),
                            onTap: () => _selectDate(context),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Tanggal lahir wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),

                          // 6. Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12))),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () =>
                                    setState(() => _obscureText = !_obscureText),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 6)
                                ? 'Password minimal 6 karakter'
                                : null,
                          ),
                          const SizedBox(height: 24),

                          // --- TOMBOL ACTION ---
                          
                          // Tampilkan Loading jika sedang proses
                          provider.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : CommonButton(
                                  label: 'Daftar',
                                  onPressed: () async {
                                    // Validasi Form
                                    if (_formKey.currentState!.validate()) {
                                      final scaffoldMsg = ScaffoldMessenger.of(context);
                                      final nav = Navigator.of(context);

                                      // PERBAIKAN DISINI:
                                      // Memanggil fungsi register dengan 6 Parameter Lengkap
                                      await provider.register(
                                        _nameController.text,           // 1. Nama
                                        _emailController.text,          // 2. Email
                                        _passwordController.text,       // 3. Password
                                        _hpController.text,             // 4. No HP
                                        _selectedGender!,               // 5. Gender
                                        _tanggalLahirController.text,   // 6. Tgl Lahir
                                      );

                                      // Cek Hasil (Sukses / Gagal)
                                      if (provider.failure != null) {
                                        // Jika Gagal
                                        scaffoldMsg.showSnackBar(
                                          SnackBar(
                                            content: Text(provider.failure!.message),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      } else if (provider.user != null) {
                                        // Jika Sukses -> Pindah ke Dashboard
                                        nav.pushReplacementNamed('/dashboard');
                                      }
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
                                  Navigator.pop(context); // Balik ke halaman sebelumnya (Login)
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