import '../entities/class_entity.dart';
import '../repositories/class_repository.dart';

class CreateClass {
  final ClassRepository repository;

  CreateClass(this.repository);

  Future<ClassEntity> call(ClassEntity newClass) async {
    return await repository.createClass(newClass);
  }
}
