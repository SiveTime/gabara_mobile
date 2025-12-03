// lib/features/meetings/presentation/providers/meeting_provider.dart
// Requirements: 1.1-1.8, 2.1-2.9, 3.1-3.4, 4.1-4.5, 15.1-15.5

import 'package:flutter/material.dart';
import '../../data/models/meeting_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/services/meeting_service.dart';
import '../../domain/entities/meeting_entity.dart';

class MeetingProvider extends ChangeNotifier {
  final MeetingService meetingService;

  MeetingProvider(this.meetingService);

  // State variables
  List<MeetingModel> _meetings = [];
  MeetingModel? _currentMeeting;
  List<AttendanceModel> _attendanceList = [];
  List<Map<String, dynamic>> _myClasses = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<MeetingModel> get meetings => _meetings;
  MeetingModel? get currentMeeting => _currentMeeting;
  List<AttendanceModel> get attendanceList => _attendanceList;
  List<Map<String, dynamic>> get myClasses => _myClasses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load meetings created by current mentor
  /// **Validates: Requirements 2.1-2.9**
  Future<void> loadMeetings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _meetings = await meetingService.fetchMeetingsByMentor();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load meetings for a specific class (student view)
  Future<void> loadMeetingsByClass(String classId) async {
    _isLoading = true;
    _errorMessage = null;
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

  /// Load a single meeting with attendance
  Future<void> loadMeetingDetail(String meetingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentMeeting = await meetingService.fetchMeetingById(meetingId);
      if (_currentMeeting != null) {
        _attendanceList = await meetingService.fetchAttendance(meetingId);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new meeting
  /// **Validates: Requirements 1.1-1.8**
  Future<MeetingModel?> createMeeting(MeetingModel meeting) async {
    if (_isLoading) return null;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await meetingService.createMeeting(meeting);
      if (created != null) {
        _meetings.insert(0, created);
        _currentMeeting = created;
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

  /// Update a meeting
  /// **Validates: Requirements 3.1-3.4**
  Future<MeetingModel?> updateMeeting(MeetingModel meeting) async {
    if (_isLoading) return null;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await meetingService.updateMeeting(meeting);
      if (updated != null) {
        // Update in list
        final index = _meetings.indexWhere((m) => m.id == updated.id);
        if (index != -1) {
          _meetings[index] = updated;
        }
        _currentMeeting = updated;
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

  /// Delete a meeting
  /// **Validates: Requirements 4.1-4.5**
  Future<bool> deleteMeeting(String meetingId) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await meetingService.deleteMeeting(meetingId);
      _meetings.removeWhere((m) => m.id == meetingId);
      if (_currentMeeting?.id == meetingId) {
        _currentMeeting = null;
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

  /// Mark attendance for a student
  /// **Validates: Requirements 15.1-15.5**
  Future<bool> markAttendance({
    required String meetingId,
    required String studentId,
    required String status,
  }) async {
    try {
      final attendance = await meetingService.markAttendance(
        meetingId: meetingId,
        studentId: studentId,
        status: status,
      );

      if (attendance != null) {
        // Update in list
        final index = _attendanceList.indexWhere(
          (a) => a.studentId == studentId,
        );
        if (index != -1) {
          _attendanceList[index] = attendance;
        } else {
          _attendanceList.add(attendance);
        }
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

  /// Update meeting status
  Future<bool> updateMeetingStatus(String meetingId, String newStatus) async {
    try {
      // Validate status transition
      if (_currentMeeting != null) {
        if (!MeetingStatus.isValidTransition(
          _currentMeeting!.status,
          newStatus,
        )) {
          _errorMessage = 'Transisi status tidak valid';
          notifyListeners();
          return false;
        }
      }

      final updated = await meetingService.updateMeetingStatus(
        meetingId,
        newStatus,
      );

      if (updated != null) {
        // Update in list
        final index = _meetings.indexWhere((m) => m.id == updated.id);
        if (index != -1) {
          _meetings[index] = updated;
        }
        _currentMeeting = updated;
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

  /// Load classes for dropdown
  Future<void> loadMyClasses() async {
    try {
      _myClasses = await meetingService.getMyClasses();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Get meetings filtered by status
  List<MeetingModel> getMeetingsByStatus(String status) {
    return _meetings.where((m) => m.status == status).toList();
  }

  /// Get upcoming meetings
  List<MeetingModel> get upcomingMeetings {
    final now = DateTime.now();
    return _meetings
        .where((m) => m.meetingDate.isAfter(now) && m.status == 'scheduled')
        .toList();
  }

  /// Get past meetings
  List<MeetingModel> get pastMeetings {
    final now = DateTime.now();
    return _meetings.where((m) => m.meetingDate.isBefore(now)).toList();
  }

  /// Clear current meeting
  void clearCurrentMeeting() {
    _currentMeeting = null;
    _attendanceList = [];
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
