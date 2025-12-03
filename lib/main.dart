import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

// Import Layer Data, Domain, Presentation - AUTH
import 'features/auth/data/services/auth_service.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

// Import Layer Data, Domain, Presentation - CLASS
import 'features/class/data/services/class_service.dart';
import 'features/class/presentation/providers/class_provider.dart';
import 'features/class/domain/entities/class_entity.dart'; // Import entity

// Import Layer Data, Domain, Presentation - QUIZ
import 'features/quiz/data/services/quiz_service.dart';
import 'features/quiz/data/services/student_quiz_service.dart';
import 'features/quiz/presentation/providers/quiz_provider.dart';
import 'features/quiz/presentation/providers/student_quiz_provider.dart';
import 'features/quiz/presentation/pages/quiz_list_page.dart';
import 'features/quiz/presentation/pages/quiz_builder_page.dart';
import 'features/quiz/presentation/pages/quiz_detail_page.dart';
import 'features/quiz/presentation/pages/student_quiz_detail_page.dart';
import 'features/quiz/presentation/pages/student_quiz_result_page.dart';

// Import Layer Data, Domain, Presentation - PROFILE
import 'features/profile/data/services/profile_service.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/usecases/get_profile.dart';
import 'features/profile/domain/usecases/update_profile.dart';
import 'features/profile/domain/usecases/change_password.dart';
import 'features/profile/presentation/providers/profile_provider.dart';

// Import Layer Data, Domain, Presentation - MEETINGS
import 'features/meetings/data/services/meeting_service.dart';
import 'features/meetings/presentation/providers/meeting_provider.dart';
import 'features/meetings/presentation/pages/meeting_list_page.dart';
import 'features/meetings/presentation/pages/create_meeting_page.dart';
import 'features/meetings/presentation/pages/meeting_detail_page.dart';

// Import Layer Data, Domain, Presentation - ASSIGNMENTS
import 'features/assignments/data/services/assignment_service.dart';
import 'features/assignments/presentation/providers/assignment_provider.dart';
import 'features/assignments/presentation/pages/assignment_list_page.dart';
import 'features/assignments/presentation/pages/create_assignment_page.dart';
import 'features/assignments/presentation/pages/assignment_detail_page.dart';
import 'features/assignments/presentation/pages/submission_detail_page.dart';

// Import Layer Data, Domain, Presentation - STUDENT
import 'features/student/presentation/providers/student_provider.dart';

// Import Pages
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'presentation/pages/dashboard_page.dart';
import 'presentation/pages/student_dashboard_page.dart';
import 'presentation/pages/mentor_dashboard_page.dart';
import 'presentation/pages/admin_dashboard_page.dart';
import 'presentation/pages/home_page.dart';
import 'features/class/presentation/pages/class_page.dart';
import 'features/class/presentation/pages/create_class_page.dart';
import 'features/class/presentation/pages/class_detail_page.dart';
import 'features/class/presentation/pages/edit_class_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  await Supabase.initialize(
    url: 'https://srofknwnftewlyrarnru.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNyb2ZrbnduZnRld2x5cmFybnJ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzODc0ODcsImV4cCI6MjA3ODk2MzQ4N30._s2WbO9t4voSr2h2cONOpWvJDEtgpt5RqjkEYbrZuqs',
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

    // --- CLASS DEPENDENCIES ---
    final classService = ClassService(supabaseClient);

    // --- QUIZ DEPENDENCIES ---
    final quizService = QuizService(supabaseClient);
    final studentQuizService = StudentQuizService(supabaseClient);

    // --- PROFILE DEPENDENCIES ---
    final profileService = ProfileService(supabaseClient);
    final profileRepository = ProfileRepositoryImpl(profileService);
    final getProfile = GetProfile(profileRepository);
    final updateProfile = UpdateProfile(profileRepository);
    final changePassword = ChangePassword(profileRepository);

    // --- MEETING DEPENDENCIES ---
    final meetingService = MeetingService(supabaseClient);

    // --- ASSIGNMENT DEPENDENCIES ---
    final assignmentService = AssignmentService(supabaseClient);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(loginUser: loginUser, registerUser: registerUser),
        ),
        ChangeNotifierProvider(create: (_) => ClassProvider(classService)),
        ChangeNotifierProvider(create: (_) => QuizProvider(quizService)),
        ChangeNotifierProvider(
          create: (_) => StudentQuizProvider(studentQuizService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            getProfileUseCase: getProfile,
            updateProfileUseCase: updateProfile,
            changePasswordUseCase: changePassword,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MeetingProvider(meetingService),
        ),
        ChangeNotifierProvider(
          create: (_) => AssignmentProvider(assignmentService),
        ),
        ChangeNotifierProvider(
          create: (_) => StudentProvider(meetingService, assignmentService),
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
          '/student-dashboard': (context) => const StudentDashboardPage(),
          '/mentor-dashboard': (context) => const MentorDashboardPage(),
          '/admin-dashboard': (context) => const AdminDashboardPage(),
          '/class': (context) => const ClassPage(),
          '/create-class': (context) => const CreateClassPage(),
          '/quiz': (context) => const QuizListPage(),
          '/quiz/create': (context) => const QuizBuilderPage(),
          // Meeting routes
          '/meetings': (context) => const MeetingListPage(),
          '/meetings/create': (context) => const CreateMeetingPage(),
          // Assignment routes
          '/assignments': (context) => const AssignmentListPage(),
          '/assignments/create': (context) => const CreateAssignmentPage(),
        },
        // Menggunakan onGenerateRoute untuk passing arguments
        onGenerateRoute: (settings) {
          if (settings.name == '/class-detail') {
            final args = settings.arguments as ClassEntity;
            return MaterialPageRoute(
              builder: (context) => ClassDetailPage(classEntity: args),
            );
          }
          if (settings.name == '/edit-class') {
            final args = settings.arguments as ClassEntity;
            return MaterialPageRoute(
              builder: (context) => EditClassPage(classEntity: args),
            );
          }
          if (settings.name == '/quiz/detail') {
            final quizId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => QuizDetailPage(quizId: quizId),
            );
          }
          // Student Quiz Routes
          if (settings.name == '/student/quiz/detail') {
            final quizId = settings.arguments as String;
            return MaterialPageRoute(
              settings: const RouteSettings(name: '/student/quiz/detail'),
              builder: (context) => StudentQuizDetailPage(quizId: quizId),
            );
          }
          if (settings.name == '/quiz/result') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => StudentQuizResultPage(
                attemptId: args['attemptId'] as String?,
              ),
            );
          }
          // Meeting routes
          if (settings.name == '/meetings/detail') {
            final meetingId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => MeetingDetailPage(meetingId: meetingId),
            );
          }
          // Assignment routes
          if (settings.name == '/assignments/detail') {
            final assignmentId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => AssignmentDetailPage(assignmentId: assignmentId),
            );
          }
          if (settings.name == '/assignments/submission') {
            final submissionId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => SubmissionDetailPage(
                submissionId: submissionId,
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
