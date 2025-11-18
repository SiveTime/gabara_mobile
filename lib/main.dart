import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/dashboard_page.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Import halaman lain yang sudah direfaktor (placeholder)
// import 'presentation/pages/dashboard_page.dart';
// import 'features/class/presentation/pages/class_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://amtbfcezkbjooqpoifpm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFtdGJmY2V6a2Jqb29xcG9pZnBtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzODU4ODYsImV4cCI6MjA3ODk2MTg4Nn0.5vGCNl_ojinzSuvM7O9aYM9zhT6YWnLdKzfmfD2iZ9Y',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create an instance of AuthRepositoryImpl
    final authRepository = AuthRepositoryImpl();

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
