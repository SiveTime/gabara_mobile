// lib/features/grades/presentation/pages/grades_page.dart
// Requirements: 13.1-13.5, 14.1-14.5

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'student_grades_page.dart';
import 'mentor_grades_page.dart';

/// Main grades page that routes to student or mentor view based on role
/// **Validates: Requirements 13.1-13.5, 14.1-14.5**
class GradesPage extends StatefulWidget {
  const GradesPage({super.key});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  bool _isLoading = true;
  String? _userRole;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'User tidak login';
          _isLoading = false;
        });
        return;
      }

      // Fetch user profile to get role
      final response = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      setState(() {
        _userRole = response?['role'] ?? 'student';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nilai')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_errorMessage'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadUserRole();
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // Route based on role
    if (_userRole == 'tutor' || _userRole == 'mentor') {
      return const MentorGradesPage();
    } else {
      return const StudentGradesPage();
    }
  }
}
