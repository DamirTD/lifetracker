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

  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Пожалуйста, войдите в систему.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<dynamic> get(String path, {required Map<String, dynamic> queryParams}) async {
    try {
      final headers = await _getHeaders();

      final uri = Uri.parse('$baseUrl/$path').replace(
          queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString()))
      );

      final response = await _httpClient.get(
        uri,
        headers: headers,
      );
      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(String path, dynamic data, {bool requireAuth = true}) async {
    try {
      final headers  = await _getHeaders(requireAuth: requireAuth);
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

  // Публичный POST запрос без авторизации (для login/register)
  Future<dynamic> postPublic(String path, dynamic data) async {
    return post(path, data, requireAuth: false);
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
        String errorMessage = error['message'] ?? 'Неизвестная ошибка';
        
        // Обработка ошибок валидации (422)
        if (response.statusCode == 422 && error['errors'] != null) {
          final errors = error['errors'] as Map<String, dynamic>;
          final errorList = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              errorList.addAll(value.map((e) => e.toString()));
            } else {
              errorList.add(value.toString());
            }
          });
          errorMessage = errorList.join('\n');
        }
        
        throw Exception(errorMessage);
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    }
  }

  Future<dynamic> uploadFile(String endpoint, String filePath) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl$endpoint');

    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    return _processResponse(response);
  }
}