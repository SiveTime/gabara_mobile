import 'package:flutter/material.dart';
import '../../data/models/class_model.dart';
import '../../data/services/class_service.dart';
import '../../domain/entities/class_member_entity.dart';

class ClassProvider extends ChangeNotifier {
  final ClassService classService;

  ClassProvider(this.classService);

  List<ClassModel> _classes = [];
  List<Map<String, dynamic>> _subjects = [];
  List<ClassMemberEntity> _classMembers = [];
  bool _isLoading = false;
  bool _isMembersLoading = false;
  String? _errorMessage;

  List<ClassModel> get classes => _classes;
  List<Map<String, dynamic>> get subjects => _subjects;
  List<ClassMemberEntity> get classMembers => _classMembers;
  bool get isLoading => _isLoading;
  bool get isMembersLoading => _isMembersLoading;
  String? get errorMessage => _errorMessage;

  // Fetch enrolled classes (for student)
  Future<void> fetchClasses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _classes = await classService.getEnrolledClasses();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch classes created by mentor
  Future<void> fetchMyClasses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _classes = await classService.getMyClasses();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSubjects() async {
    try {
      _subjects = await classService.getSubjects();
      notifyListeners();
    } catch (e) {
      debugPrint("Gagal ambil subjects: $e");
    }
  }

  Future<bool> createClass({
    required String name,
    required String description,
    required int subjectId,
    required int maxStudents,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await classService.createClass(
        name: name,
        description: description,
        subjectId: subjectId,
        maxStudents: maxStudents,
      );
      // Refresh kelas mentor setelah create
      await fetchMyClasses();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update class
  Future<bool> updateClass({
    required String classId,
    required String name,
    required String description,
    required int subjectId,
    required int maxStudents,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await classService.updateClass(
        classId: classId,
        name: name,
        description: description,
        subjectId: subjectId,
        maxStudents: maxStudents,
      );
      await fetchMyClasses();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete class
  Future<bool> deleteClass(String classId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    debugPrint('ClassProvider: Deleting class $classId');

    try {
      await classService.deleteClass(classId);
      debugPrint('ClassProvider: Delete successful, refreshing list');
      await fetchMyClasses();
      debugPrint('ClassProvider: List refreshed, count: ${_classes.length}');
      return true;
    } catch (e) {
      debugPrint('ClassProvider: Delete failed - $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Join class by code (for student)
  Future<bool> joinClass(String classCode) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await classService.joinClass(classCode);
      await fetchClasses();
      return true;
    } catch (e) {
      _errorMessage = "Kode kelas tidak valid atau sudah bergabung.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch class members
  Future<void> fetchClassMembers(String classId) async {
    _isMembersLoading = true;
    notifyListeners();

    try {
      _classMembers = await classService.getClassMembers(classId);
      debugPrint('ClassProvider: Fetched ${_classMembers.length} members');
    } catch (e) {
      debugPrint('ClassProvider: Error fetching members - $e');
      _classMembers = [];
    } finally {
      _isMembersLoading = false;
      notifyListeners();
    }
  }

  // Clear members when switching classes
  void clearMembers() {
    _classMembers = [];
    notifyListeners();
  }
}
