// test/features/assignments/create_assignment_page_test.dart
// Unit tests for CreateAssignmentPage
// **Validates: Requirements 5.1-5.8, 7.1-7.5**

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:gabara_mobile/features/assignments/data/models/assignment_model.dart';
import 'package:gabara_mobile/features/assignments/data/models/submission_model.dart';
import 'package:gabara_mobile/features/assignments/presentation/pages/create_assignment_page.dart';
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

  void setClasses(List<Map<String, dynamic>> classes) {
    _myClasses = classes;
    notifyListeners();
  }

  void setCurrentAssignment(AssignmentModel? assignment) {
    _currentAssignment = assignment;
    notifyListeners();
  }

  void setHasSubmissions(bool value) {
    _hasSubmissions = value;
    notifyListeners();
  }

  @override
  Future<void> loadMyClasses() async { notifyListeners(); }
  @override
  Future<void> loadAssignmentDetail(String assignmentId) async { notifyListeners(); }
  @override
  Future<AssignmentModel?> createAssignment(AssignmentModel assignment) async => assignment;
  @override
  Future<AssignmentModel?> updateAssignment(AssignmentModel assignment) async => assignment;
  @override
  Future<void> loadAssignments() async {}
  @override
  Future<void> loadAssignmentsByClass(String classId) async {}
  @override
  Future<bool> deleteAssignment(String assignmentId) async => true;
  @override
  Future<bool> gradeSubmission({required String submissionId, required double score, required String feedback}) async => true;
  @override
  Future<void> loadSubmissionDetail(String submissionId) async {}
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

Widget createTestWidget({
  required MockAssignmentProvider mockProvider,
  String? assignmentId,
}) {
  return MaterialApp(
    home: ChangeNotifierProvider<AssignmentProvider>.value(
      value: mockProvider,
      child: CreateAssignmentPage(assignmentId: assignmentId),
    ),
  );
}

void main() {
  group('CreateAssignmentPage', () {
    late MockAssignmentProvider mockProvider;

    setUp(() {
      mockProvider = MockAssignmentProvider();
      mockProvider.setClasses([
        {'id': 'class-1', 'name': 'Kelas A'},
        {'id': 'class-2', 'name': 'Kelas B'},
      ]);
    });

    testWidgets('displays correct AppBar title for create mode', (tester) async {
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      expect(find.text('Buat Tugas'), findsOneWidget);
    });

    testWidgets('displays correct AppBar title for edit mode', (tester) async {
      mockProvider.setCurrentAssignment(AssignmentModel(
        id: 'assignment-1',
        classId: 'class-1',
        title: 'Test Assignment',
        deadline: DateTime.now().add(const Duration(days: 7)),
        createdBy: 'mentor-1',
      ));

      await tester.pumpWidget(createTestWidget(
        mockProvider: mockProvider,
        assignmentId: 'assignment-1',
      ));
      await tester.pumpAndSettle();
      expect(find.text('Edit Tugas'), findsOneWidget);
    });

    testWidgets('displays title input field', (tester) async {
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      expect(find.text('Judul Tugas *'), findsOneWidget);
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

    testWidgets('displays deadline picker', (tester) async {
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      expect(find.text('Deadline *'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('displays max score input field', (tester) async {
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      expect(find.text('Nilai Maksimal *'), findsOneWidget);
    });

    testWidgets('can enter title text', (tester) async {
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      final titleField = find.byType(TextFormField).first;
      await tester.enterText(titleField, 'My Test Assignment');
      await tester.pumpAndSettle();
      
      expect(find.text('My Test Assignment'), findsOneWidget);
    });

    testWidgets('can select class from dropdown', (tester) async {
      await tester.pumpWidget(createTestWidget(mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      
      expect(find.text('Kelas A'), findsWidgets);
      expect(find.text('Kelas B'), findsWidgets);
      
      await tester.tap(find.text('Kelas A').last);
      await tester.pumpAndSettle();
    });

    testWidgets('displays warning when editing with submissions', (tester) async {
      mockProvider.setCurrentAssignment(AssignmentModel(
        id: 'assignment-1',
        classId: 'class-1',
        title: 'Test Assignment',
        deadline: DateTime.now().add(const Duration(days: 7)),
        createdBy: 'mentor-1',
      ));
      mockProvider.setHasSubmissions(true);

      await tester.pumpWidget(createTestWidget(
        mockProvider: mockProvider,
        assignmentId: 'assignment-1',
      ));
      await tester.pumpAndSettle();
      
      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.textContaining('sudah memiliki submission'), findsOneWidget);
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
