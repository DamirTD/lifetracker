import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient = http.Client();

  ApiClient({required this.baseUrl});

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Пожалуйста, войдите в систему.');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path) async {
    try {
      final headers  = await _getHeaders();
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/$path'),
        headers: headers,
      );
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(String path, dynamic data) async {
    try {
      final headers  = await _getHeaders();
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/$path'),
        headers: headers,
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> put(String path, dynamic data) async {
    try {
      final headers  = await _getHeaders();
      final response = await _httpClient.put(
        Uri.parse('$baseUrl/$path'),
        headers: headers,
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final headers  = await _getHeaders();
      final response = await _httpClient.delete(
        Uri.parse('$baseUrl/$path'),
        headers: headers,
      );
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> patch(String path, [dynamic data]) async {
    try {
      final headers  = await _getHeaders();
      final response = await _httpClient.patch(
        Uri.parse('$baseUrl/$path'),
        headers: headers,
        body: data != null ? jsonEncode(data) : null,
      );
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove('auth_token');
      });
      throw Exception('Сессия истекла. Пожалуйста, войдите в систему повторно.');
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Неизвестная ошибка');
      } catch (e) {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    }
  }
}