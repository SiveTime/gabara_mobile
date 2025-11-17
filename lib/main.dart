import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- IMPORT BARU
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/dashboard_page.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/services/auth_service.dart';

Future<void> main() async { // <-- Ubah jadi 'async'
  WidgetsFlutterBinding.ensureInitialized(); // <-- Tambahkan ini

  // Inisialisasi Supabase
  await Supabase.initialize(
    // TODO: Ganti dengan URL dan Anon Key Supabase Anda
    url: 'https://URL_PROJECT_ANDA.supabase.co',
    anonKey: 'ANON_KEY_ANDA_DARI_SUPABASE',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- PERSIAPAN DEPENDENCY INJECTION (VERSI SUPABASE) ---
    // 1. Ambil Supabase client yang sudah diinisialisasi
    final supabaseClient = Supabase.instance.client;
    
    // 2. Buat AuthService dengan SupabaseClient
    // (Kita akan update file auth_service.dart selanjutnya)
    final authService = AuthService(supabaseClient);
    
    // 3. Buat AuthRepositoryImpl dengan AuthService
    final authRepository = AuthRepositoryImpl(authService);
    // ------------------------------------

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUser: LoginUser(authRepository),
            registerUser: RegisterUser(authRepository),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Gabara',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins', // Asumsi font global
        ),
        // Set rute awal ke HomePage (landing page)
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(), // home_page.dart
          '/login': (context) => const LoginPage(), // login_page.dart
          '/register': (context) => const RegisterPage(), // register_page.dart
          '/dashboard': (context) => const DashboardPage(), // dashboard_page.dart

          // Rute lain akan ditambahkan di sini saat halaman direfaktor
          // '/my-class': (context) => const ClassPage(),
        },
      ),
    );
  }
}