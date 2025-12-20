import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/class_model.dart';
import '../../domain/entities/class_member_entity.dart';

class ClassService {
  final SupabaseClient supabaseClient;

  ClassService(this.supabaseClient);

  // Get enrolled classes (for student)
  Future<List<ClassModel>> getEnrolledClasses() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return [];

      // Get enrollments first
      final enrollments = await supabaseClient
          .from('class_enrollments')
          .select('class_id')
          .eq('user_id', user.id)
          .eq('status', 'active');

      if ((enrollments as List).isEmpty) return [];

      final classIds = enrollments.map((e) => e['class_id']).toList();

      // Get classes with subjects
      final response = await supabaseClient
          .from('classes')
          .select(
            'id, name, description, class_code, max_students, is_active, created_at, tutor_id, subjects(name)',
          )
          .inFilter('id', classIds)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;

      // Fetch tutor names
      return await _mapClassesWithTutorNames(data);
    } catch (e) {
      debugPrint('Error getEnrolledClasses: $e');
      return [];
    }
  }

  // Get classes created by mentor (tutor_id = current user)
  Future<List<ClassModel>> getMyClasses() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return [];

      final response = await supabaseClient
          .from('classes')
          .select(
            'id, name, description, class_code, max_students, is_active, created_at, tutor_id, subject_id, subjects(name)',
          )
          .eq('tutor_id', user.id)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;

      // Fetch tutor names
      return await _mapClassesWithTutorNames(data);
    } catch (e) {
      debugPrint('Error getMyClasses: $e');
      return [];
    }
  }

  // Helper: Map classes with tutor names from profiles
  Future<List<ClassModel>> _mapClassesWithTutorNames(
    List<dynamic> classes,
  ) async {
    if (classes.isEmpty) return [];

    // Get unique tutor IDs
    final tutorIds = classes
        .map((c) => c['tutor_id'] as String?)
        .where((id) => id != null)
        .toSet()
        .toList();

    // Fetch profiles for tutors
    Map<String, String> tutorNames = {};
    if (tutorIds.isNotEmpty) {
      final profiles = await supabaseClient
          .from('profiles')
          .select('id, full_name')
          .inFilter('id', tutorIds);

      for (var profile in profiles) {
        tutorNames[profile['id']] = profile['full_name'] ?? 'Mentor';
      }
    }

    // Map to ClassModel with tutor names
    return classes.map((json) {
      final tutorId = json['tutor_id'] as String?;
      final tutorName = tutorNames[tutorId] ?? 'Mentor';

      return ClassModel.fromJson({
        ...json,
        'tutor': {'full_name': tutorName},
      });
    }).toList();
  }

  // Generate unique class code
  String _generateClassCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      6,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  // Create new class
  Future<void> createClass({
    required String name,
    required String description,
    required int subjectId,
    required int maxStudents,
  }) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) throw Exception('User tidak login');

    final classCode = _generateClassCode();

    await supabaseClient.from('classes').insert({
      'name': name,
      'description': description,
      'subject_id': subjectId,
      'tutor_id': user.id,
      'max_students': maxStudents,
      'class_code': classCode,
      'is_active': true,
    });
  }

  // Update class
  Future<void> updateClass({
    required String classId,
    required String name,
    required String description,
    required int subjectId,
    required int maxStudents,
  }) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) throw Exception('User tidak login');

    await supabaseClient
        .from('classes')
        .update({
          'name': name,
          'description': description,
          'subject_id': subjectId,
          'max_students': maxStudents,
        })
        .eq('id', classId)
        .eq('tutor_id', user.id);
  }

  // Delete class (hard delete)
  Future<void> deleteClass(String classId) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) throw Exception('User tidak login');

    debugPrint('=== DELETE CLASS ===');
    debugPrint('Class ID: $classId');
    debugPrint('User ID: ${user.id}');

    try {
      // Verifikasi kelas ada dan milik user ini
      final existingClass = await supabaseClient
          .from('classes')
          .select('id, tutor_id, name')
          .eq('id', classId)
          .maybeSingle();

      debugPrint('Existing class: $existingClass');

      if (existingClass == null) {
        throw Exception('Kelas tidak ditemukan');
      }

      if (existingClass['tutor_id'] != user.id) {
        throw Exception('Anda bukan pemilik kelas ini');
      }

      // Hard delete - tanpa filter tutor_id karena sudah diverifikasi
      await supabaseClient.from('classes').delete().eq('id', classId);

      debugPrint('Class "${existingClass['name']}" deleted successfully');
    } catch (e) {
      debugPrint('Error deleting class: $e');
      rethrow;
    }
  }

  // Get subjects list
  Future<List<Map<String, dynamic>>> getSubjects() async {
    try {
      final response = await supabaseClient
          .from('subjects')
          .select('id, name')
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Join class by code (for student)
  Future<void> joinClass(String classCode) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) throw Exception('User tidak login');

    // Find class by code
    final classData = await supabaseClient
        .from('classes')
        .select('id')
        .eq('class_code', classCode.toUpperCase())
        .eq('is_active', true)
        .maybeSingle();

    if (classData == null) {
      throw Exception('Kode kelas tidak ditemukan');
    }

    // Enroll student
    await supabaseClient.from('class_enrollments').insert({
      'class_id': classData['id'],
      'user_id': user.id,
      'status': 'active',
    });
  }

  // Get enrolled students count for a class
  Future<int> getEnrolledCount(String classId) async {
    try {
      final response = await supabaseClient
          .from('class_enrollments')
          .select('id')
          .eq('class_id', classId)
          .eq('status', 'active');
      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  // Get class members (students and mentors)
  Future<List<ClassMemberEntity>> getClassMembers(String classId) async {
    try {
      debugPrint('=== FETCHING CLASS MEMBERS ===');
      debugPrint('Class ID: $classId');

      List<ClassMemberEntity> members = [];

      // Step 1: Get enrolled students from class_enrollments
      final enrollments = await supabaseClient
          .from('class_enrollments')
          .select('id, user_id, class_id, status, joined_at')
          .eq('class_id', classId)
          .eq('status', 'active')
          .order('joined_at', ascending: true);

      debugPrint('Enrollments found: ${enrollments.length}');
      debugPrint('Enrollments data: $enrollments');

      // Step 2: Get user profiles for enrolled students
      if (enrollments.isNotEmpty) {
        final userIds = enrollments.map((e) => e['user_id']).toList();

        debugPrint('User IDs to fetch: $userIds');

        final profiles = await supabaseClient
            .from('profiles')
            .select('id, full_name, avatar_url')
            .inFilter('id', userIds);

        debugPrint('Profiles found: ${profiles.length}');
        debugPrint('Profiles data: $profiles');

        // Map profiles to enrollments
        final profileMap = <String, dynamic>{};
        for (var profile in profiles) {
          profileMap[profile['id']] = profile;
        }

        // Create member entities for students
        for (var enrollment in enrollments) {
          final userId = enrollment['user_id'];
          final profile = profileMap[userId];

          debugPrint(
            'Processing enrollment - userId: $userId, profile: $profile',
          );

          if (profile != null) {
            members.add(
              ClassMemberEntity(
                id: enrollment['id'],
                userId: userId,
                classId: enrollment['class_id'],
                fullName: profile['full_name'] ?? 'Unknown Student',
                email: '',
                profilePicture: profile['avatar_url'],
                joinedAt: DateTime.parse(enrollment['joined_at']),
                role: 'student',
              ),
            );
          }
        }
      }

      // Step 3: Get class tutor/mentor
      final classData = await supabaseClient
          .from('classes')
          .select('tutor_id, created_at')
          .eq('id', classId)
          .maybeSingle();

      debugPrint('Class data: $classData');

      if (classData != null && classData['tutor_id'] != null) {
        final tutorId = classData['tutor_id'];

        final tutorProfile = await supabaseClient
            .from('profiles')
            .select('id, full_name, avatar_url')
            .eq('id', tutorId)
            .maybeSingle();

        debugPrint('Tutor profile: $tutorProfile');

        if (tutorProfile != null) {
          members.add(
            ClassMemberEntity(
              id: 'tutor_$tutorId',
              userId: tutorId,
              classId: classId,
              fullName: tutorProfile['full_name'] ?? 'Mentor',
              email: '',
              profilePicture: tutorProfile['avatar_url'],
              joinedAt: DateTime.parse(classData['created_at']),
              role: 'mentor',
            ),
          );
        }
      }

      debugPrint('Total members found: ${members.length}');

      // Sort members: mentor first, then students by join date
      members.sort((a, b) {
        if (a.role == 'mentor' && b.role != 'mentor') return -1;
        if (a.role != 'mentor' && b.role == 'mentor') return 1;
        return a.joinedAt.compareTo(b.joinedAt);
      });

      return members;
    } catch (e) {
      debugPrint('Error fetching class members: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Simple test method
  Future<Map<String, dynamic>> testDatabaseConnection() async {
    try {
      final user = supabaseClient.auth.currentUser;

      // Test basic queries
      final classCount = await supabaseClient
          .from('classes')
          .select('id')
          .count();
      final enrollmentCount = await supabaseClient
          .from('class_enrollments')
          .select('id')
          .count();
      final profileCount = await supabaseClient
          .from('profiles')
          .select('id')
          .count();

      return {
        'success': true,
        'user_id': user?.id,
        'user_email': user?.email,
        'classes_count': classCount,
        'enrollments_count': enrollmentCount,
        'profiles_count': profileCount,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Debug: Check database structure for class members
  Future<Map<String, dynamic>> debugDatabaseStructure(String classId) async {
    try {
      debugPrint('=== DEBUG DATABASE STRUCTURE ===');

      // Check 1: Try to fetch from class_enrollments
      final enrollments = await supabaseClient
          .from('class_enrollments')
          .select('*')
          .eq('class_id', classId)
          .limit(1);

      debugPrint('class_enrollments sample: $enrollments');

      // Check 2: Try to fetch class with students relationship
      final classWithStudents = await supabaseClient
          .from('classes')
          .select('*, students(*)')
          .eq('id', classId)
          .maybeSingle();

      debugPrint('classes with students: $classWithStudents');

      // Check 3: Check if there's a class_students table
      final classStudents = await supabaseClient
          .from('class_students')
          .select('*')
          .eq('class_id', classId)
          .limit(1);

      debugPrint('class_students sample: $classStudents');

      // Check 4: Get all tables info
      final allEnrollments = await supabaseClient
          .from('class_enrollments')
          .select('*')
          .eq('class_id', classId);

      debugPrint('Total enrollments: ${allEnrollments.length}');
      if (allEnrollments.isNotEmpty) {
        debugPrint('First enrollment: ${allEnrollments[0]}');
      }

      return {
        'enrollments_count': allEnrollments.length,
        'has_enrollments': allEnrollments.isNotEmpty,
        'first_enrollment': allEnrollments.isNotEmpty
            ? allEnrollments[0]
            : null,
      };
    } catch (e) {
      debugPrint('Debug error: $e');
      return {'error': e.toString()};
    }
  }

  // Debug method to check enrollment data
  Future<void> debugClassEnrollments(String classId) async {
    try {
      debugPrint('=== DEBUG CLASS ENROLLMENTS ===');
      debugPrint('Class ID: $classId');

      final user = supabaseClient.auth.currentUser;
      debugPrint('Current user: ${user?.id}');
      debugPrint('User email: ${user?.email}');

      // Check if class exists
      final classExists = await supabaseClient
          .from('classes')
          .select('id, name, tutor_id')
          .eq('id', classId)
          .maybeSingle();

      debugPrint('Class exists: $classExists');

      // Check ALL enrollments for this class (no filters)
      final allEnrollments = await supabaseClient
          .from('class_enrollments')
          .select('*')
          .eq('class_id', classId);

      debugPrint(
        'All enrollments for class (${allEnrollments.length}): $allEnrollments',
      );

      // Check profiles table
      if (allEnrollments.isNotEmpty) {
        final userIds = allEnrollments.map((e) => e['user_id']).toList();
        final profiles = await supabaseClient
            .from('profiles')
            .select('*')
            .inFilter('id', userIds);

        debugPrint(
          'Profiles for enrolled users (${profiles.length}): $profiles',
        );
      }

      // Check current user's profile
      if (user != null) {
        final userProfile = await supabaseClient
            .from('profiles')
            .select('*')
            .eq('id', user.id)
            .maybeSingle();

        debugPrint('Current user profile: $userProfile');
      }
    } catch (e) {
      debugPrint('Debug error: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }
}
