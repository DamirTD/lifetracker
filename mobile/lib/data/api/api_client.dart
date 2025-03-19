import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient = http.Client();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiClient({required this.baseUrl});

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path) async {
    final headers  = await _getHeaders();
    final response = await _httpClient.get(
      Uri.parse('$baseUrl/$path'),
      headers: headers,
    );
    return _processResponse(response);
  }

  Future<dynamic> post(String path, dynamic data) async {
    final headers  = await _getHeaders();
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/$path'),
      headers: headers,
      body: jsonEncode(data),
    );
    return _processResponse(response);
  }

  Future<dynamic> put(String path, dynamic data) async {
    final headers  = await _getHeaders();
    final response = await _httpClient.put(
      Uri.parse('$baseUrl/$path'),
      headers: headers,
      body: jsonEncode(data),
    );
    return _processResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final headers  = await _getHeaders();
    final response = await _httpClient.delete(
      Uri.parse('$baseUrl/$path'),
      headers: headers,
    );
    return _processResponse(response);
  }

  Future<dynamic> patch(String path, [dynamic data]) async {
    final headers  = await _getHeaders();
    final response = await _httpClient.patch(
      Uri.parse('$baseUrl/$path'),
      headers: headers,
      body: data != null ? jsonEncode(data) : null,
    );
    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Unknown error');
    }
  }
}