import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import Layer Data, Domain, Presentation - AUTH
import 'features/auth/data/services/auth_service.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

// Import Layer Data, Domain, Presentation - CLASS (BARU)
import 'features/class/data/services/class_service.dart';
import 'features/class/presentation/providers/class_provider.dart';

// Import Layer Data, Domain, Presentation - PROFILE (BARU)
import 'features/profile/data/services/profile_service.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/usecases/get_profile.dart';
import 'features/profile/domain/usecases/update_profile.dart';
import 'features/profile/domain/usecases/change_password.dart';
import 'features/profile/presentation/providers/profile_provider.dart';

// Import Pages
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'presentation/pages/dashboard_page.dart';
import 'presentation/pages/student_dashboard_page.dart';
import 'presentation/pages/mentor_dashboard_page.dart';
import 'presentation/pages/admin_dashboard_page.dart';
import 'presentation/pages/home_page.dart';
import 'features/class/presentation/pages/create_class_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://srofknwnftewlyrarnru.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNyb2ZrbnduZnRld2x5cmFybnJ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzODc0ODcsImV4cCI6MjA3ODk2MzQ4N30._s2WbO9t4voSr2h2cONOpWvJDEtgpt5RqjkEYbrZuqs', 
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseClient = Supabase.instance.client;
    
    // --- AUTH DEPENDENCIES ---
    final authService = AuthService(supabaseClient); 
    final authRepository = AuthRepositoryImpl(authService);
    final loginUser = LoginUser(authRepository);
    final registerUser = RegisterUser(authRepository);

    // --- CLASS DEPENDENCIES (BARU) ---
    final classService = ClassService(supabaseClient);

    // --- PROFILE DEPENDENCIES (BARU) ---
    final profileService = ProfileService(supabaseClient);
    final profileRepository = ProfileRepositoryImpl(profileService);
    final getProfile = GetProfile(profileRepository);
    final updateProfile = UpdateProfile(profileRepository);
    final changePassword = ChangePassword(profileRepository);

    return MultiProvider(
      providers: [
        // Provider untuk Auth
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUser: loginUser,
            registerUser: registerUser,
          ),
        ),
        
        // Provider untuk Kelas (BARU)
        ChangeNotifierProvider(
          create: (_) => ClassProvider(classService),
        ),

        // Provider untuk Profile (BARU)
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            getProfileUseCase: getProfile,
            updateProfileUseCase: updateProfile,
            changePasswordUseCase: changePassword,
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
          '/dashboard': (context) => const DashboardPage(), // Legacy route
          '/student-dashboard': (context) => const StudentDashboardPage(),
          '/mentor-dashboard': (context) => const MentorDashboardPage(),
          '/admin-dashboard': (context) => const AdminDashboardPage(),
          '/create-class': (context) => const CreateClassPage(),
        },
      ),
    );
  }
}