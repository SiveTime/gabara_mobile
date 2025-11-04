import 'package:gabara_mobile/core/network/api_client.dart';
import '../models/class_model.dart';

class ClassService {
  final ApiClient apiClient;

  ClassService(this.apiClient);

  Future<List<ClassModel>> fetchClasses() async {
    final response = await apiClient.get('/classes');
    return (response as List)
        .map((data) => ClassModel.fromJson(data))
        .toList();
  }

  Future<ClassModel> createClass(Map<String, dynamic> data) async {
    final response = await apiClient.post('/classes', body: data);
    return ClassModel.fromJson(response);
  }

  Future<void> joinClass(String classId) async {
    await apiClient.post('/classes/join', body: {'class_id': classId});
  }
}
