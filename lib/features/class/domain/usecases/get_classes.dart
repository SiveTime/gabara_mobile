import '../entities/class_entity.dart';
import '../repositories/class_repository.dart';

class GetClasses {
  final ClassRepository repository;

  GetClasses(this.repository);

  Future<List<ClassEntity>> call() async {
    return await repository.getClasses();
  }
}
