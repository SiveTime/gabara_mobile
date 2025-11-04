import '../entities/tugas_entity.dart';
import '../repositories/tugas_repository.dart';

class GetTugasList {
  final TugasRepository repository;
  GetTugasList(this.repository);

  Future<List<TugasEntity>> call(String kelasId) async {
    return await repository.getTugasList(kelasId);
  }
}
