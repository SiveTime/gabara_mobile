// test/features/student/student_assignment_list_page_test.dart
// Unit tests for StudentAssignmentListPage
// **Validates: Requirements 11.1-11.8**

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:gabara_mobile/features/meetings/data/models/meeting_model.dart';
import 'package:gabara_mobile/features/meetings/data/services/meeting_service.dart';
import 'package:gabara_mobile/features/assignments/data/models/assignment_model.dart';
import 'package:gabara_mobile/features/assignments/data/models/submission_model.dart';
import 'package:gabara_mobile/features/assignments/data/services/assignment_service.dart';
import 'package:gabara_mobile/features/student/presentation/pages/student_assignment_list_page.dart';
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

  void setAssignments(List<AssignmentModel> assignments) {
    _assignments = assignments;
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
  Future<void> loadMeetingDetail(String meetingId) async {}

  @override
  Future<void> loadAssignments(String classId) async {
    _selectedClassId = classId;
    notifyListeners();
  }

  @override
  Future<void> loadAssignmentDetail(String assignmentId) async {}

  @override
  Future<bool> submitAssignment(SubmissionModel submission) async => true;

  @override
  List<MeetingModel> get upcomingMeetings => [];

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

// Test helper to create AssignmentModel
AssignmentModel createTestAssignment({
  required String id,
  required String title,
  String description = 'Test description',
  DateTime? deadline,
  int maxScore = 100,
  bool isActive = true,
  String? attachmentUrl,
}) {
  return AssignmentModel(
    id: id,
    classId: 'class-1',
    title: title,
    description: description,
    deadline: deadline ?? DateTime.now().add(const Duration(days: 7)),
    maxScore: maxScore,
    attachmentUrl: attachmentUrl,
    isActive: isActive,
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
      child: StudentAssignmentListPage(classId: classId, className: className),
    ),
  );
}

void main() {
  group('StudentAssignmentListPage', () {
    late MockStudentProvider mockProvider;

    setUp(() {
      mockProvider = MockStudentProvider();
    });

    testWidgets('displays loading indicator when loading', (tester) async {
      mockProvider.setLoading(true);
      mockProvider.setAssignments([]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays empty state when no assignments', (tester) async {
      mockProvider.setAssignments([]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada tugas'), findsOneWidget);
      expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
    });

    testWidgets('displays list of assignments when data exists', (tester) async {
      mockProvider.setAssignments([
        createTestAssignment(id: '1', title: 'Assignment 1'),
        createTestAssignment(id: '2', title: 'Assignment 2'),
        createTestAssignment(id: '3', title: 'Assignment 3'),
      ]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Assignment 1'), findsOneWidget);
      expect(find.text('Assignment 2'), findsOneWidget);
      expect(find.text('Assignment 3'), findsOneWidget);
    });

    testWidgets('displays error state when loading fails', (tester) async {
      mockProvider.setError('Network error');
      mockProvider.setAssignments([]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('displays "Aktif" badge for active assignments', (tester) async {
      mockProvider.setAssignments([
        createTestAssignment(
          id: '1',
          title: 'Active Assignment',
          deadline: DateTime.now().add(const Duration(days: 7)),
        ),
      ]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Aktif'), findsOneWidget);
    });

    testWidgets('displays "Tertutup" badge for past deadline assignments', (tester) async {
      mockProvider.setAssignments([
        createTestAssignment(
          id: '1',
          title: 'Closed Assignment',
          deadline: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Tertutup'), findsOneWidget);
    });

    testWidgets('displays max score for each assignment', (tester) async {
      mockProvider.setAssignments([
        createTestAssignment(id: '1', title: 'Assignment', maxScore: 100),
      ]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Nilai Maksimal: 100'), findsOneWidget);
    });

    testWidgets('displays attachment indicator when assignment has attachment', (tester) async {
      mockProvider.setAssignments([
        createTestAssignment(
          id: '1',
          title: 'Assignment with Attachment',
          attachmentUrl: 'https://example.com/file.pdf',
        ),
      ]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Ada lampiran'), findsOneWidget);
      expect(find.byIcon(Icons.attach_file), findsWidgets);
    });

    testWidgets('displays description preview', (tester) async {
      mockProvider.setAssignments([
        createTestAssignment(
          id: '1',
          title: 'Assignment',
          description: 'This is a detailed description of the assignment.',
        ),
      ]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('This is a detailed description of the assignment.'), findsOneWidget);
    });

    testWidgets('AppBar displays class name', (tester) async {
      mockProvider.setAssignments([]);

      await tester.pumpWidget(createTestWidget(
        mockProvider: mockProvider,
        className: 'Matematika Dasar',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Tugas - Matematika Dasar'), findsOneWidget);
    });

    testWidgets('does not show FAB (student cannot create assignments)', (tester) async {
      mockProvider.setAssignments([]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('does not show edit/delete buttons (student view)', (tester) async {
      mockProvider.setAssignments([
        createTestAssignment(id: '1', title: 'Assignment 1'),
      ]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
    });

    testWidgets('displays deadline with schedule icon', (tester) async {
      mockProvider.setAssignments([
        createTestAssignment(
          id: '1',
          title: 'Assignment',
          deadline: DateTime(2025, 12, 31, 23, 59),
        ),
      ]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.schedule), findsWidgets);
      expect(find.textContaining('Deadline'), findsOneWidget);
    });

    testWidgets('displays star icon for max score', (tester) async {
      mockProvider.setAssignments([
        createTestAssignment(id: '1', title: 'Assignment'),
      ]);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star_outline), findsWidgets);
    });
  });
}
