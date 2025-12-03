// test/features/meetings/meeting_list_page_test.dart
// Unit tests for MeetingListPage
// **Validates: Requirements 2.1-2.9**

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:gabara_mobile/features/meetings/data/models/meeting_model.dart';
import 'package:gabara_mobile/features/meetings/data/models/attendance_model.dart';
import 'package:gabara_mobile/features/meetings/presentation/pages/meeting_list_page.dart';
import 'package:gabara_mobile/features/meetings/presentation/providers/meeting_provider.dart';

// Mock MeetingProvider for testing (simpler approach without mocking service)
class MockMeetingProvider extends ChangeNotifier implements MeetingProvider {
  List<MeetingModel> _meetings = [];
  MeetingModel? _currentMeeting;
  List<AttendanceModel> _attendanceList = [];
  List<Map<String, dynamic>> _myClasses = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool shouldThrowError = false;

  @override
  List<MeetingModel> get meetings => _meetings;
  
  @override
  MeetingModel? get currentMeeting => _currentMeeting;
  
  @override
  List<AttendanceModel> get attendanceList => _attendanceList;
  
  @override
  List<Map<String, dynamic>> get myClasses => _myClasses;
  
  @override
  bool get isLoading => _isLoading;
  
  @override
  String? get errorMessage => _errorMessage;

  void setMeetings(List<MeetingModel> meetings) {
    _meetings = meetings;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  Future<void> loadMeetings() async {
    if (shouldThrowError) {
      _errorMessage = 'Network error';
    }
    notifyListeners();
  }

  @override
  Future<void> loadMeetingsByClass(String classId) async {}

  @override
  Future<void> loadMeetingDetail(String meetingId) async {}

  @override
  Future<MeetingModel?> createMeeting(MeetingModel meeting) async => meeting;

  @override
  Future<MeetingModel?> updateMeeting(MeetingModel meeting) async => meeting;

  @override
  Future<bool> deleteMeeting(String meetingId) async {
    _meetings.removeWhere((m) => m.id == meetingId);
    notifyListeners();
    return true;
  }

  @override
  Future<bool> markAttendance({
    required String meetingId,
    required String studentId,
    required String status,
  }) async => true;

  @override
  Future<bool> updateMeetingStatus(String meetingId, String newStatus) async => true;

  @override
  Future<void> loadMyClasses() async {}

  @override
  List<MeetingModel> getMeetingsByStatus(String status) {
    return _meetings.where((m) => m.status == status).toList();
  }

  @override
  List<MeetingModel> get upcomingMeetings => _meetings;

  @override
  List<MeetingModel> get pastMeetings => [];

  @override
  void clearCurrentMeeting() {}

  @override
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

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
}) {
  return MeetingModel(
    id: id,
    classId: 'class-1',
    title: title,
    description: 'Test description',
    meetingDate: meetingDate ?? DateTime.now().add(const Duration(days: 1)),
    durationMinutes: 60,
    meetingType: meetingType,
    meetingLink: meetingType == 'online' ? 'https://meet.google.com/xxx' : null,
    location: meetingType == 'offline' ? 'Room 101' : null,
    status: status,
    createdBy: 'mentor-1',
  );
}


// Helper widget to wrap test widgets with necessary providers
Widget createTestWidget({
  required MockMeetingProvider mockProvider,
}) {
  return MaterialApp(
    home: ChangeNotifierProvider<MeetingProvider>.value(
      value: mockProvider,
      child: const MeetingListPage(),
    ),
  );
}

void main() {
  group('MeetingListPage', () {
    late MockMeetingProvider mockProvider;

    setUp(() {
      mockProvider = MockMeetingProvider();
    });

    testWidgets('displays loading indicator when loading', (tester) async {
      mockProvider.setLoading(true);
      mockProvider.setMeetings([]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pump(); // Just pump once, don't settle
      
      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays empty state when no meetings', (tester) async {
      mockProvider.setMeetings([]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      // Should show empty state message
      expect(find.text('Belum ada pertemuan'), findsOneWidget);
      expect(find.text('Tap tombol + untuk membuat pertemuan baru'), findsOneWidget);
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
      
      // Should display all meetings
      expect(find.text('Meeting 1'), findsOneWidget);
      expect(find.text('Meeting 2'), findsOneWidget);
      expect(find.text('Meeting 3'), findsOneWidget);
    });

    testWidgets('displays FAB to create new meeting', (tester) async {
      mockProvider.setMeetings([]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      // Should show FAB with create button
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Buat Pertemuan'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('displays error state when loading fails', (tester) async {
      mockProvider.setError('Network error');
      mockProvider.setMeetings([]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      // Should show error message and retry button
      expect(find.textContaining('Error'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('refresh button triggers reload', (tester) async {
      mockProvider.setMeetings([
        createTestMeeting(id: '1', title: 'Meeting 1'),
      ]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      // Find and tap refresh button
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);
      
      await tester.tap(refreshButton);
      await tester.pumpAndSettle();
      
      // Meeting should still be displayed after refresh
      expect(find.text('Meeting 1'), findsOneWidget);
    });

    testWidgets('shows delete confirmation dialog', (tester) async {
      mockProvider.setMeetings([
        createTestMeeting(id: '1', title: 'Meeting to Delete'),
      ]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      // Find delete button on meeting card and tap it
      final deleteButton = find.byIcon(Icons.delete);
      expect(deleteButton, findsOneWidget);
      
      await tester.tap(deleteButton.first);
      await tester.pumpAndSettle();
      
      // Should show confirmation dialog
      expect(find.text('Hapus Pertemuan'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);
    });

    testWidgets('cancel button closes delete dialog', (tester) async {
      mockProvider.setMeetings([
        createTestMeeting(id: '1', title: 'Meeting to Delete'),
      ]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      // Find delete button and tap it
      final deleteButton = find.byIcon(Icons.delete);
      await tester.tap(deleteButton.first);
      await tester.pumpAndSettle();
      
      // Tap cancel button
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      
      // Dialog should be closed, meeting still exists
      expect(find.text('Meeting to Delete'), findsOneWidget);
    });

    testWidgets('displays correct status badges', (tester) async {
      mockProvider.setMeetings([
        createTestMeeting(id: '1', title: 'Scheduled Meeting', status: 'scheduled'),
        createTestMeeting(id: '2', title: 'Ongoing Meeting', status: 'ongoing'),
        createTestMeeting(id: '3', title: 'Completed Meeting', status: 'completed'),
      ]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      // Should display status badges (MeetingCard uses these labels)
      expect(find.text('Dijadwalkan'), findsOneWidget);
      expect(find.text('Sedang Berlangsung'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
    });

    testWidgets('displays cancelled status badge', (tester) async {
      mockProvider.setMeetings([
        createTestMeeting(id: '1', title: 'Cancelled Meeting', status: 'cancelled'),
      ]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Dibatalkan'), findsOneWidget);
    });

    testWidgets('displays meeting type indicator', (tester) async {
      mockProvider.setMeetings([
        createTestMeeting(id: '1', title: 'Online Meeting', meetingType: 'online'),
        createTestMeeting(id: '2', title: 'Offline Meeting', meetingType: 'offline'),
      ]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      // Should display both meetings
      expect(find.text('Online Meeting'), findsOneWidget);
      expect(find.text('Offline Meeting'), findsOneWidget);
      
      // Should have video icon for online and location icon for offline
      expect(find.byIcon(Icons.videocam), findsWidgets);
      expect(find.byIcon(Icons.location_on), findsWidgets);
    });

    testWidgets('AppBar displays correct title', (tester) async {
      mockProvider.setMeetings([]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      // Should display correct title
      expect(find.text('Pertemuan'), findsOneWidget);
    });
  });
}
