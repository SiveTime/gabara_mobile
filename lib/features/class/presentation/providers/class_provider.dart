import 'package:flutter/foundation.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/usecases/get_classes.dart';
import '../../domain/usecases/create_class.dart';
import '../../domain/usecases/join_class.dart';

class ClassProvider extends ChangeNotifier {
  final GetClasses getClasses;
  final CreateClass createClass;
  final JoinClass joinClass;

  ClassProvider({
    required this.getClasses,
    required this.createClass,
    required this.joinClass,
  });

  List<ClassEntity> _classes = [];
  bool _isLoading = false;

  List<ClassEntity> get classes => _classes;
  bool get isLoading => _isLoading;

  Future<void> fetchClasses() async {
    _isLoading = true;
    notifyListeners();
    _classes = await getClasses();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addClass(ClassEntity newClass) async {
    await createClass(newClass);
    await fetchClasses();
  }

  Future<void> join(String classId) async {
    await joinClass(classId);
    await fetchClasses();
  }
}
