// test/features/student/student_meeting_detail_page_test.dart
// Unit tests for StudentMeetingDetailPage
// **Validates: Requirements 10.1-10.5**

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gabara_mobile/features/meetings/data/models/meeting_model.dart';
import 'package:gabara_mobile/features/meetings/data/services/meeting_service.dart';
import 'package:gabara_mobile/features/assignments/data/models/assignment_model.dart';
import 'package:gabara_mobile/features/assignments/data/models/submission_model.dart';
import 'package:gabara_mobile/features/assignments/data/services/assignment_service.dart';
import 'package:gabara_mobile/features/student/presentation/pages/student_meeting_detail_page.dart';
import 'package:gabara_mobile/features/student/presentation/providers/student_provider.dart';

// Mock StudentProvider for testing
class MockStudentProvider extends ChangeNotifier implements StudentProvider {
  List<MeetingModel> _meetings = [];
  MeetingModel? _currentMeeting;
  List<AssignmentModel> _assignments = [];
  AssignmentModel? _currentAssignment;
  SubmissionModel? _mySubmission;
  List<Map<String, dynamic>> _myClasses = [];
  String? _selectedClassId;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  List<MeetingModel> get meetings => _meetings;
  @override
  MeetingModel? get currentMeeting => _currentMeeting;
  @override
  List<AssignmentModel> get assignments => _assignments;
  @override
  AssignmentModel? get currentAssignment => _currentAssignment;
  @override
  SubmissionModel? get mySubmission => _mySubmission;
  @override
  List<Map<String, dynamic>> get myClasses => _myClasses;
  @override
  String? get selectedClassId => _selectedClassId;
  @override
  bool get isLoading => _isLoading;
  @override
  String? get errorMessage => _errorMessage;

  void setCurrentMeeting(MeetingModel? meeting) {
    _currentMeeting = meeting;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  @override
  Future<void> loadMeetings(String classId) async {}

  @override
  Future<void> loadMeetingDetail(String meetingId) async {
    notifyListeners();
  }

  @override
  Future<void> loadAssignments(String classId) async {}

  @override
  Future<void> loadAssignmentDetail(String assignmentId) async {}

  @override
  Future<bool> submitAssignment(SubmissionModel submission) async => true;

  @override
  List<MeetingModel> get upcomingMeetings => [];

  @override
  List<AssignmentModel> get activeAssignments => [];

  @override
  void clearCurrentData() {}

  @override
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  MeetingService get meetingService => throw UnimplementedError();

  @override
  AssignmentService get assignmentService => throw UnimplementedError();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Test helper to create MeetingModel
MeetingModel createTestMeeting({
  required String id,
  required String title,
  String description = 'Test description',
  String status = 'scheduled',
  String meetingType = 'online',
  DateTime? meetingDate,
  String? meetingLink,
  String? location,
  int durationMinutes = 60,
}) {
  return MeetingModel(
    id: id,
    classId: 'class-1',
    title: title,
    description: description,
    meetingDate: meetingDate ?? DateTime.now().add(const Duration(days: 1)),
    durationMinutes: durationMinutes,
    meetingType: meetingType,
    meetingLink: meetingType == 'online' ? (meetingLink ?? 'https://meet.google.com/xxx') : null,
    location: meetingType == 'offline' ? (location ?? 'Room 101') : null,
    status: status,
    createdBy: 'mentor-1',
  );
}

// Helper widget to wrap test widgets with necessary providers
Widget createTestWidget({
  required MockStudentProvider mockProvider,
  String meetingId = 'meeting-1',
}) {
  return MaterialApp(
    home: ChangeNotifierProvider<StudentProvider>.value(
      value: mockProvider,
      child: StudentMeetingDetailPage(meetingId: meetingId),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id', null);
  });

  group('StudentMeetingDetailPage', () {
    late MockStudentProvider mockProvider;

    setUp(() {
      mockProvider = MockStudentProvider();
    });

    testWidgets('displays loading indicator when loading', (tester) async {
      mockProvider.setLoading(true);
      mockProvider.setCurrentMeeting(null);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error state when loading fails', (tester) async {
      mockProvider.setError('Network error');
      mockProvider.setCurrentMeeting(null);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('displays meeting not found when meeting is null', (tester) async {
      mockProvider.setCurrentMeeting(null);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Pertemuan tidak ditemukan'), findsOneWidget);
    });

    testWidgets('displays meeting title and status', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting(
        id: '1',
        title: 'Introduction to Flutter',
        status: 'scheduled',
      ));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Introduction to Flutter'), findsOneWidget);
      expect(find.text('Dijadwalkan'), findsOneWidget);
    });

    testWidgets('displays meeting description', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting(
        id: '1',
        title: 'Meeting',
        description: 'This is a detailed description of the meeting.',
      ));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Deskripsi'), findsOneWidget);
      expect(find.text('This is a detailed description of the meeting.'), findsOneWidget);
    });

    testWidgets('displays meeting duration', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting(
        id: '1',
        title: 'Meeting',
        durationMinutes: 90,
      ));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('90 menit'), findsOneWidget);
    });

    testWidgets('displays online meeting type badge', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting(
        id: '1',
        title: 'Online Meeting',
        meetingType: 'online',
      ));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Online'), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsWidgets);
    });

    testWidgets('displays offline meeting type badge', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting(
        id: '1',
        title: 'Offline Meeting',
        meetingType: 'offline',
        location: 'Room 101',
      ));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Offline'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsWidgets);
    });

    testWidgets('displays "Buka Meeting" button for scheduled online meeting', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting(
        id: '1',
        title: 'Online Meeting',
        meetingType: 'online',
        status: 'scheduled',
        meetingLink: 'https://meet.google.com/xxx',
      ));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Buka Meeting'), findsOneWidget);
    });

    testWidgets('displays "Buka Meeting" button for ongoing online meeting', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting(
        id: '1',
        title: 'Online Meeting',
        meetingType: 'online',
        status: 'ongoing',
        meetingLink: 'https://meet.google.com/xxx',
      ));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Buka Meeting'), findsOneWidget);
    });

    testWidgets('does not display "Buka Meeting" button for completed meeting', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting(
        id: '1',
        title: 'Online Meeting',
        meetingType: 'online',
        status: 'completed',
        meetingLink: 'https://meet.google.com/xxx',
      ));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      // Button should not be visible for completed meetings
      final buttonFinder = find.widgetWithText(ElevatedButton, 'Buka Meeting');
      expect(buttonFinder, findsNothing);
    });

    testWidgets('displays location for offline meeting', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting(
        id: '1',
        title: 'Offline Meeting',
        meetingType: 'offline',
        location: 'Building A, Room 101',
      ));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Building A, Room 101'), findsOneWidget);
    });

    testWidgets('displays all status badges correctly', (tester) async {
      // Test scheduled
      mockProvider.setCurrentMeeting(createTestMeeting(id: '1', title: 'M', status: 'scheduled'));
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      expect(find.text('Dijadwalkan'), findsOneWidget);

      // Test ongoing
      mockProvider.setCurrentMeeting(createTestMeeting(id: '2', title: 'M', status: 'ongoing'));
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      expect(find.text('Berlangsung'), findsOneWidget);

      // Test completed
      mockProvider.setCurrentMeeting(createTestMeeting(id: '3', title: 'M', status: 'completed'));
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      expect(find.text('Selesai'), findsOneWidget);

      // Test cancelled
      mockProvider.setCurrentMeeting(createTestMeeting(id: '4', title: 'M', status: 'cancelled'));
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      expect(find.text('Dibatalkan'), findsOneWidget);
    });

    testWidgets('AppBar displays correct title', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting(id: '1', title: 'Meeting'));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Detail Pertemuan'), findsOneWidget);
    });

    testWidgets('does not show edit/delete buttons (student view)', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting(id: '1', title: 'Meeting'));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
    });
  });
}
