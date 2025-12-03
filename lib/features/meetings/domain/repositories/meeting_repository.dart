// lib/features/meetings/domain/repositories/meeting_repository.dart
// Requirements: 1.1-1.8, 2.1-2.9, 3.1-3.4, 4.1-4.5, 15.1-15.5

import '../../data/models/meeting_model.dart';
import '../../data/models/attendance_model.dart';

/// Abstract interface for Meeting repository
/// Defines contract for meeting data operations
abstract class IMeetingRepository {
  /// Create a new meeting
  /// **Validates: Requirements 1.1-1.8**
  Future<MeetingModel?> createMeeting(MeetingModel meeting);

  /// Fetch all meetings created by the current mentor
  /// **Validates: Requirements 2.1-2.9**
  Future<List<MeetingModel>> fetchMeetingsByMentor();

  /// Fetch meetings for a specific class
  Future<List<MeetingModel>> fetchMeetingsByClass(String classId);

  /// Fetch a single meeting by ID
  Future<MeetingModel?> fetchMeetingById(String meetingId);

  /// Update a meeting
  /// **Validates: Requirements 3.1-3.4**
  Future<MeetingModel?> updateMeeting(MeetingModel meeting);

  /// Delete a meeting
  /// **Validates: Requirements 4.1-4.5**
  Future<void> deleteMeeting(String meetingId);

  /// Mark attendance for a student
  /// **Validates: Requirements 15.1-15.5**
  Future<AttendanceModel?> markAttendance({
    required String meetingId,
    required String studentId,
    required String status,
  });

  /// Fetch attendance list for a meeting
  Future<List<AttendanceModel>> fetchAttendance(String meetingId);

  /// Fetch enrolled students for a class
  Future<List<Map<String, dynamic>>> fetchEnrolledStudents(String classId);

  /// Update meeting status
  Future<MeetingModel?> updateMeetingStatus(String meetingId, String newStatus);

  /// Get classes owned by current mentor
  Future<List<Map<String, dynamic>>> getMyClasses();
}
