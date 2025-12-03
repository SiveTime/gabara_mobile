// test/features/student/student_meeting_list_page_test.dart
// Unit tests for StudentMeetingListPage
// **Validates: Requirements 10.1-10.5**

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:gabara_mobile/features/meetings/data/models/meeting_model.dart';
import 'package:gabara_mobile/features/meetings/data/services/meeting_service.dart';
import 'package:gabara_mobile/features/assignments/data/models/assignment_model.dart';
import 'package:gabara_mobile/features/assignments/data/models/submission_model.dart';
import 'package:gabara_mobile/features/assignments/data/services/assignment_service.dart';
import 'package:gabara_mobile/features/student/presentation/pages/student_meeting_list_page.dart';
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

  void setMeetings(List<MeetingModel> meetings) {
    _meetings = meetings;
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
  Future<void> loadMeetings(String classId) async {
    _selectedClassId = classId;
    notifyListeners();
  }

  @override
  Future<void> loadMeetingDetail(String meetingId) async {}

  @override
  Future<void> loadAssignments(String classId) async {}

  @override
  Future<void> loadAssignmentDetail(String assignmentId) async {}

  @override
  Future<bool> submitAssignment(SubmissionModel submission) async => true;

  @override
  List<MeetingModel> get upcomingMeetings => _meetings.where((m) => m.status == 'scheduled').toList();

  @override
  List<AssignmentModel> get activeAssignments => _assignments.where((a) => a.isActive).toList();

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
  String status = 'scheduled',
  String meetingType = 'online',
  DateTime? meetingDate,
  String? meetingLink,
}) {
  return MeetingModel(
    id: id,
    classId: 'class-1',
    title: title,
    description: 'Test description',
    meetingDate: meetingDate ?? DateTime.now().add(const Duration(days: 1)),
    durationMinutes: 60,
    meetingType: meetingType,
    meetingLink: meetingType == 'online' ? (meetingLink ?? 'https://meet.google.com/xxx') : null,
    location: meetingType == 'offline' ? 'Room 101' : null,
    status: status,
    createdBy: 'mentor-1',
  );
}

// Helper widget to wrap test widgets with necessary providers
Widget createTestWidget({
  required MockStudentProvider mockProvider,
  String classId = 'class-1',
  String className = 'Test Class',
}) {
  return MaterialApp(
    home: ChangeNotifierProvider<StudentProvider>.value(
      value: mockProvider,
      child: StudentMeetingListPage(classId: classId, className: className),
    ),
  );
}

void main() {
  group('StudentMeetingListPage', () {
    late MockStudentProvider mockProvider;

    setUp(() {
      mockProvider = MockStudentProvider();
    });

    testWidgets('displays loading indicator when loading', (tester) async {
      mockProvider.setLoading(true);
      mockProvider.setMeetings([]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays empty state when no meetings', (tester) async {
      mockProvider.setMeetings([]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada pertemuan'), findsOneWidget);
      expect(find.byIcon(Icons.event_note), findsOneWidget);
    });

    testWidgets('displays list of meetings when data exists', (tester) async {
      mockProvider.setMeetings([
        createTestMeeting(id: '1', title: 'Meeting 1', status: 'scheduled'),
        createTestMeeting(id: '2', title: 'Meeting 2', status: 'ongoing'),
        createTestMeeting(id: '3', title: 'Meeting 3', status: 'completed'),
      ]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Meeting 1'), findsOneWidget);
      expect(find.text('Meeting 2'), findsOneWidget);
      expect(find.text('Meeting 3'), findsOneWidget);
    });

    testWidgets('displays error state when loading fails', (tester) async {
      mockProvider.setError('Network error');
      mockProvider.setMeetings([]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('displays correct status badges', (tester) async {
      mockProvider.setMeetings([
        createTestMeeting(id: '1', title: 'Scheduled Meeting', status: 'scheduled'),
        createTestMeeting(id: '2', title: 'Ongoing Meeting', status: 'ongoing'),
        createTestMeeting(id: '3', title: 'Completed Meeting', status: 'completed'),
      ]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Dijadwalkan'), findsOneWidget);
      expect(find.text('Berlangsung'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
    });

    testWidgets('displays meeting type indicator', (tester) async {
      mockProvider.setMeetings([
        createTestMeeting(id: '1', title: 'Online Meeting', meetingType: 'online'),
        createTestMeeting(id: '2', title: 'Offline Meeting', meetingType: 'offline'),
      ]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Online Meeting'), findsOneWidget);
      expect(find.text('Offline Meeting'), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsWidgets);
      expect(find.byIcon(Icons.location_on), findsWidgets);
    });

    testWidgets('displays "Buka Meeting" button for online meetings', (tester) async {
      mockProvider.setMeetings([
        createTestMeeting(
          id: '1',
          title: 'Online Meeting',
          meetingType: 'online',
          status: 'scheduled',
          meetingLink: 'https://meet.google.com/xxx',
        ),
      ]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Buka Meeting'), findsOneWidget);
    });

    testWidgets('AppBar displays class name', (tester) async {
      mockProvider.setMeetings([]);

      await tester.pumpWidget(createTestWidget(
        mockProvider: mockProvider,
        className: 'Matematika Dasar',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Pertemuan - Matematika Dasar'), findsOneWidget);
    });

    testWidgets('does not show FAB (student cannot create meetings)', (tester) async {
      mockProvider.setMeetings([]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('does not show edit/delete buttons (student view)', (tester) async {
      mockProvider.setMeetings([
        createTestMeeting(id: '1', title: 'Meeting 1'),
      ]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
    });

    testWidgets('displays meeting date and time', (tester) async {
      final meetingDate = DateTime(2025, 12, 15, 14, 30);
      mockProvider.setMeetings([
        createTestMeeting(id: '1', title: 'Meeting 1', meetingDate: meetingDate),
      ]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.textContaining('15'), findsWidgets);
      expect(find.textContaining('14:30'), findsOneWidget);
    });
  });
}
