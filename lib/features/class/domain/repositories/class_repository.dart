import '../entities/class_entity.dart';

abstract class ClassRepository {
  Future<List<ClassEntity>> getClasses();
  Future<ClassEntity> createClass(ClassEntity newClass);
  Future<void> joinClass(String classId);
}
