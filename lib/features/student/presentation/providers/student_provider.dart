// lib/features/student/presentation/providers/student_provider.dart
// Requirements: 10.1-10.5, 11.1-11.8, 12.1-12.6

import 'package:flutter/material.dart';
import '../../../meetings/data/models/meeting_model.dart';
import '../../../meetings/data/services/meeting_service.dart';
import '../../../assignments/data/models/assignment_model.dart';
import '../../../assignments/data/models/submission_model.dart';
import '../../../assignments/data/services/assignment_service.dart';

class StudentProvider extends ChangeNotifier {
  final MeetingService meetingService;
  final AssignmentService assignmentService;

  StudentProvider(this.meetingService, this.assignmentService);

  // State variables
  List<MeetingModel> _meetings = [];
  MeetingModel? _currentMeeting;
  List<AssignmentModel> _assignments = [];
  AssignmentModel? _currentAssignment;
  SubmissionModel? _mySubmission;
  List<Map<String, dynamic>> _myClasses = [];
  String? _selectedClassId;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<MeetingModel> get meetings => _meetings;
  MeetingModel? get currentMeeting => _currentMeeting;
  List<AssignmentModel> get assignments => _assignments;
  AssignmentModel? get currentAssignment => _currentAssignment;
  SubmissionModel? get mySubmission => _mySubmission;
  List<Map<String, dynamic>> get myClasses => _myClasses;
  String? get selectedClassId => _selectedClassId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load meetings for student's enrolled class
  /// **Validates: Requirements 10.1-10.5**
  Future<void> loadMeetings(String classId) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedClassId = classId;
    notifyListeners();

    try {
      _meetings = await meetingService.fetchMeetingsByClass(classId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load meeting detail
  Future<void> loadMeetingDetail(String meetingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentMeeting = await meetingService.fetchMeetingById(meetingId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load assignments for student's enrolled class
  /// **Validates: Requirements 11.1-11.8**
  Future<void> loadAssignments(String classId) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedClassId = classId;
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

  /// Load assignment detail with student's submission
  Future<void> loadAssignmentDetail(String assignmentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentAssignment = await assignmentService.fetchAssignmentById(assignmentId);
      _mySubmission = await assignmentService.fetchStudentSubmission(assignmentId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submit assignment
  /// **Validates: Requirements 12.1-12.6**
  Future<bool> submitAssignment(SubmissionModel submission) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _mySubmission = await assignmentService.submitAssignment(submission);
      return _mySubmission != null;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get upcoming meetings
  List<MeetingModel> get upcomingMeetings {
    final now = DateTime.now();
    return _meetings.where((m) => m.meetingDate.isAfter(now) && m.status == 'scheduled').toList();
  }

  /// Get active assignments (not past deadline)
  List<AssignmentModel> get activeAssignments {
    final now = DateTime.now();
    return _assignments.where((a) => a.deadline.isAfter(now) && a.isActive).toList();
  }

  /// Clear current data
  void clearCurrentData() {
    _currentMeeting = null;
    _currentAssignment = null;
    _mySubmission = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
