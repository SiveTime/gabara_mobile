import '../entities/tugas_entity.dart';

abstract class TugasRepository {
  Future<List<TugasEntity>> getTugasList(String kelasId);
  Future<void> submitTugas(String tugasId, String filePath);
}
