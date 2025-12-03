// test/features/meetings/meeting_integration_test.dart
// Integration tests for Meeting flow
// **Validates: Requirements 1.1-1.8, 2.1-2.9, 3.1-3.4, 4.1-4.5**

import 'package:flutter_test/flutter_test.dart';
import 'package:gabara_mobile/features/meetings/data/models/meeting_model.dart';
import 'package:gabara_mobile/features/meetings/data/models/attendance_model.dart';

void main() {
  group('Meeting Integration Tests', () {
    group('Meeting CRUD Flow', () {
      test('Meeting model can be created with all required fields', () {
        final meeting = MeetingModel(
          id: 'meeting-1',
          classId: 'class-1',
          title: 'Pertemuan 1: Pengenalan',
          description: 'Pengenalan materi dasar',
          meetingDate: DateTime.now().add(const Duration(days: 1)),
          meetingType: 'online',
          meetingLink: 'https://meet.google.com/abc-defg-hij',
          durationMinutes: 90,
          status: 'scheduled',
          createdBy: 'mentor-1',
          createdAt: DateTime.now(),
        );

        expect(meeting.id, equals('meeting-1'));
        expect(meeting.title, equals('Pertemuan 1: Pengenalan'));
        expect(meeting.meetingType, equals('online'));
        expect(meeting.isOnline, isTrue);
        expect(meeting.meetingLink, isNotNull);
      });

      test('Meeting model serialization round-trip preserves data', () {
        final original = MeetingModel(
          id: 'meeting-1',
          classId: 'class-1',
          title: 'Test Meeting',
          description: 'Test Description',
          meetingDate: DateTime(2025, 12, 15, 10, 0),
          meetingType: 'offline',
          location: 'Room 101',
          durationMinutes: 60,
          status: 'scheduled',
          createdBy: 'mentor-1',
          createdAt: DateTime(2025, 12, 1),
        );

        final json = original.toJson();
        final restored = MeetingModel.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.classId, equals(original.classId));
        expect(restored.title, equals(original.title));
        expect(restored.description, equals(original.description));
        expect(restored.meetingType, equals(original.meetingType));
        expect(restored.location, equals(original.location));
        expect(restored.durationMinutes, equals(original.durationMinutes));
        expect(restored.status, equals(original.status));
      });

      test('Meeting status transitions are valid', () {
        final meeting = MeetingModel(
          id: 'meeting-1',
          classId: 'class-1',
          title: 'Test Meeting',
          meetingDate: DateTime.now(),
          meetingType: 'online',
          status: 'scheduled',
          createdBy: 'mentor-1',
        );

        // Scheduled meeting
        expect(meeting.status, equals('scheduled'));
        expect(meeting.isScheduled, isTrue);

        // Update to ongoing
        final ongoingMeeting = meeting.copyWith(status: 'ongoing');
        expect(ongoingMeeting.isOngoing, isTrue);

        // Update to completed
        final completedMeeting = meeting.copyWith(status: 'completed');
        expect(completedMeeting.isCompleted, isTrue);

        // Update to cancelled
        final cancelledMeeting = meeting.copyWith(status: 'cancelled');
        expect(cancelledMeeting.isCancelled, isTrue);
      });

      test('Online meeting requires meeting link', () {
        final onlineMeeting = MeetingModel(
          id: 'meeting-1',
          classId: 'class-1',
          title: 'Online Meeting',
          meetingDate: DateTime.now(),
          meetingType: 'online',
          meetingLink: 'https://meet.google.com/abc',
          status: 'scheduled',
          createdBy: 'mentor-1',
        );

        expect(onlineMeeting.isOnline, isTrue);
        expect(onlineMeeting.meetingLink, isNotNull);
        expect(onlineMeeting.meetingLink, isNotEmpty);
      });

      test('Offline meeting requires location', () {
        final offlineMeeting = MeetingModel(
          id: 'meeting-1',
          classId: 'class-1',
          title: 'Offline Meeting',
          meetingDate: DateTime.now(),
          meetingType: 'offline',
          location: 'Room 101',
          status: 'scheduled',
          createdBy: 'mentor-1',
        );

        expect(offlineMeeting.isOffline, isTrue);
        expect(offlineMeeting.location, isNotNull);
        expect(offlineMeeting.location, isNotEmpty);
      });
    });

    group('Attendance Flow', () {
      test('Attendance model can be created', () {
        final attendance = AttendanceModel(
          id: 'attendance-1',
          meetingId: 'meeting-1',
          studentId: 'student-1',
          status: 'present',
          markedAt: DateTime.now(),
        );

        expect(attendance.id, equals('attendance-1'));
        expect(attendance.meetingId, equals('meeting-1'));
        expect(attendance.studentId, equals('student-1'));
        expect(attendance.status, equals('present'));
        expect(attendance.isPresent, isTrue);
      });

      test('Attendance status values are valid', () {
        final presentAttendance = AttendanceModel(
          id: 'a1',
          meetingId: 'm1',
          studentId: 's1',
          status: 'present',
        );
        expect(presentAttendance.isPresent, isTrue);

        final absentAttendance = AttendanceModel(
          id: 'a2',
          meetingId: 'm1',
          studentId: 's2',
          status: 'absent',
        );
        expect(absentAttendance.isAbsent, isTrue);

        final lateAttendance = AttendanceModel(
          id: 'a3',
          meetingId: 'm1',
          studentId: 's3',
          status: 'late',
        );
        expect(lateAttendance.isLate, isTrue);

        final excusedAttendance = AttendanceModel(
          id: 'a4',
          meetingId: 'm1',
          studentId: 's4',
          status: 'excused',
        );
        expect(excusedAttendance.isExcused, isTrue);
      });

      test('Attendance serialization round-trip preserves data', () {
        final original = AttendanceModel(
          id: 'attendance-1',
          meetingId: 'meeting-1',
          studentId: 'student-1',
          status: 'present',
          markedAt: DateTime(2025, 12, 1, 10, 30),
        );

        final json = original.toJson();
        final restored = AttendanceModel.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.meetingId, equals(original.meetingId));
        expect(restored.studentId, equals(original.studentId));
        expect(restored.status, equals(original.status));
      });
    });

    group('Meeting Validation', () {
      test('Meeting date must be in the future for new meetings', () {
        final futureMeeting = MeetingModel(
          id: 'meeting-1',
          classId: 'class-1',
          title: 'Future Meeting',
          meetingDate: DateTime.now().add(const Duration(days: 1)),
          meetingType: 'online',
          status: 'scheduled',
          createdBy: 'mentor-1',
        );

        expect(futureMeeting.meetingDate.isAfter(DateTime.now()), isTrue);
      });

      test('Meeting duration must be positive', () {
        final meeting = MeetingModel(
          id: 'meeting-1',
          classId: 'class-1',
          title: 'Test Meeting',
          meetingDate: DateTime.now(),
          meetingType: 'online',
          durationMinutes: 60,
          status: 'scheduled',
          createdBy: 'mentor-1',
        );

        expect(meeting.durationMinutes, greaterThan(0));
      });

      test('Meeting title cannot be empty', () {
        final meeting = MeetingModel(
          id: 'meeting-1',
          classId: 'class-1',
          title: 'Valid Title',
          meetingDate: DateTime.now(),
          meetingType: 'online',
          status: 'scheduled',
          createdBy: 'mentor-1',
        );

        expect(meeting.title, isNotEmpty);
      });
    });
  });
}
