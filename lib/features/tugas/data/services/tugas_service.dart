import '../models/tugas_model.dart';

class TugasService {
  Future<List<TugasModel>> fetchTugasList(String kelasId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      TugasModel(
        id: '1',
        title: 'Tugas Flutter Layout',
        description: 'Buat tampilan halaman login menggunakan Flutter.',
        deadline: DateTime(2025, 11, 5),
        kelas: kelasId,
        isSubmitted: false,
      ),
      TugasModel(
        id: '2',
        title: 'Tugas State Management',
        description: 'Implementasikan Provider untuk manajemen state.',
        deadline: DateTime(2025, 11, 10),
        kelas: kelasId,
        isSubmitted: true,
      ),
    ];
  }

  Future<void> uploadTugas(String tugasId, String filePath) async {
    await Future.delayed(const Duration(seconds: 1));
    // logging only; in real app upload to backend
    // ignore: avoid_print
    print('Tugas $tugasId berhasil dikirim dengan file: $filePath');
  }

  // Convenience wrappers expected by provider
  Future<List<TugasModel>> getTutorTugasList() async => fetchTugasList('tutor');
  Future<List<TugasModel>> getStudentTugasList() async => fetchTugasList('student');

  Future<void> deleteTugas(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // pretend deletion succeeded
  }

  Future<List<Map<String, dynamic>>> getSubmissions(String tugasId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {'id': 's1', 'studentName': 'Ani', 'submittedAt': '2025-10-10 10:00'},
      {'id': 's2', 'studentName': 'Budi', 'submittedAt': '2025-10-11 12:30'},
    ];
  }
}
