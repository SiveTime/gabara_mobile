import '../repositories/class_repository.dart';

class JoinClass {
  final ClassRepository repository;

  JoinClass(this.repository);

  Future<void> call(String classId) async {
    await repository.joinClass(classId);
  }
}
