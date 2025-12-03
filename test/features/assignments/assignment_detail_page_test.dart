// test/features/assignments/assignment_detail_page_test.dart
// Unit tests for AssignmentDetailPage
// **Validates: Requirements 6.1-6.6, 9.1-9.5**

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:gabara_mobile/features/assignments/data/models/assignment_model.dart';
import 'package:gabara_mobile/features/assignments/data/models/submission_model.dart';
import 'package:gabara_mobile/features/assignments/presentation/pages/assignment_detail_page.dart';
import 'package:gabara_mobile/features/assignments/presentation/providers/assignment_provider.dart';

// Mock AssignmentProvider for testing
class MockAssignmentProvider extends ChangeNotifier implements AssignmentProvider {
  List<AssignmentModel> _assignments = [];
  AssignmentModel? _currentAssignment;
  List<SubmissionModel> _submissions = [];
  SubmissionModel? _currentSubmission;
  List<Map<String, dynamic>> _myClasses = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasSubmissions = false;
  int _gradedCount = 0;
  int _pendingCount = 0;

  @override
  List<AssignmentModel> get assignments => _assignments;
  @override
  AssignmentModel? get currentAssignment => _currentAssignment;
  @override
  List<SubmissionModel> get submissions => _submissions;
  @override
  SubmissionModel? get currentSubmission => _currentSubmission;
  @override
  List<Map<String, dynamic>> get myClasses => _myClasses;
  @override
  bool get isLoading => _isLoading;
  @override
  String? get errorMessage => _errorMessage;
  @override
  bool get hasSubmissions => _hasSubmissions;
  @override
  int get gradedCount => _gradedCount;
  @override
  int get pendingCount => _pendingCount;

  void setCurrentAssignment(AssignmentModel? assignment) {
    _currentAssignment = assignment;
    notifyListeners();
  }

  void setSubmissions(List<SubmissionModel> submissions) {
    _submissions = submissions;
    _gradedCount = submissions.where((s) => s.status == 'graded').length;
    _pendingCount = submissions.where((s) => s.status != 'graded' && s.status != 'draft').length;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  Future<void> loadAssignmentDetail(String assignmentId) async { notifyListeners(); }
  @override
  Future<void> loadAssignments() async {}
  @override
  Future<void> loadAssignmentsByClass(String classId) async {}
  @override
  Future<AssignmentModel?> createAssignment(AssignmentModel assignment) async => assignment;
  @override
  Future<AssignmentModel?> updateAssignment(AssignmentModel assignment) async => assignment;
  @override
  Future<bool> deleteAssignment(String assignmentId) async => true;
  @override
  Future<bool> gradeSubmission({required String submissionId, required double score, required String feedback}) async => true;
  @override
  Future<void> loadSubmissionDetail(String submissionId) async {}
  @override
  Future<void> loadMyClasses() async {}
  @override
  void clearCurrentAssignment() {}
  @override
  void clearError() { _errorMessage = null; notifyListeners(); }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}


AssignmentModel createTestAssignment({
  String id = 'assignment-1',
  String title = 'Test Assignment',
  DateTime? deadline,
  int maxScore = 100,
}) {
  return AssignmentModel(
    id: id,
    classId: 'class-1',
    title: title,
    description: 'Test description',
    deadline: deadline ?? DateTime.now().add(const Duration(days: 7)),
    maxScore: maxScore,
    createdBy: 'mentor-1',
  );
}

SubmissionModel createTestSubmission({
  String id = 'sub-1',
  String studentId = 'student-1',
  String studentName = 'John Doe',
  String status = 'submitted',
  double? score,
}) {
  return SubmissionModel(
    id: id,
    assignmentId: 'assignment-1',
    studentId: studentId,
    content: 'Test content',
    status: status,
    submittedAt: DateTime.now(),
    score: score,
    studentName: studentName,
  );
}

Widget createTestWidget({
  required MockAssignmentProvider mockProvider,
  String assignmentId = 'assignment-1',
}) {
  return MaterialApp(
    home: ChangeNotifierProvider<AssignmentProvider>.value(
      value: mockProvider,
      child: AssignmentDetailPage(assignmentId: assignmentId),
    ),
  );
}

void main() {
  group('AssignmentDetailPage', () {
    late MockAssignmentProvider mockProvider;

    setUp(() {
      mockProvider = MockAssignmentProvider();
    });

    testWidgets('displays loading indicator when loading', (tester) async {
      mockProvider.setLoading(true);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pump();
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays not found message when assignment is null', (tester) async {
      mockProvider.setCurrentAssignment(null);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Tugas tidak ditemukan'), findsOneWidget);
    });

    testWidgets('displays assignment title', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment(title: 'My Assignment'));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('My Assignment'), findsOneWidget);
    });

    testWidgets('displays assignment description', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment());
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Test description'), findsOneWidget);
    });

    testWidgets('displays active status badge for future deadline', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment(
        deadline: DateTime.now().add(const Duration(days: 7)),
      ));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Aktif'), findsOneWidget);
    });

    testWidgets('displays closed status badge for past deadline', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment(
        deadline: DateTime.now().subtract(const Duration(days: 1)),
      ));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Tertutup'), findsOneWidget);
    });

    testWidgets('displays max score', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment(maxScore: 100));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('100 poin'), findsOneWidget);
    });

    testWidgets('displays edit button in AppBar', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment());
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('displays delete button in AppBar', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment());
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('displays submissions section', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment());
      mockProvider.setSubmissions([]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Submissions'), findsOneWidget);
    });

    testWidgets('displays empty submissions message', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment());
      mockProvider.setSubmissions([]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Belum ada submission'), findsOneWidget);
    });

    testWidgets('displays submissions list with students', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment());
      mockProvider.setSubmissions([
        createTestSubmission(studentName: 'John Doe', status: 'submitted'),
        createTestSubmission(id: 'sub-2', studentId: 'student-2', studentName: 'Jane Smith', status: 'graded', score: 85),
      ]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
    });

    testWidgets('displays graded and pending counts', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment());
      mockProvider.setSubmissions([
        createTestSubmission(status: 'graded', score: 85),
        createTestSubmission(id: 'sub-2', studentId: 'student-2', status: 'submitted'),
      ]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Dinilai: 1'), findsOneWidget);
      expect(find.text('Menunggu: 1'), findsOneWidget);
    });

    testWidgets('shows delete confirmation dialog', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment());
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      
      expect(find.text('Hapus Tugas'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);
    });

    testWidgets('displays AppBar title', (tester) async {
      mockProvider.setCurrentAssignment(createTestAssignment());
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Detail Tugas'), findsOneWidget);
    });
  });
}
