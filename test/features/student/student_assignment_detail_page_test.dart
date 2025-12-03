// test/features/student/student_assignment_detail_page_test.dart
// Unit tests for StudentAssignmentDetailPage
// **Validates: Requirements 12.1-12.6**

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gabara_mobile/features/meetings/data/models/meeting_model.dart';
import 'package:gabara_mobile/features/meetings/data/services/meeting_service.dart';
import 'package:gabara_mobile/features/assignments/data/models/assignment_model.dart';
import 'package:gabara_mobile/features/assignments/data/models/submission_model.dart';
import 'package:gabara_mobile/features/assignments/data/services/assignment_service.dart';
import 'package:gabara_mobile/features/student/presentation/pages/student_assignment_detail_page.dart';
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

  void setCurrentAssignment(AssignmentModel? assignment) {
    _currentAssignment = assignment;
    notifyListeners();
  }

  void setMySubmission(SubmissionModel? submission) {
    _mySubmission = submission;
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
  Future<void> loadAssignments(String classId) async {}

  @override
  Future<void> loadAssignmentDetail(String assignmentId) async {
    notifyListeners();
  }

  @override
  Future<bool> submitAssignment(SubmissionModel submission) async {
    _mySubmission = submission.copyWith(status: 'submitted', submittedAt: DateTime.now());
    notifyListeners();
    return true;
  }

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

// Test helper to create SubmissionModel
SubmissionModel createTestSubmission({
  required String id,
  required String assignmentId,
  String content = 'Test submission content',
  String status = 'submitted',
  DateTime? submittedAt,
  double? score,
  String? feedback,
}) {
  return SubmissionModel(
    id: id,
    assignmentId: assignmentId,
    studentId: 'student-1',
    content: content,
    status: status,
    submittedAt: submittedAt ?? DateTime.now(),
    score: score,
    feedback: feedback,
  );
}

// Helper widget to wrap test widgets with necessary providers
Widget createTestWidget({
  required MockStudentProvider mockProvider,
  String assignmentId = 'assignment-1',
}) {
  return MaterialApp(
    home: ChangeNotifierProvider<StudentProvider>.value(
      value: mockProvider,
      child: StudentAssignmentDetailPage(assignmentId: assignmentId),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id', null);
  });

  group('StudentAssignmentDetailPage', () {
    late MockStudentProvider mockProvider;

    setUp(() {
      mockProvider = MockStudentProvider();
    });

    testWidgets('displays loading indicator when loading', (tester) async {
      mockProvider.setLoading(true);
      mockProvider.setCurrentAssignment(null);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error state when loading fails', (tester) async {
      mockProvider.setError('Network error');
      mockProvider.setCurrentAssignment(null);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('displays assignment not found when assignment is null', (tester) async {
      mockProvider.setCurrentAssignment(null);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Tugas tidak ditemukan'), findsOneWidget);
    });

    testWidgets('displays assignment title and status', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment(
        id: '1',
        title: 'Flutter Assignment',
        deadline: DateTime.now().add(const Duration(days: 7)),
      ));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Flutter Assignment'), findsOneWidget);
      expect(find.text('Aktif'), findsOneWidget);
    });

    testWidgets('displays assignment description', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment(
        id: '1',
        title: 'Assignment',
        description: 'Complete the following exercises.',
      ));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Complete the following exercises.'), findsOneWidget);
    });

    testWidgets('displays max score', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment(
        id: '1',
        title: 'Assignment',
        maxScore: 100,
      ));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.textContaining('100'), findsWidgets);
    });

    testWidgets('displays submission form when not submitted', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment(
        id: '1',
        title: 'Assignment',
        deadline: DateTime.now().add(const Duration(days: 7)),
      ));
      mockProvider.setMySubmission(null);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Kumpulkan Tugas'), findsOneWidget);
      expect(find.text('Kumpulkan'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('displays submission status when submitted', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment(id: '1', title: 'Assignment'));
      mockProvider.setMySubmission(createTestSubmission(
        id: 'sub-1',
        assignmentId: '1',
        status: 'submitted',
      ));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Menunggu Penilaian'), findsOneWidget);
    });

    testWidgets('displays grade when submission is graded', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment(
        id: '1',
        title: 'Assignment',
        maxScore: 100,
      ));
      mockProvider.setMySubmission(createTestSubmission(
        id: 'sub-1',
        assignmentId: '1',
        status: 'graded',
        score: 85,
        feedback: 'Good work!',
      ));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Sudah Dinilai'), findsOneWidget);
      expect(find.text('85'), findsOneWidget);
      expect(find.text('Good work!'), findsOneWidget);
    });

    testWidgets('displays late status for late submissions', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment(id: '1', title: 'Assignment'));
      mockProvider.setMySubmission(createTestSubmission(
        id: 'sub-1',
        assignmentId: '1',
        status: 'late',
      ));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Terlambat'), findsOneWidget);
    });

    testWidgets('displays "Tertutup" badge for past deadline', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment(
        id: '1',
        title: 'Assignment',
        deadline: DateTime.now().subtract(const Duration(days: 1)),
      ));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Tertutup'), findsOneWidget);
    });

    testWidgets('disables form when deadline passed', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment(
        id: '1',
        title: 'Assignment',
        deadline: DateTime.now().subtract(const Duration(days: 1)),
      ));
      mockProvider.setMySubmission(null);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      // Should show warning about deadline
      expect(find.textContaining('Deadline sudah lewat'), findsOneWidget);
    });

    testWidgets('displays feedback section when graded', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment(id: '1', title: 'Assignment'));
      mockProvider.setMySubmission(createTestSubmission(
        id: 'sub-1',
        assignmentId: '1',
        status: 'graded',
        score: 90,
        feedback: 'Excellent work! Keep it up.',
      ));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Feedback dari Mentor:'), findsOneWidget);
      expect(find.text('Excellent work! Keep it up.'), findsOneWidget);
    });

    testWidgets('displays percentage when graded', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment(
        id: '1',
        title: 'Assignment',
        maxScore: 100,
      ));
      mockProvider.setMySubmission(createTestSubmission(
        id: 'sub-1',
        assignmentId: '1',
        status: 'graded',
        score: 85,
      ));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('85.0%'), findsOneWidget);
    });

    testWidgets('AppBar displays correct title', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment(id: '1', title: 'Assignment'));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Detail Tugas'), findsOneWidget);
    });

    testWidgets('displays submission form with validation', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment(
        id: '1',
        title: 'Assignment',
        deadline: DateTime.now().add(const Duration(days: 7)),
      ));
      mockProvider.setMySubmission(null);

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      // Verify form elements are present
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Kumpulkan'), findsOneWidget);
    });

    testWidgets('displays "Update Jawaban" when already submitted', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment(
        id: '1',
        title: 'Assignment',
        deadline: DateTime.now().add(const Duration(days: 7)),
      ));
      mockProvider.setMySubmission(createTestSubmission(
        id: 'sub-1',
        assignmentId: '1',
        status: 'submitted',
        content: 'My answer',
      ));

      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Edit Jawaban'), findsOneWidget);
      expect(find.text('Update Jawaban'), findsOneWidget);
    });
  });
}
