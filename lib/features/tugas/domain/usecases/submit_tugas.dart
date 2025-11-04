import '../repositories/tugas_repository.dart';

class SubmitTugas {
  final TugasRepository repository;
  SubmitTugas(this.repository);

  Future<void> call(String tugasId, String filePath) async {
    await repository.submitTugas(tugasId, filePath);
  }
}
