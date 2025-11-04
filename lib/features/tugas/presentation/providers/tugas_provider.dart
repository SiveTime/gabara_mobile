import 'package:flutter/material.dart';
import '../../data/models/tugas_model.dart';
import '../../data/services/tugas_service.dart';

class TugasProvider extends ChangeNotifier {
  final TugasService _service = TugasService();

  List<TugasModel> _tugasList = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _submissions = [];

  List<TugasModel> get tugasList => _tugasList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get submissions => _submissions;

  Future<void> fetchTugas({bool isTutor = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tugasList = isTutor
          ? await _service.getTutorTugasList()
          : await _service.getStudentTugasList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTugas(String id) async {
    try {
      await _service.deleteTugas(id);
      _tugasList.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchSubmissions(String tugasId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _submissions = await _service.getSubmissions(tugasId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  TugasModel? getTugasById(String id) {
    try {
      return _tugasList.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
