// lib/features/meetings/data/repositories/meeting_repository_impl.dart
// Requirements: 1.1-1.8, 2.1-2.9, 3.1-3.4, 4.1-4.5, 15.1-15.5

import '../../domain/repositories/meeting_repository.dart';
import '../models/meeting_model.dart';
import '../models/attendance_model.dart';
import '../services/meeting_service.dart';

/// Implementation of IMeetingRepository
/// Delegates operations to MeetingService
class MeetingRepositoryImpl implements IMeetingRepository {
  final MeetingService _meetingService;

  MeetingRepositoryImpl(this._meetingService);

  @override
  Future<MeetingModel?> createMeeting(MeetingModel meeting) {
    return _meetingService.createMeeting(meeting);
  }

  @override
  Future<List<MeetingModel>> fetchMeetingsByMentor() {
    return _meetingService.fetchMeetingsByMentor();
  }

  @override
  Future<List<MeetingModel>> fetchMeetingsByClass(String classId) {
    return _meetingService.fetchMeetingsByClass(classId);
  }

  @override
  Future<MeetingModel?> fetchMeetingById(String meetingId) {
    return _meetingService.fetchMeetingById(meetingId);
  }

  @override
  Future<MeetingModel?> updateMeeting(MeetingModel meeting) {
    return _meetingService.updateMeeting(meeting);
  }

  @override
  Future<void> deleteMeeting(String meetingId) {
    return _meetingService.deleteMeeting(meetingId);
  }

  @override
  Future<AttendanceModel?> markAttendance({
    required String meetingId,
    required String studentId,
    required String status,
  }) {
    return _meetingService.markAttendance(
      meetingId: meetingId,
      studentId: studentId,
      status: status,
    );
  }

  @override
  Future<List<AttendanceModel>> fetchAttendance(String meetingId) {
    return _meetingService.fetchAttendance(meetingId);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchEnrolledStudents(String classId) {
    return _meetingService.fetchEnrolledStudents(classId);
  }

  @override
  Future<MeetingModel?> updateMeetingStatus(
    String meetingId,
    String newStatus,
  ) {
    return _meetingService.updateMeetingStatus(meetingId, newStatus);
  }

  @override
  Future<List<Map<String, dynamic>>> getMyClasses() {
    return _meetingService.getMyClasses();
  }
}
