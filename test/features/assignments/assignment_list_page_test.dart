// test/features/assignments/assignment_list_page_test.dart
// Unit tests for AssignmentListPage
// **Validates: Requirements 6.1-6.6**

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:gabara_mobile/features/assignments/data/models/assignment_model.dart';
import 'package:gabara_mobile/features/assignments/data/models/submission_model.dart';
import 'package:gabara_mobile/features/assignments/presentation/pages/assignment_list_page.dart';
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

  void setAssignments(List<AssignmentModel> assignments) {
    _assignments = assignments;
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
  Future<void> loadAssignments() async { notifyListeners(); }
  @override
  Future<void> loadAssignmentsByClass(String classId) async {}
  @override
  Future<void> loadAssignmentDetail(String assignmentId) async {}
  @override
  Future<AssignmentModel?> createAssignment(AssignmentModel assignment) async => assignment;
  @override
  Future<AssignmentModel?> updateAssignment(AssignmentModel assignment) async => assignment;
  @override
  Future<bool> deleteAssignment(String assignmentId) async {
    _assignments.removeWhere((a) => a.id == assignmentId);
    notifyListeners();
    return true;
  }
  @override
  Future<bool> gradeSubmission({required String submissionId, required double score, required String feedback}) async => true;
  @override
  Future<void> loadSubmissionDetail(String submissionId) async {}
  @override
  Future<void> loadMyClasses() async {}
  @override
  int get gradedCount => 0;
  @override
  int get pendingCount => 0;
  @override
  void clearCurrentAssignment() {}
  @override
  void clearError() { _errorMessage = null; notifyListeners(); }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}


// Test helper to create AssignmentModel
AssignmentModel createTestAssignment({
  required String id,
  required String title,
  DateTime? deadline,
  int maxScore = 100,
  bool isActive = true,
}) {
  return AssignmentModel(
    id: id,
    classId: 'class-1',
    title: title,
    description: 'Test description',
    deadline: deadline ?? DateTime.now().add(const Duration(days: 7)),
    maxScore: maxScore,
    isActive: isActive,
    createdBy: 'mentor-1',
  );
}

Widget createTestWidget({required MockAssignmentProvider mockProvider}) {
  return MaterialApp(
    home: ChangeNotifierProvider<AssignmentProvider>.value(
      value: mockProvider,
      child: const AssignmentListPage(),
    ),
  );
}

void main() {
  group('AssignmentListPage', () {
    late MockAssignmentProvider mockProvider;

    setUp(() {
      mockProvider = MockAssignmentProvider();
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
      expect(find.text('Tap tombol + untuk membuat tugas baru'), findsOneWidget);
      expect(find.byIcon(Icons.assignment), findsOneWidget);
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

    testWidgets('displays FAB to create new assignment', (tester) async {
      mockProvider.setAssignments([]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Buat Tugas'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('displays error state when loading fails', (tester) async {
      mockProvider.setError('Network error');
      mockProvider.setAssignments([]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.textContaining('Error'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('refresh button triggers reload', (tester) async {
      mockProvider.setAssignments([
        createTestAssignment(id: '1', title: 'Assignment 1'),
      ]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);
      
      await tester.tap(refreshButton);
      await tester.pumpAndSettle();
      
      expect(find.text('Assignment 1'), findsOneWidget);
    });

    testWidgets('shows delete confirmation dialog', (tester) async {
      mockProvider.setAssignments([
        createTestAssignment(id: '1', title: 'Assignment to Delete'),
      ]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      final deleteButton = find.byIcon(Icons.delete);
      expect(deleteButton, findsOneWidget);
      
      await tester.tap(deleteButton.first);
      await tester.pumpAndSettle();
      
      expect(find.text('Hapus Tugas'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);
    });

    testWidgets('cancel button closes delete dialog', (tester) async {
      mockProvider.setAssignments([
        createTestAssignment(id: '1', title: 'Assignment to Delete'),
      ]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      
      expect(find.text('Assignment to Delete'), findsOneWidget);
    });

    testWidgets('displays active status badge for future deadline', (tester) async {
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

    testWidgets('displays closed status badge for past deadline', (tester) async {
      mockProvider.setAssignments([
        createTestAssignment(
          id: '1',
          title: 'Expired Assignment',
          deadline: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Tertutup'), findsOneWidget);
    });

    testWidgets('displays max score info', (tester) async {
      mockProvider.setAssignments([
        createTestAssignment(id: '1', title: 'Assignment', maxScore: 100),
      ]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Max: 100'), findsOneWidget);
    });

    testWidgets('AppBar displays correct title', (tester) async {
      mockProvider.setAssignments([]);
      
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Tugas'), findsOneWidget);
    });
  });
}
