import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import Layer Data, Domain, Presentation
import 'features/auth/data/services/auth_service.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

// Import Pages
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'presentation/pages/dashboard_page.dart';
import 'presentation/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://khyrqmyqqkapvxgvxkbb.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtoeXJxbXlxcWthcHZ4Z3Z4a2JiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MDgxMTQsImV4cCI6MjA3ODQ4NDExNH0.yySqbK0E9CRH_l6XGn1E4TwAyh33qf5TH9OmiY82utw', 
  );

  runApp(const MyApp());
}

//holla
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseClient = Supabase.instance.client;
    final authService = AuthService(supabaseClient); 
    final authRepository = AuthRepositoryImpl(authService);
    
    final loginUser = LoginUser(authRepository);
    final registerUser = RegisterUser(authRepository);

    return MultiProvider(
      providers: [
        
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUser: loginUser,
            registerUser: registerUser,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Gabara Mobile',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/dashboard': (context) => const DashboardPage(),
        },
      ),
    );
  }
}