// test/features/assignments/submission_detail_page_test.dart
// Unit tests for SubmissionDetailPage
// **Validates: Requirements 9.1-9.5**

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:gabara_mobile/features/assignments/data/models/assignment_model.dart';
import 'package:gabara_mobile/features/assignments/data/models/submission_model.dart';
import 'package:gabara_mobile/features/assignments/presentation/pages/submission_detail_page.dart';
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
  int get gradedCount => 0;
  @override
  int get pendingCount => 0;

  void setCurrentSubmission(SubmissionModel? submission) {
    _currentSubmission = submission;
    notifyListeners();
  }

  void setCurrentAssignment(AssignmentModel? assignment) {
    _currentAssignment = assignment;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  Future<void> loadSubmissionDetail(String submissionId) async { notifyListeners(); }
  @override
  Future<bool> gradeSubmission({required String submissionId, required double score, required String feedback}) async => true;
  @override
  Future<void> loadAssignments() async {}
  @override
  Future<void> loadAssignmentsByClass(String classId) async {}
  @override
  Future<void> loadAssignmentDetail(String assignmentId) async {}
  @override
  Future<AssignmentModel?> createAssignment(AssignmentModel assignment) async => assignment;
  @override
  Future<AssignmentModel?> updateAssignment(AssignmentModel assignment) async => assignment;
  @override
  Future<bool> deleteAssignment(String assignmentId) async => true;
  @override
  Future<void> loadMyClasses() async {}
  @override
  void clearCurrentAssignment() {}
  @override
  void clearError() { _errorMessage = null; notifyListeners(); }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

SubmissionModel createTestSubmission({
  String id = 'sub-1',
  String studentName = 'John Doe',
  String status = 'submitted',
  String content = 'Test answer content',
  double? score,
  String? feedback,
  DateTime? gradedAt,
}) {
  return SubmissionModel(
    id: id,
    assignmentId: 'assignment-1',
    studentId: 'student-1',
    content: content,
    status: status,
    submittedAt: DateTime.now(),
    score: score,
    feedback: feedback,
    gradedAt: gradedAt,
    studentName: studentName,
  );
}

Widget createTestWidget({
  required MockAssignmentProvider mockProvider,
  String submissionId = 'sub-1',
}) {
  return MaterialApp(
    home: ChangeNotifierProvider<AssignmentProvider>.value(
      value: mockProvider,
      child: SubmissionDetailPage(submissionId: submissionId),
    ),
  );
}

void main() {
  group('SubmissionDetailPage', () {
    late MockAssignmentProvider mockProvider;

    setUp(() {
      mockProvider = MockAssignmentProvider();
      mockProvider.setCurrentAssignment(AssignmentModel(
        id: 'assignment-1',
        classId: 'class-1',
        title: 'Test Assignment',
        deadline: DateTime.now().add(const Duration(days: 7)),
        maxScore: 100,
        createdBy: 'mentor-1',
      ));
    });

    testWidgets('displays loading indicator when loading', (tester) async {
      mockProvider.setLoading(true);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pump();
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays not found message when submission is null', (tester) async {
      mockProvider.setCurrentSubmission(null);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Submission tidak ditemukan'), findsOneWidget);
    });

    testWidgets('displays student name', (tester) async {
      mockProvider.setCurrentSubmission(createTestSubmission(studentName: 'John Doe'));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('displays submission content', (tester) async {
      mockProvider.setCurrentSubmission(createTestSubmission(content: 'My answer'));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('My answer'), findsOneWidget);
    });

    testWidgets('displays submitted status badge', (tester) async {
      mockProvider.setCurrentSubmission(createTestSubmission(status: 'submitted'));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Menunggu'), findsOneWidget);
    });

    testWidgets('displays graded status badge', (tester) async {
      mockProvider.setCurrentSubmission(createTestSubmission(status: 'graded', score: 85));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Dinilai'), findsOneWidget);
    });

    testWidgets('displays late status badge', (tester) async {
      mockProvider.setCurrentSubmission(createTestSubmission(status: 'late'));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Terlambat'), findsOneWidget);
    });

    testWidgets('displays grading form', (tester) async {
      mockProvider.setCurrentSubmission(createTestSubmission());
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Penilaian'), findsOneWidget);
      expect(find.text('Nilai *'), findsOneWidget);
      expect(find.text('Feedback'), findsOneWidget);
    });

    testWidgets('displays save button for ungraded submission', (tester) async {
      mockProvider.setCurrentSubmission(createTestSubmission(status: 'submitted'));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Simpan Nilai'), findsOneWidget);
    });

    testWidgets('displays update button for graded submission', (tester) async {
      mockProvider.setCurrentSubmission(createTestSubmission(
        status: 'graded',
        score: 85,
        feedback: 'Good job',
        gradedAt: DateTime.now(),
      ));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Update Nilai'), findsOneWidget);
    });

    testWidgets('pre-fills score for graded submission', (tester) async {
      mockProvider.setCurrentSubmission(createTestSubmission(
        status: 'graded',
        score: 85,
      ));
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('85'), findsOneWidget);
    });

    testWidgets('displays Jawaban section', (tester) async {
      mockProvider.setCurrentSubmission(createTestSubmission());
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Jawaban'), findsOneWidget);
    });

    testWidgets('displays AppBar title', (tester) async {
      mockProvider.setCurrentSubmission(createTestSubmission());
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Detail Submission'), findsOneWidget);
    });
  });
}
