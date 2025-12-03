// lib/features/assignments/data/services/assignment_service.dart
// Requirements: 5.1-5.8, 9.1-9.5, 12.1-12.6, 13.1-13.5

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/assignment_model.dart';
import '../models/submission_model.dart';
import '../../../grades/data/services/grades_service.dart';

class AssignmentService {
  final SupabaseClient supabaseClient;

  AssignmentService(this.supabaseClient);

  /// Create a new assignment
  /// **Validates: Requirements 5.1-5.8**
  Future<AssignmentModel?> createAssignment(AssignmentModel assignment) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User tidak login');

      final response = await supabaseClient
          .from('assignments')
          .insert(assignment.toCreateJson())
          .select()
          .single();

      return AssignmentModel.fromJson(response);
    } catch (e) {
      debugPrint('Error createAssignment: $e');
      rethrow;
    }
  }

  /// Fetch all assignments created by the current mentor
  /// **Validates: Requirements 6.1-6.6**
  Future<List<AssignmentModel>> fetchAssignmentsByMentor() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return [];

      final response = await supabaseClient
          .from('assignments')
          .select()
          .eq('created_by', user.id)
          .order('deadline', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => AssignmentModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetchAssignmentsByMentor: $e');
      return [];
    }
  }

  /// Fetch assignments for a specific class
  Future<List<AssignmentModel>> fetchAssignmentsByClass(String classId) async {
    try {
      final response = await supabaseClient
          .from('assignments')
          .select()
          .eq('class_id', classId)
          .order('deadline', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => AssignmentModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetchAssignmentsByClass: $e');
      return [];
    }
  }

  /// Fetch assignments for a specific meeting
  Future<List<AssignmentModel>> fetchAssignmentsByMeeting(String meetingId) async {
    try {
      final response = await supabaseClient
          .from('assignments')
          .select()
          .eq('meeting_id', meetingId)
          .order('deadline', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => AssignmentModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetchAssignmentsByMeeting: $e');
      return [];
    }
  }

  /// Count assignments for a specific meeting
  Future<int> countAssignmentsByMeeting(String meetingId) async {
    try {
      final response = await supabaseClient
          .from('assignments')
          .select('id')
          .eq('meeting_id', meetingId);

      return (response as List).length;
    } catch (e) {
      debugPrint('Error countAssignmentsByMeeting: $e');
      return 0;
    }
  }

  /// Fetch a single assignment by ID
  Future<AssignmentModel?> fetchAssignmentById(String assignmentId) async {
    try {
      final response = await supabaseClient
          .from('assignments')
          .select()
          .eq('id', assignmentId)
          .maybeSingle();

      if (response == null) return null;
      return AssignmentModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetchAssignmentById: $e');
      return null;
    }
  }

  /// Update an assignment
  /// **Validates: Requirements 7.1-7.5**
  Future<AssignmentModel?> updateAssignment(AssignmentModel assignment) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User tidak login');

      await supabaseClient
          .from('assignments')
          .update(assignment.toUpdateJson())
          .eq('id', assignment.id)
          .eq('created_by', user.id);

      return await fetchAssignmentById(assignment.id);
    } catch (e) {
      debugPrint('Error updateAssignment: $e');
      rethrow;
    }
  }

  /// Delete an assignment
  /// **Validates: Requirements 8.1-8.4**
  Future<void> deleteAssignment(String assignmentId) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User tidak login');

      // Verify ownership
      final existingAssignment = await supabaseClient
          .from('assignments')
          .select('id, created_by, title')
          .eq('id', assignmentId)
          .maybeSingle();

      if (existingAssignment == null) {
        throw Exception('Assignment tidak ditemukan');
      }

      if (existingAssignment['created_by'] != user.id) {
        throw Exception('Anda bukan pembuat assignment ini');
      }

      // Delete assignment (cascade will delete submissions)
      await supabaseClient.from('assignments').delete().eq('id', assignmentId);

      debugPrint(
        'Assignment "${existingAssignment['title']}" deleted successfully',
      );
    } catch (e) {
      debugPrint('Error deleteAssignment: $e');
      rethrow;
    }
  }

  /// Submit an assignment (student)
  /// **Validates: Requirements 12.1-12.6**
  Future<SubmissionModel?> submitAssignment(SubmissionModel submission) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User tidak login');

      // Get assignment to check deadline
      final assignment = await fetchAssignmentById(submission.assignmentId);
      if (assignment == null) throw Exception('Assignment tidak ditemukan');

      // Determine if submission is late
      final now = DateTime.now();
      final isLate = now.isAfter(assignment.deadline);
      final status = isLate ? 'late' : 'submitted';

      // Check if submission already exists (using assignment_submissions table)
      final existing = await supabaseClient
          .from('assignment_submissions')
          .select()
          .eq('assignment_id', submission.assignmentId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existing != null) {
        // Check if submission is already graded
        final existingStatus = existing['status'] as String?;
        if (existingStatus == 'graded') {
          throw Exception('Pengajuan sudah dinilai dan tidak dapat diubah');
        }

        // Update existing submission
        await supabaseClient
            .from('assignment_submissions')
            .update({
              'content': submission.content,
              'attachment_url': submission.attachmentUrl,
              'status': status,
              'submitted_at': now.toUtc().toIso8601String(),
            })
            .eq('id', existing['id']);

        // Fetch updated submission
        final updated = await supabaseClient
            .from('assignment_submissions')
            .select()
            .eq('id', existing['id'])
            .maybeSingle();

        if (updated != null) {
          return SubmissionModel.fromJsonV2(updated);
        }
        return null;
      } else {
        // Create new submission
        final response = await supabaseClient
            .from('assignment_submissions')
            .insert({
              'assignment_id': submission.assignmentId,
              'user_id': user.id,
              'content': submission.content,
              'attachment_url': submission.attachmentUrl,
              'status': status,
              'submitted_at': now.toUtc().toIso8601String(),
            })
            .select()
            .single();

        return SubmissionModel.fromJsonV2(response);
      }
    } catch (e) {
      debugPrint('Error submitAssignment: $e');
      rethrow;
    }
  }

  /// Fetch all submissions for an assignment (mentor)
  /// Uses RPC function to bypass RLS restrictions
  Future<List<SubmissionModel>> fetchSubmissions(String assignmentId) async {
    try {
      // Try RPC function first (bypasses RLS)
      final rpcResponse = await supabaseClient
          .rpc('get_assignment_submissions', params: {'p_assignment_id': assignmentId});
      
      if (rpcResponse != null && rpcResponse is List && rpcResponse.isNotEmpty) {
        return rpcResponse.map((json) => SubmissionModel.fromRpcJson(json)).toList();
      }
      
      // Fallback to direct query if RPC not available
      final response = await supabaseClient
          .from('assignment_submissions')
          .select('''
            id, assignment_id, user_id, content, attachment_url,
            status, submitted_at, score, feedback, graded_at, graded_by,
            profiles:user_id(full_name)
          ''')
          .eq('assignment_id', assignmentId)
          .order('submitted_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => SubmissionModel.fromJsonV2(json)).toList();
    } catch (e) {
      debugPrint('Error fetchSubmissions: $e');
      return [];
    }
  }

  /// Fetch a single submission by ID
  Future<SubmissionModel?> fetchSubmissionById(String submissionId) async {
    try {
      final response = await supabaseClient
          .from('assignment_submissions')
          .select('''
            id, assignment_id, user_id, content, attachment_url,
            status, submitted_at, score, feedback, graded_at, graded_by,
            profiles:user_id(full_name)
          ''')
          .eq('id', submissionId)
          .maybeSingle();

      if (response == null) return null;
      return SubmissionModel.fromJsonV2(response);
    } catch (e) {
      debugPrint('Error fetchSubmissionById: $e');
      return null;
    }
  }

  /// Fetch student's submission for an assignment
  Future<SubmissionModel?> fetchStudentSubmission(String assignmentId) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return null;

      final response = await supabaseClient
          .from('assignment_submissions')
          .select()
          .eq('assignment_id', assignmentId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) return null;
      return SubmissionModel.fromJsonV2(response);
    } catch (e) {
      debugPrint('Error fetchStudentSubmission: $e');
      return null;
    }
  }

  /// Grade a submission (mentor)
  /// **Validates: Requirements 9.1-9.5, 13.1-13.5**
  Future<SubmissionModel?> gradeSubmission({
    required String submissionId,
    required double score,
    required String feedback,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User tidak login');

      // Get submission details first to get user_id and assignment_id
      final existingSubmission = await supabaseClient
          .from('assignment_submissions')
          .select('user_id, assignment_id')
          .eq('id', submissionId)
          .single();

      final response = await supabaseClient
          .from('assignment_submissions')
          .update({
            'score': score,
            'feedback': feedback,
            'status': 'graded',
            'graded_at': DateTime.now().toUtc().toIso8601String(),
            'graded_by': user.id,
          })
          .eq('id', submissionId)
          .select()
          .single();

      // Sync grade to grades table
      // **Validates: Requirements 13.1-13.5**
      try {
        final studentId = existingSubmission['user_id'] as String;
        final assignmentId = existingSubmission['assignment_id'] as String;
        
        // Get assignment details for class_id and max_score
        final assignment = await fetchAssignmentById(assignmentId);
        if (assignment != null) {
          final gradesService = GradesService(supabaseClient);
          await gradesService.syncGradeFromAssignment(
            studentId: studentId,
            classId: assignment.classId,
            assignmentId: assignmentId,
            score: score,
            maxScore: assignment.maxScore.toDouble(),
            assignmentTitle: assignment.title,
          );
          debugPrint('Grade synced for assignment: ${assignment.title}');
        }
      } catch (gradeError) {
        // Log error but don't fail the grading
        debugPrint('Error syncing grade: $gradeError');
      }

      return SubmissionModel.fromJsonV2(response);
    } catch (e) {
      debugPrint('Error gradeSubmission: $e');
      rethrow;
    }
  }

  /// Delete a submission (student)
  /// Only allowed if submission is not graded yet
  Future<bool> deleteSubmission(String submissionId) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User tidak login');

      // Check if submission exists and belongs to user
      final existing = await supabaseClient
          .from('assignment_submissions')
          .select('id, user_id, status')
          .eq('id', submissionId)
          .maybeSingle();

      if (existing == null) {
        throw Exception('Pengajuan tidak ditemukan');
      }

      if (existing['user_id'] != user.id) {
        throw Exception('Anda tidak memiliki akses untuk menghapus pengajuan ini');
      }

      if (existing['status'] == 'graded') {
        throw Exception('Pengajuan yang sudah dinilai tidak dapat dihapus');
      }

      // Delete submission
      await supabaseClient
          .from('assignment_submissions')
          .delete()
          .eq('id', submissionId)
          .eq('user_id', user.id);

      return true;
    } catch (e) {
      debugPrint('Error deleteSubmission: $e');
      rethrow;
    }
  }

  /// Get submission count for an assignment
  Future<int> getSubmissionCount(String assignmentId) async {
    try {
      final response = await supabaseClient
          .from('assignment_submissions')
          .select('id')
          .eq('assignment_id', assignmentId)
          .neq('status', 'draft');

      return (response as List).length;
    } catch (e) {
      debugPrint('Error getSubmissionCount: $e');
      return 0;
    }
  }

  /// Check if assignment has submissions (for edit validation)
  Future<bool> hasSubmissions(String assignmentId) async {
    final count = await getSubmissionCount(assignmentId);
    return count > 0;
  }

  /// Get classes owned by current mentor (for dropdown)
  Future<List<Map<String, dynamic>>> getMyClasses() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return [];

      final response = await supabaseClient
          .from('classes')
          .select('id, name')
          .eq('tutor_id', user.id)
          .eq('is_active', true)
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getMyClasses: $e');
      return [];
    }
  }
}
