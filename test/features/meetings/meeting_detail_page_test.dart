// test/features/meetings/meeting_detail_page_test.dart
// Unit tests for MeetingDetailPage
// **Validates: Requirements 2.1-2.9, 15.1-15.5**

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:gabara_mobile/features/meetings/data/models/meeting_model.dart';
import 'package:gabara_mobile/features/meetings/data/models/attendance_model.dart';
import 'package:gabara_mobile/features/meetings/presentation/pages/meeting_detail_page.dart';
import 'package:gabara_mobile/features/meetings/presentation/providers/meeting_provider.dart';

// Mock MeetingProvider for testing
class MockMeetingProvider extends ChangeNotifier implements MeetingProvider {
  List<MeetingModel> _meetings = [];
  MeetingModel? _currentMeeting;
  List<AttendanceModel> _attendanceList = [];
  List<Map<String, dynamic>> _myClasses = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? lastUpdatedStatus;
  String? lastMarkedStudentId;
  String? lastMarkedStatus;

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

  void setCurrentMeeting(MeetingModel? meeting) {
    _currentMeeting = meeting;
    notifyListeners();
  }

  void setAttendanceList(List<AttendanceModel> list) {
    _attendanceList = list;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  Future<void> loadMeetingDetail(String meetingId) async {
    notifyListeners();
  }

  @override
  Future<bool> updateMeetingStatus(String meetingId, String newStatus) async {
    lastUpdatedStatus = newStatus;
    if (_currentMeeting != null) {
      _currentMeeting = MeetingModel(
        id: _currentMeeting!.id,
        classId: _currentMeeting!.classId,
        title: _currentMeeting!.title,
        description: _currentMeeting!.description,
        meetingDate: _currentMeeting!.meetingDate,
        durationMinutes: _currentMeeting!.durationMinutes,
        meetingType: _currentMeeting!.meetingType,
        meetingLink: _currentMeeting!.meetingLink,
        location: _currentMeeting!.location,
        status: newStatus,
        createdBy: _currentMeeting!.createdBy,
      );
      notifyListeners();
    }
    return true;
  }

  @override
  Future<bool> markAttendance({
    required String meetingId,
    required String studentId,
    required String status,
  }) async {
    lastMarkedStudentId = studentId;
    lastMarkedStatus = status;
    return true;
  }

  @override
  Future<bool> deleteMeeting(String meetingId) async => true;
  @override
  Future<void> loadMeetings() async {}
  @override
  Future<void> loadMeetingsByClass(String classId) async {}
  @override
  Future<void> loadMyClasses() async {}
  @override
  Future<MeetingModel?> createMeeting(MeetingModel meeting) async => meeting;
  @override
  Future<MeetingModel?> updateMeeting(MeetingModel meeting) async => meeting;
  @override
  List<MeetingModel> getMeetingsByStatus(String status) => [];
  @override
  List<MeetingModel> get upcomingMeetings => [];
  @override
  List<MeetingModel> get pastMeetings => [];
  @override
  void clearCurrentMeeting() {}
  @override
  void clearError() { _errorMessage = null; notifyListeners(); }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}


// Test helper
MeetingModel createTestMeeting({
  String id = 'meeting-1',
  String title = 'Test Meeting',
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

AttendanceModel createTestAttendance({
  String id = 'att-1',
  String studentId = 'student-1',
  String studentName = 'John Doe',
  String status = 'present',
}) {
  return AttendanceModel(
    id: id,
    meetingId: 'meeting-1',
    studentId: studentId,
    studentName: studentName,
    status: status,
    markedAt: DateTime.now(),
  );
}

Widget createTestWidget({
  required MockMeetingProvider mockProvider,
  String meetingId = 'meeting-1',
}) {
  return MaterialApp(
    home: ChangeNotifierProvider<MeetingProvider>.value(
      value: mockProvider,
      child: MeetingDetailPage(meetingId: meetingId),
    ),
  );
}

void main() {
  group('MeetingDetailPage', () {
    late MockMeetingProvider mockProvider;

    setUp(() {
      mockProvider = MockMeetingProvider();
    });

    testWidgets('displays loading indicator when loading', (tester) async {
      mockProvider.setLoading(true);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pump();
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays not found message when meeting is null', (tester) async {
      mockProvider.setCurrentMeeting(null);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Pertemuan tidak ditemukan'), findsOneWidget);
    });

    testWidgets('displays meeting title', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting(title: 'My Meeting'));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('My Meeting'), findsOneWidget);
    });

    testWidgets('displays meeting description', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting());
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Test description'), findsOneWidget);
    });

    testWidgets('displays scheduled status badge', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting(status: 'scheduled'));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Dijadwalkan'), findsOneWidget);
    });

    testWidgets('displays ongoing status badge', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting(status: 'ongoing'));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Berlangsung'), findsOneWidget);
    });

    testWidgets('displays completed status badge', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting(status: 'completed'));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Selesai'), findsOneWidget);
    });

    testWidgets('displays cancelled status badge', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting(status: 'cancelled'));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Dibatalkan'), findsOneWidget);
    });

    testWidgets('displays meeting link for online meetings', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting(meetingType: 'online'));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Meeting Link'), findsOneWidget);
      expect(find.text('https://meet.google.com/xxx'), findsOneWidget);
    });

    testWidgets('displays location for offline meetings', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting(meetingType: 'offline'));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Lokasi'), findsOneWidget);
      expect(find.text('Room 101'), findsOneWidget);
    });

    testWidgets('displays edit button in AppBar', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting());
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('displays delete button in AppBar', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting());
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('displays attendance section', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting());
      mockProvider.setAttendanceList([]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Kehadiran'), findsOneWidget);
    });

    testWidgets('displays empty attendance message', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting());
      mockProvider.setAttendanceList([]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Belum ada data kehadiran'), findsOneWidget);
    });

    testWidgets('displays attendance list with students', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting());
      mockProvider.setAttendanceList([
        createTestAttendance(studentName: 'John Doe', status: 'present'),
        createTestAttendance(id: 'att-2', studentId: 'student-2', studentName: 'Jane Smith', status: 'absent'),
      ]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('2 siswa'), findsOneWidget);
    });

    testWidgets('displays start button for scheduled meetings', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting(status: 'scheduled'));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Mulai'), findsOneWidget);
    });

    testWidgets('displays complete button for ongoing meetings', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting(status: 'ongoing'));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Selesai'), findsWidgets);
    });

    testWidgets('shows delete confirmation dialog', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting());
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      
      // Should show confirmation dialog
      expect(find.text('Hapus Pertemuan'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);
    });

    testWidgets('displays status section', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting());
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Status Pertemuan'), findsOneWidget);
    });

    testWidgets('displays AppBar title', (tester) async {
      mockProvider.setCurrentMeeting(createTestMeeting());
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Detail Pertemuan'), findsOneWidget);
    });
  });
}
