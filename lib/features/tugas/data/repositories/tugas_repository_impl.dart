import '../../domain/entities/tugas_entity.dart';
import '../../domain/repositories/tugas_repository.dart';
import '../services/tugas_service.dart';

class TugasRepositoryImpl implements TugasRepository {
  final TugasService service;
  TugasRepositoryImpl(this.service);

  @override
  Future<List<TugasEntity>> getTugasList(String kelasId) async {
    final data = await service.fetchTugasList(kelasId);
    return data
        .map((model) => TugasEntity(
              id: model.id,
              title: model.title,
              description: model.description,
              deadline: model.deadline,
              kelas: model.kelas,
              isSubmitted: model.isSubmitted,
            ))
        .toList();
  }

  @override
  Future<void> submitTugas(String tugasId, String filePath) async {
    await service.uploadTugas(tugasId, filePath);
  }
}
