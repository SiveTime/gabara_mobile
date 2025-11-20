import 'package:flutter/material.dart';
import '../../data/models/class_model.dart';
import '../../data/services/class_service.dart';

class ClassProvider extends ChangeNotifier {
  final ClassService classService;

  ClassProvider(this.classService);

  List<ClassModel> _classes = [];
  List<Map<String, dynamic>> _subjects = []; // Data untuk dropdown mapel
  bool _isLoading = false;
  String? _errorMessage;

  List<ClassModel> get classes => _classes;
  List<Map<String, dynamic>> get subjects => _subjects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 1. AMBIL DATA KELAS
  Future<void> fetchClasses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _classes = await classService.getClasses();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. AMBIL DATA SUBJECTS (Dipanggil saat mau bikin kelas)
  Future<void> fetchSubjects() async {
    try {
      _subjects = await classService.getSubjects();
      notifyListeners();
    } catch (e) {
      // Error silent saja untuk dropdown, atau bisa di log
      debugPrint("Gagal ambil subjects: $e");
    }
  }

  // 3. BUAT KELAS BARU
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
      
      // Refresh data kelas setelah berhasil membuat
      await fetchClasses(); 
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false; // Stop loading biar user bisa coba lagi
      notifyListeners();
      return false;
    }
  }
}