// lib/features/meetings/data/services/meeting_service.dart
// Requirements: 1.1-1.8, 2.1-2.9, 15.1-15.5

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meeting_model.dart';
import '../models/attendance_model.dart';

class MeetingService {
  final SupabaseClient supabaseClient;

  MeetingService(this.supabaseClient);

  /// Create a new meeting
  /// **Validates: Requirements 1.1-1.8**
  Future<MeetingModel?> createMeeting(MeetingModel meeting) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User tidak login');

      final response = await supabaseClient
          .from('meetings')
          .insert(meeting.toCreateJson())
          .select()
          .single();

      return MeetingModel.fromJson(response);
    } catch (e) {
      debugPrint('Error createMeeting: $e');
      rethrow;
    }
  }

  /// Fetch all meetings created by the current mentor
  /// **Validates: Requirements 2.1-2.9**
  Future<List<MeetingModel>> fetchMeetingsByMentor() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return [];

      final response = await supabaseClient
          .from('meetings')
          .select()
          .eq('created_by', user.id)
          .order('meeting_date', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => MeetingModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetchMeetingsByMentor: $e');
      return [];
    }
  }

  /// Fetch meetings for a specific class
  Future<List<MeetingModel>> fetchMeetingsByClass(String classId) async {
    try {
      final response = await supabaseClient
          .from('meetings')
          .select()
          .eq('class_id', classId)
          .order('created_at', ascending: true); // Order by creation time, oldest first

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => MeetingModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetchMeetingsByClass: $e');
      return [];
    }
  }

  /// Fetch a single meeting by ID
  Future<MeetingModel?> fetchMeetingById(String meetingId) async {
    try {
      final response = await supabaseClient
          .from('meetings')
          .select()
          .eq('id', meetingId)
          .maybeSingle();

      if (response == null) return null;
      return MeetingModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetchMeetingById: $e');
      return null;
    }
  }

  /// Update a meeting
  /// **Validates: Requirements 3.1-3.4**
  Future<MeetingModel?> updateMeeting(MeetingModel meeting) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User tidak login');

      await supabaseClient
          .from('meetings')
          .update(meeting.toUpdateJson())
          .eq('id', meeting.id)
          .eq('created_by', user.id);

      return await fetchMeetingById(meeting.id);
    } catch (e) {
      debugPrint('Error updateMeeting: $e');
      rethrow;
    }
  }

  /// Delete a meeting
  /// **Validates: Requirements 4.1-4.5**
  Future<void> deleteMeeting(String meetingId) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User tidak login');

      // Verify ownership
      final existingMeeting = await supabaseClient
          .from('meetings')
          .select('id, created_by, title')
          .eq('id', meetingId)
          .maybeSingle();

      if (existingMeeting == null) {
        throw Exception('Meeting tidak ditemukan');
      }

      if (existingMeeting['created_by'] != user.id) {
        throw Exception('Anda bukan pembuat meeting ini');
      }

      // Delete meeting (cascade will delete attendance)
      await supabaseClient.from('meetings').delete().eq('id', meetingId);

      debugPrint('Meeting "${existingMeeting['title']}" deleted successfully');
    } catch (e) {
      debugPrint('Error deleteMeeting: $e');
      rethrow;
    }
  }

  /// Mark attendance for a student
  /// **Validates: Requirements 15.1-15.5**
  Future<AttendanceModel?> markAttendance({
    required String meetingId,
    required String studentId,
    required String status,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User tidak login');

      // Check if attendance record exists
      final existing = await supabaseClient
          .from('attendance')
          .select()
          .eq('meeting_id', meetingId)
          .eq('student_id', studentId)
          .maybeSingle();

      if (existing != null) {
        // Update existing record
        final response = await supabaseClient
            .from('attendance')
            .update({
              'status': status,
              'marked_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', existing['id'])
            .select()
            .single();

        return AttendanceModel.fromJson(response);
      } else {
        // Create new record
        final response = await supabaseClient
            .from('attendance')
            .insert({
              'meeting_id': meetingId,
              'student_id': studentId,
              'status': status,
              'marked_at': DateTime.now().toUtc().toIso8601String(),
            })
            .select()
            .single();

        return AttendanceModel.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error markAttendance: $e');
      rethrow;
    }
  }

  /// Fetch attendance list for a meeting
  Future<List<AttendanceModel>> fetchAttendance(String meetingId) async {
    try {
      final response = await supabaseClient
          .from('attendance')
          .select('''
            id, meeting_id, student_id, status, marked_at,
            profiles(full_name)
          ''')
          .eq('meeting_id', meetingId)
          .order('marked_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => AttendanceModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetchAttendance: $e');
      return [];
    }
  }

  /// Fetch enrolled students for a class (for attendance marking)
  Future<List<Map<String, dynamic>>> fetchEnrolledStudents(
    String classId,
  ) async {
    try {
      final response = await supabaseClient
          .from('class_enrollments')
          .select('''
            user_id,
            profiles(id, full_name)
          ''')
          .eq('class_id', classId)
          .eq('status', 'active');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetchEnrolledStudents: $e');
      return [];
    }
  }

  /// Update meeting status
  Future<MeetingModel?> updateMeetingStatus(
    String meetingId,
    String newStatus,
  ) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User tidak login');

      await supabaseClient
          .from('meetings')
          .update({'status': newStatus})
          .eq('id', meetingId)
          .eq('created_by', user.id);

      return await fetchMeetingById(meetingId);
    } catch (e) {
      debugPrint('Error updateMeetingStatus: $e');
      rethrow;
    }
  }

  /// Get classes owned by current mentor (for dropdown)
  Future<List<Map<String, dynamic>>> getMyClasses() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return [];

      final response = await supabaseClient
          .from('classes')
          .select('id, name')
          .eq('tutor_id', user.id)
          .eq('is_active', true)
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getMyClasses: $e');
      return [];
    }
  }
}
