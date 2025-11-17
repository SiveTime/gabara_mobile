import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:gabara_mobile/core/widgets/common_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  // --- TAMBAHAN CONTROLLER ---
  final _hpController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  // --------------------------
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  // --- TAMBAHAN STATE ---
  String? _selectedGender;
  // --------------------

  // --- TAMBAHAN: FUNGSI UNTUK DATE PICKER ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000), // Tanggal awal yang muncul
      firstDate: DateTime(1950), // Batas tahun paling awal
      lastDate: DateTime.now(), // Batas tahun paling akhir (hari ini)
    );
    if (pickedDate != null) {
      setState(() {
        // Format tanggal manual YYYY-MM-DD
        _tanggalLahirController.text =
            "${pickedDate.year.toString()}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // --- TAMBAHAN: DISPOSE CONTROLLER BARU ---
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _hpController.dispose(); // <-- Ditambahkan
    _tanggalLahirController.dispose(); // <-- Ditambahkan
    _passwordController.dispose();
    super.dispose();
  }
  // ---------------------------------

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image
          Image.asset(
            'assets/registrasi.jpg', // Gambar untuk registrasi
            fit: BoxFit.cover,
            // Error handling jika gambar tidak termuat
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.grey[200]);
            },
          ),
          // 2. Overlay Gelap
          Container(
            color: Colors.black.withAlpha(102), // 0.4 opacity
          ),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tombol Back di dalam Card
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.maybePop(context),
                          ),
                        ),
                        // Logo
                        Image.asset(
                          'assets/GabaraColor.png', // Logo berwarna
                          height: 40,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(height: 40);
                          },
                        ),
                        const SizedBox(height: 16),
                        // Judul
                        const Text(
                          'Registrasi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Nama Lengkap
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Nama Lengkap',
                                  prefixIcon: Icon(Icons.person_outline),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Nama tidak boleh kosong'
                                    : null,
                                keyboardType: TextInputType.name,
                              ),
                              const SizedBox(height: 16),
                              // Email
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Email tidak boleh kosong'
                                    : null,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),

                              // --- FIELD BARU: NO HP ---
                              TextFormField(
                                controller: _hpController,
                                decoration: const InputDecoration(
                                  labelText: 'No Hp',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'No Hp tidak boleh kosong'
                                    : null,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),

                              // --- FIELD BARU: JENIS KELAMIN ---
                              DropdownButtonFormField<String>(
                                value: _selectedGender,
                                decoration: const InputDecoration(
                                  labelText: 'Pilih Jenis Kelamin',
                                  prefixIcon: Icon(Icons.wc_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                ),
                                hint: const Text('Pilih Jenis Kelamin'),
                                items: ['Laki-laki', 'Perempuan']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                },
                                validator: (v) => (v == null)
                                    ? 'Jenis kelamin harus dipilih'
                                    : null,
                              ),
                              const SizedBox(height: 16),

                              // --- FIELD BARU: TANGGAL LAHIR ---
                              TextFormField(
                                controller: _tanggalLahirController,
                                decoration: const InputDecoration(
                                  labelText: 'Tanggal Lahir',
                                  prefixIcon: Icon(Icons.calendar_today_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                ),
                                readOnly: true, // <-- Penting!
                                onTap: () {
                                  // Memanggil date picker
                                  _selectDate(context);
                                },
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Tanggal lahir tidak boleh kosong'
                                    : null,
                              ),
                              const SizedBox(height: 16),

                              // Password
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Password tidak boleh kosong'
                                    : null,
                              ),
                              const SizedBox(height: 24),
                              // Tombol Daftar
                              provider.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : CommonButton(
                                      label: 'Daftar',
                                      onPressed: () async {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          // Simpan context
                                          final scaffoldMessenger =
                                              ScaffoldMessenger.of(context);
                                          final navigator =
                                              Navigator.of(context);

                                          // Ambil semua data (meski belum semua dikirim)
                                          final name = _nameController.text;
                                          final email = _emailController.text;
                                          final password =
                                              _passwordController.text;
                                          // final noHp = _hpController.text;
                                          // final jenisKelamin = _selectedGender;
                                          // final tanggalLahir = _tanggalLahirController.text;

                                          // (Saat ini provider.register HANYA menerima 3 data,
                                          // jadi kita kirim 3 itu dulu. Nanti ini bisa di-update
                                          // jika provider-nya sudah di-upgrade)

                                          await provider.register(
                                            name,
                                            email,
                                            password,
                                          );

                                          if (provider.failure != null) {
                                            scaffoldMessenger.showSnackBar(
                                              SnackBar(
                                                content: Text(provider
                                                    .failure!.message),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          } else if (provider.user != null) {
                                            navigator.pushReplacementNamed(
                                                '/dashboard');
                                          }
                                        }
                                      },
                                    ),
                              const SizedBox(height: 16),
                              // Link ke Login
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Sudah punya akun?'),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // Kembali ke login
                                    },
                                    child: const Text('Login'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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