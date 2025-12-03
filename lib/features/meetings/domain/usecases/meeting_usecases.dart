// lib/features/meetings/domain/usecases/meeting_usecases.dart
// Requirements: 1.1-1.8, 2.1-2.9, 3.1-3.4, 4.1-4.5, 15.1-15.5

import '../../data/models/meeting_model.dart';
import '../../data/models/attendance_model.dart';
import '../repositories/meeting_repository.dart';

/// Use case for creating a new meeting
/// **Validates: Requirements 1.1-1.8**
class CreateMeetingUseCase {
  final IMeetingRepository _repository;

  CreateMeetingUseCase(this._repository);

  Future<MeetingModel?> execute(MeetingModel meeting) async {
    // Validate meeting date is not in the past
    if (meeting.meetingDate.isBefore(DateTime.now())) {
      throw Exception('Tanggal meeting tidak boleh di masa lalu');
    }

    // Validate meeting type and required fields
    if (meeting.meetingType == 'online' &&
        (meeting.meetingLink == null || meeting.meetingLink!.isEmpty)) {
      throw Exception('Meeting online harus memiliki link');
    }

    if (meeting.meetingType == 'offline' &&
        (meeting.location == null || meeting.location!.isEmpty)) {
      throw Exception('Meeting offline harus memiliki lokasi');
    }

    return _repository.createMeeting(meeting);
  }
}

/// Use case for fetching meetings by mentor
/// **Validates: Requirements 2.1-2.9**
class GetMeetingsByMentorUseCase {
  final IMeetingRepository _repository;

  GetMeetingsByMentorUseCase(this._repository);

  Future<List<MeetingModel>> execute() {
    return _repository.fetchMeetingsByMentor();
  }
}

/// Use case for fetching meetings by class
class GetMeetingsByClassUseCase {
  final IMeetingRepository _repository;

  GetMeetingsByClassUseCase(this._repository);

  Future<List<MeetingModel>> execute(String classId) {
    return _repository.fetchMeetingsByClass(classId);
  }
}

/// Use case for fetching a single meeting
class GetMeetingByIdUseCase {
  final IMeetingRepository _repository;

  GetMeetingByIdUseCase(this._repository);

  Future<MeetingModel?> execute(String meetingId) {
    return _repository.fetchMeetingById(meetingId);
  }
}

/// Use case for updating a meeting
/// **Validates: Requirements 3.1-3.4**
class UpdateMeetingUseCase {
  final IMeetingRepository _repository;

  UpdateMeetingUseCase(this._repository);

  Future<MeetingModel?> execute(MeetingModel meeting) async {
    // Validate meeting type and required fields
    if (meeting.meetingType == 'online' &&
        (meeting.meetingLink == null || meeting.meetingLink!.isEmpty)) {
      throw Exception('Meeting online harus memiliki link');
    }

    if (meeting.meetingType == 'offline' &&
        (meeting.location == null || meeting.location!.isEmpty)) {
      throw Exception('Meeting offline harus memiliki lokasi');
    }

    return _repository.updateMeeting(meeting);
  }
}

/// Use case for deleting a meeting
/// **Validates: Requirements 4.1-4.5**
class DeleteMeetingUseCase {
  final IMeetingRepository _repository;

  DeleteMeetingUseCase(this._repository);

  Future<void> execute(String meetingId) {
    return _repository.deleteMeeting(meetingId);
  }
}

/// Use case for marking attendance
/// **Validates: Requirements 15.1-15.5**
class MarkAttendanceUseCase {
  final IMeetingRepository _repository;

  MarkAttendanceUseCase(this._repository);

  Future<AttendanceModel?> execute({
    required String meetingId,
    required String studentId,
    required String status,
  }) async {
    // Validate status
    final validStatuses = ['present', 'absent', 'late', 'excused'];
    if (!validStatuses.contains(status)) {
      throw Exception('Status kehadiran tidak valid');
    }

    return _repository.markAttendance(
      meetingId: meetingId,
      studentId: studentId,
      status: status,
    );
  }
}

/// Use case for fetching attendance
class GetAttendanceUseCase {
  final IMeetingRepository _repository;

  GetAttendanceUseCase(this._repository);

  Future<List<AttendanceModel>> execute(String meetingId) {
    return _repository.fetchAttendance(meetingId);
  }
}

/// Use case for updating meeting status
class UpdateMeetingStatusUseCase {
  final IMeetingRepository _repository;

  UpdateMeetingStatusUseCase(this._repository);

  Future<MeetingModel?> execute(String meetingId, String newStatus) async {
    // Validate status transition
    final validStatuses = ['scheduled', 'ongoing', 'completed', 'cancelled'];
    if (!validStatuses.contains(newStatus)) {
      throw Exception('Status meeting tidak valid');
    }

    return _repository.updateMeetingStatus(meetingId, newStatus);
  }
}
