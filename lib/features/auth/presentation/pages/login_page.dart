import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:gabara_mobile/core/widgets/common_button.dart';
// HAPUS: import 'package:gabara_mobile/core/constants/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    return Scaffold(
      // Kita tidak pakai AppBar agar bisa full-screen background
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image
          Image.asset(
            'assets/login.jpg', // Pastikan path ini benar
            fit: BoxFit.cover,
            // Error handling jika gambar tidak termuat
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.grey[200]);
            },
          ),
          // 2. Overlay Gelap
          Container(
            // PERBAIKAN 1: 'withOpacity' diganti 'withAlpha'
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
                          'Login',
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
                              // Email
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                  ),
                                ),
                                validator: (v) => v!.isEmpty
                                    ? 'Email tidak boleh kosong'
                                    : null,
                                keyboardType: TextInputType.emailAddress,
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
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
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
                                validator: (v) => v!.isEmpty
                                    ? 'Password tidak boleh kosong'
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              // Lupa Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // TODO: Implementasi lupa password
                                  },
                                  child: const Text('Lupa Password?'),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Tombol Login
                              provider.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : // Di dalam method build atau widget terpisah
                                    CommonButton(
                                      // Atau ElevatedButton
                                      label: 'Masuk',
                                      // ... di dalam onPressed tombol LOGIN
                                      onPressed: () async {
                                        // 1. Validasi Input dasar
                                        final email = _emailController.text
                                            .trim(); // Pastikan controller sudah didefinisikan
                                        final password = _passwordController
                                            .text
                                            .trim();

                                        if (email.isEmpty || password.isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Email dan password wajib diisi',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        // 2. Panggil Provider Login
                                        final authProvider =
                                            Provider.of<AuthProvider>(
                                              context,
                                              listen: false,
                                            );

                                        // Tampilkan loading (opsional, jika button support loading state)
                                        // authProvider.setLoading(true);

                                        final success = await authProvider
                                            .login(email, password);

                                        if (!context.mounted)
                                          return; // Cek apakah widget masih aktif

                                        if (success) {
                                          // 3. Redirect ke Dashboard
                                          // Karena AuthProvider sudah menyimpan data user & role,
                                          // Dashboard nanti tinggal membacanya.
                                          Navigator.pushReplacementNamed(
                                            context,
                                            '/dashboard',
                                          );
                                        } else {
                                          // 4. Tampilkan Error
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                authProvider.errorMessage ??
                                                    'Login gagal',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                              // ... widget loading indicator jika authProvider.isLoading == true
                              const SizedBox(height: 16),
                              // Link ke Register
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Belum punya akun?'),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/register');
                                    },
                                    child: const Text('Registrasi'),
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
