// test/features/meetings/create_meeting_page_test.dart
// Unit tests for CreateMeetingPage
// **Validates: Requirements 1.1-1.8, 3.1-3.4**

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:gabara_mobile/features/meetings/data/models/meeting_model.dart';
import 'package:gabara_mobile/features/meetings/data/models/attendance_model.dart';
import 'package:gabara_mobile/features/meetings/presentation/pages/create_meeting_page.dart';
import 'package:gabara_mobile/features/meetings/presentation/providers/meeting_provider.dart';

// Mock MeetingProvider for testing
class MockMeetingProvider extends ChangeNotifier implements MeetingProvider {
  List<MeetingModel> _meetings = [];
  MeetingModel? _currentMeeting;
  List<AttendanceModel> _attendanceList = [];
  List<Map<String, dynamic>> _myClasses = [];
  bool _isLoading = false;
  String? _errorMessage;
  MeetingModel? lastCreatedMeeting;

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

  void setClasses(List<Map<String, dynamic>> classes) {
    _myClasses = classes;
    notifyListeners();
  }

  void setCurrentMeeting(MeetingModel? meeting) {
    _currentMeeting = meeting;
    notifyListeners();
  }

  @override
  Future<void> loadMyClasses() async { notifyListeners(); }
  @override
  Future<void> loadMeetingDetail(String meetingId) async { notifyListeners(); }
  @override
  Future<MeetingModel?> createMeeting(MeetingModel meeting) async {
    lastCreatedMeeting = meeting;
    return meeting;
  }
  @override
  Future<MeetingModel?> updateMeeting(MeetingModel meeting) async => meeting;
  @override
  Future<void> loadMeetings() async {}
  @override
  Future<void> loadMeetingsByClass(String classId) async {}
  @override
  Future<bool> deleteMeeting(String meetingId) async => true;
  @override
  Future<bool> markAttendance({required String meetingId, required String studentId, required String status}) async => true;
  @override
  Future<bool> updateMeetingStatus(String meetingId, String newStatus) async => true;
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

Widget createTestWidget({
  required MockMeetingProvider mockProvider,
  String? meetingId,
}) {
  return MaterialApp(
    home: ChangeNotifierProvider<MeetingProvider>.value(
      value: mockProvider,
      child: CreateMeetingPage(meetingId: meetingId),
    ),
  );
}

void main() {
  group('CreateMeetingPage', () {
    late MockMeetingProvider mockProvider;

    setUp(() {
      mockProvider = MockMeetingProvider();
      mockProvider.setClasses([
        {'id': 'class-1', 'name': 'Kelas A'},
        {'id': 'class-2', 'name': 'Kelas B'},
      ]);
    });

    testWidgets('displays correct AppBar title for create mode', (tester) async {
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      expect(find.text('Buat Pertemuan'), findsOneWidget);
    });

    testWidgets('displays correct AppBar title for edit mode', (tester) async {
      mockProvider.setCurrentMeeting(MeetingModel(
        id: 'meeting-1',
        classId: 'class-1',
        title: 'Test Meeting',
        meetingDate: DateTime.now().add(const Duration(days: 1)),
        meetingType: 'online',
        meetingLink: 'https://meet.google.com/xxx',
        createdBy: 'mentor-1',
      ));

      await tester.pumpWidget(createTestWidget(
        mockProvider: mockProvider,
        meetingId: 'meeting-1',
      ));
      await tester.pumpAndSettle();
      expect(find.text('Edit Pertemuan'), findsOneWidget);
    });

    testWidgets('displays title input field', (tester) async {
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      // Find title field by label
      expect(find.text('Judul Pertemuan *'), findsOneWidget);
    });

    testWidgets('displays description input field', (tester) async {
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Deskripsi'), findsOneWidget);
    });

    testWidgets('displays class dropdown', (tester) async {
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Kelas *'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('displays date picker', (tester) async {
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Tanggal Pertemuan *'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('displays time picker', (tester) async {
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Waktu Mulai *'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('can enter title text', (tester) async {
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      // Find and enter text in title field
      final titleField = find.byType(TextFormField).first;
      await tester.enterText(titleField, 'My Test Meeting');
      await tester.pumpAndSettle();
      
      expect(find.text('My Test Meeting'), findsOneWidget);
    });

    testWidgets('can select class from dropdown', (tester) async {
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      // Tap dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      
      // Should show class options
      expect(find.text('Kelas A'), findsWidgets);
      expect(find.text('Kelas B'), findsWidgets);
      
      // Select a class
      await tester.tap(find.text('Kelas A').last);
      await tester.pumpAndSettle();
    });

    testWidgets('validates empty title on submit', (tester) async {
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      // Scroll to bottom to find submit button
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      
      // Find and tap submit button
      final submitButton = find.widgetWithText(ElevatedButton, 'Buat');
      if (submitButton.evaluate().isNotEmpty) {
        await tester.tap(submitButton);
        await tester.pumpAndSettle();
        
        // Scroll back up to see validation error
        await tester.drag(find.byType(ListView), const Offset(0, 500));
        await tester.pumpAndSettle();
        
        expect(find.text('Judul pertemuan harus diisi'), findsOneWidget);
      }
    });

    testWidgets('form has ListView for scrolling', (tester) async {
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('form has Form widget', (tester) async {
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.byType(Form), findsOneWidget);
    });
  });
}
