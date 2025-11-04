// lib/features/quiz/data/services/quiz_service.dart
// NOTE: adjust import to your project path for ApiClient or use your existing ApiClient
// e.g. import 'package:your_app/core/network/api_client.dart';
import 'dart:convert';

import '../../../../core/network/api_client.dart'; // <-- adjust if needed

class QuizService {
  final ApiClient client;
  QuizService(this.client);

  Future<List<dynamic>> fetchQuizzesRaw() async {
    // Example endpoint: /quizzes
    final res = await client.get('/quizzes');
    // assuming client.get returns parsed JSON already, or string
    if (res == null) return [];
    if (res is String) return jsonDecode(res) as List<dynamic>;
    return res as List<dynamic>;
  }

  Future<dynamic> fetchQuizByIdRaw(String id) async {
    final res = await client.get('/quizzes/$id');
    return res;
  }

  Future<bool> submitAnswersRaw(String quizId, Map<String, String> answers) async {
    final payload = {'answers': answers};
    final res = await client.post('/quizzes/$quizId/submit', body: payload);
    // assume success if status true
    if (res == null) return false;
    if (res is Map && res['success'] == true) return true;
    return true; // fallback
  }

  Future<dynamic> createQuizRaw(Map<String, dynamic> payload) async {
    final res = await client.post('/quizzes', body: payload);
    return res;
  }
}
