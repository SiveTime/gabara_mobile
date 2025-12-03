// test/features/meetings/meeting_model_test.dart
// **Feature: meetings-assignments-grades, Property 1: Meeting Creation Consistency**
// **Validates: Requirements 1.1-1.8**

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide test, group, expect;
import 'package:gabara_mobile/features/meetings/data/models/meeting_model.dart';
import 'package:gabara_mobile/features/meetings/domain/entities/meeting_entity.dart';

void main() {
  group('MeetingModel Serialization', () {
    // Property 1: Meeting Creation Consistency
    // For any valid meeting data, creating a meeting should result in a meeting
    // record with all fields correctly stored and retrievable.
    Glados(any.meetingModel).test(
      'Property 1: Meeting round-trip serialization preserves all fields',
      (meeting) {
        // Serialize to JSON
        final json = meeting.toJson();

        // Deserialize from JSON
        final restored = MeetingModel.fromJson(json);

        // Verify all fields are preserved
        expect(restored.id, equals(meeting.id));
        expect(restored.classId, equals(meeting.classId));
        expect(restored.title, equals(meeting.title));
        expect(restored.description, equals(meeting.description));
        expect(restored.durationMinutes, equals(meeting.durationMinutes));
        expect(restored.meetingType, equals(meeting.meetingType));
        expect(restored.meetingLink, equals(meeting.meetingLink));
        expect(restored.location, equals(meeting.location));
        expect(restored.status, equals(meeting.status));
        expect(restored.createdBy, equals(meeting.createdBy));
      },
    );

    Glados(any.meetingModel).test(
      'toCreateJson excludes id field',
      (meeting) {
        final json = meeting.toCreateJson();
        expect(json.containsKey('id'), isFalse);
        expect(json['title'], equals(meeting.title));
        expect(json['class_id'], equals(meeting.classId));
      },
    );

    Glados(any.meetingModel).test(
      'toUpdateJson excludes id and created_by fields',
      (meeting) {
        final json = meeting.toUpdateJson();
        expect(json.containsKey('id'), isFalse);
        expect(json.containsKey('created_by'), isFalse);
        expect(json['title'], equals(meeting.title));
      },
    );
  });


  group('MeetingEntity Properties', () {
    test('isOnline returns true for online meetings', () {
      final meeting = MeetingModel(
        id: '1',
        classId: 'class1',
        title: 'Test Meeting',
        meetingDate: DateTime.now(),
        meetingType: 'online',
        meetingLink: 'https://meet.google.com/xxx',
        createdBy: 'mentor1',
      );
      expect(meeting.isOnline, isTrue);
      expect(meeting.isOffline, isFalse);
    });

    test('isOffline returns true for offline meetings', () {
      final meeting = MeetingModel(
        id: '1',
        classId: 'class1',
        title: 'Test Meeting',
        meetingDate: DateTime.now(),
        meetingType: 'offline',
        location: 'Room 101',
        createdBy: 'mentor1',
      );
      expect(meeting.isOffline, isTrue);
      expect(meeting.isOnline, isFalse);
    });

    test('endTime calculates correctly', () {
      final startTime = DateTime(2025, 12, 1, 10, 0);
      final meeting = MeetingModel(
        id: '1',
        classId: 'class1',
        title: 'Test Meeting',
        meetingDate: startTime,
        durationMinutes: 90,
        meetingType: 'online',
        createdBy: 'mentor1',
      );
      expect(meeting.endTime, equals(DateTime(2025, 12, 1, 11, 30)));
    });
  });

  group('MeetingStatus Transitions', () {
    test('valid transitions from scheduled', () {
      expect(MeetingStatus.isValidTransition('scheduled', 'ongoing'), isTrue);
      expect(MeetingStatus.isValidTransition('scheduled', 'cancelled'), isTrue);
      expect(MeetingStatus.isValidTransition('scheduled', 'completed'), isFalse);
    });

    test('valid transitions from ongoing', () {
      expect(MeetingStatus.isValidTransition('ongoing', 'completed'), isTrue);
      expect(MeetingStatus.isValidTransition('ongoing', 'cancelled'), isTrue);
      expect(MeetingStatus.isValidTransition('ongoing', 'scheduled'), isFalse);
    });

    test('no transitions from completed', () {
      expect(MeetingStatus.isValidTransition('completed', 'scheduled'), isFalse);
      expect(MeetingStatus.isValidTransition('completed', 'ongoing'), isFalse);
      expect(MeetingStatus.isValidTransition('completed', 'cancelled'), isFalse);
    });

    test('no transitions from cancelled', () {
      expect(MeetingStatus.isValidTransition('cancelled', 'scheduled'), isFalse);
      expect(MeetingStatus.isValidTransition('cancelled', 'ongoing'), isFalse);
      expect(MeetingStatus.isValidTransition('cancelled', 'completed'), isFalse);
    });
  });

  group('MeetingType Validation', () {
    test('valid meeting types', () {
      expect(MeetingType.isValid('online'), isTrue);
      expect(MeetingType.isValid('offline'), isTrue);
      expect(MeetingType.isValid('hybrid'), isFalse);
      expect(MeetingType.isValid(''), isFalse);
    });
  });
}

// Custom generators for Glados
extension MeetingGenerators on Any {
  Generator<MeetingModel> get meetingModel {
    return any.lowercaseLetters.map((id) {
      final meetingType = id.hashCode % 2 == 0 ? 'online' : 'offline';
      return MeetingModel(
        id: 'id-$id',
        classId: 'class-$id',
        title: 'Meeting $id',
        description: 'Test description',
        meetingDate: DateTime.now().add(const Duration(days: 1)),
        durationMinutes: 60,
        meetingType: meetingType,
        meetingLink: meetingType == 'online' ? 'https://meet.google.com/xxx' : null,
        location: meetingType == 'offline' ? 'Room 101' : null,
        status: 'scheduled',
        createdBy: 'mentor-$id',
      );
    });
  }
}
