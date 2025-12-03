// lib/features/assignments/presentation/providers/assignment_provider.dart
// Requirements: 5.1-5.8, 6.1-6.6, 7.1-7.5, 8.1-8.4, 9.1-9.5

import 'package:flutter/material.dart';
import '../../data/models/assignment_model.dart';
import '../../data/models/submission_model.dart';
import '../../data/services/assignment_service.dart';

class AssignmentProvider extends ChangeNotifier {
  final AssignmentService assignmentService;

  AssignmentProvider(this.assignmentService);

  // State variables
  List<AssignmentModel> _assignments = [];
  AssignmentModel? _currentAssignment;
  List<SubmissionModel> _submissions = [];
  SubmissionModel? _currentSubmission;
  List<Map<String, dynamic>> _myClasses = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasSubmissions = false;

  // Getters
  List<AssignmentModel> get assignments => _assignments;
  AssignmentModel? get currentAssignment => _currentAssignment;
  List<SubmissionModel> get submissions => _submissions;
  SubmissionModel? get currentSubmission => _currentSubmission;
  List<Map<String, dynamic>> get myClasses => _myClasses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasSubmissions => _hasSubmissions;

  /// Load assignments created by current mentor
  /// **Validates: Requirements 6.1-6.6**
  Future<void> loadAssignments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _assignments = await assignmentService.fetchAssignmentsByMentor();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// Load assignments for a specific class (student view)
  Future<void> loadAssignmentsByClass(String classId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _assignments = await assignmentService.fetchAssignmentsByClass(classId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load assignments for a specific meeting
  Future<void> loadAssignmentsByMeeting(String meetingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _assignments = await assignmentService.fetchAssignmentsByMeeting(meetingId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get assignment count for a meeting
  Future<int> getAssignmentCountByMeeting(String meetingId) async {
    try {
      return await assignmentService.countAssignmentsByMeeting(meetingId);
    } catch (e) {
      debugPrint('Error getting assignment count: $e');
      return 0;
    }
  }

  /// Load a single assignment with submissions
  Future<void> loadAssignmentDetail(String assignmentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentAssignment = await assignmentService.fetchAssignmentById(assignmentId);
      if (_currentAssignment != null) {
        _submissions = await assignmentService.fetchSubmissions(assignmentId);
        _hasSubmissions = await assignmentService.hasSubmissions(assignmentId);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new assignment
  /// **Validates: Requirements 5.1-5.8**
  Future<AssignmentModel?> createAssignment(AssignmentModel assignment) async {
    if (_isLoading) return null;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await assignmentService.createAssignment(assignment);
      if (created != null) {
        _assignments.insert(0, created);
        _currentAssignment = created;
      }
      return created;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an assignment
  /// **Validates: Requirements 7.1-7.5**
  Future<AssignmentModel?> updateAssignment(AssignmentModel assignment) async {
    if (_isLoading) return null;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await assignmentService.updateAssignment(assignment);
      if (updated != null) {
        final index = _assignments.indexWhere((a) => a.id == updated.id);
        if (index != -1) {
          _assignments[index] = updated;
        }
        _currentAssignment = updated;
      }
      return updated;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete an assignment
  /// **Validates: Requirements 8.1-8.4**
  Future<bool> deleteAssignment(String assignmentId) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await assignmentService.deleteAssignment(assignmentId);
      _assignments.removeWhere((a) => a.id == assignmentId);
      if (_currentAssignment?.id == assignmentId) {
        _currentAssignment = null;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Grade a submission
  /// **Validates: Requirements 9.1-9.5**
  Future<bool> gradeSubmission({
    required String submissionId,
    required double score,
    required String feedback,
  }) async {
    try {
      final graded = await assignmentService.gradeSubmission(
        submissionId: submissionId,
        score: score,
        feedback: feedback,
      );

      if (graded != null) {
        final index = _submissions.indexWhere((s) => s.id == submissionId);
        if (index != -1) {
          _submissions[index] = graded;
        }
        _currentSubmission = graded;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Load submission detail
  Future<void> loadSubmissionDetail(String submissionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentSubmission = await assignmentService.fetchSubmissionById(submissionId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load classes for dropdown
  Future<void> loadMyClasses() async {
    try {
      _myClasses = await assignmentService.getMyClasses();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Get graded submissions count
  int get gradedCount => _submissions.where((s) => s.status == 'graded').length;

  /// Get pending submissions count
  int get pendingCount => _submissions.where((s) => s.status != 'graded' && s.status != 'draft').length;

  /// Clear current assignment
  void clearCurrentAssignment() {
    _currentAssignment = null;
    _submissions = [];
    _currentSubmission = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
