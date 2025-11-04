import 'dart:convert';
import 'package:http/http.dart' as http;
import '../error/exceptions.dart';
import '../constants/api_endpoints.dart';

class ApiClient {
  final http.Client client;

  ApiClient({required this.client});

  Future<dynamic> get(String endpoint) async {
    final url = _fullUrl(endpoint);
    final response = await client.get(Uri.parse(url));
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = _fullUrl(endpoint);
    final response = await client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body ?? {}),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    final url = _fullUrl(endpoint);
    final response = await client.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body ?? {}),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final url = _fullUrl(endpoint);
    final response = await client.delete(Uri.parse(url));
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    // Safely decode JSON body (handle empty response)
    dynamic body;
    if (response.body.isEmpty) {
      body = null;
    } else {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = response.body;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    } else if (statusCode >= 400 && statusCode < 500) {
      final message = (body is Map && body['message'] != null) ? body['message'] : 'Permintaan tidak valid';
      throw ServerException(message);
    } else {
      throw ServerException('Terjadi kesalahan server (${response.statusCode})');
    }
  }

  String _fullUrl(String endpoint) {
    if (endpoint.startsWith('http')) return endpoint;
    // ensure leading slash
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '${ApiEndpoints.baseUrl}$path';
  }
}
