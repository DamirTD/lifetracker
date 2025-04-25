import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/config.dart';
import 'package:mobile/data/models/task_category.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskCategoryRepository {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Пожалуйста, войдите в систему.');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<TaskCategory>> getCategories() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('${Config.apiUrl}/categories'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          return (data['data'] as List)
              .map((category) => TaskCategory.fromJson(category))
              .toList();
        }
        return [];
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        throw Exception(
          'Сессия истекла. Пожалуйста, войдите в систему повторно.',
        );
      } else {
        throw Exception('Ошибка загрузки категорий: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskCategory> createCategory(String name) async {
    try {
      final headers = await _getHeaders();

      final response = await http.post(
        Uri.parse('${Config.apiUrl}/categories'),
        headers: headers,
        body: jsonEncode({'name': name}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['data'] != null && data['data'] is Map<String, dynamic>) {
          return TaskCategory.fromJson(data['data']);
        } else {
          throw Exception(
            'Некорректный формат ответа от сервера: отсутствует поле "data"',
          );
        }
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        throw Exception(
          'Сессия истекла. Пожалуйста, войдите в систему повторно.',
        );
      } else {
        throw Exception('Ошибка создания категории: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskCategory> updateCategory(int categoryId, String name) async {
    try {
      final headers = await _getHeaders();

      final response = await http.put(
        Uri.parse('${Config.apiUrl}/categories/$categoryId'),
        headers: headers,
        body: jsonEncode({'name': name}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TaskCategory.fromJson(data['data']);
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        throw Exception(
          'Сессия истекла. Пожалуйста, войдите в систему повторно.',
        );
      } else if (response.statusCode == 404) {
        throw Exception(
          'Категория не найдена или у вас нет прав для её изменения',
        );
      } else {
        throw Exception('Ошибка обновления категории: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteCategory(int categoryId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.delete(
        Uri.parse('${Config.apiUrl}/categories/$categoryId'),
        headers: headers,
      );

      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        throw Exception(
          'Сессия истекла. Пожалуйста, войдите в систему повторно.',
        );
      } else if (response.statusCode == 404) {
        throw Exception(
          'Категория не найдена или у вас нет прав для её удаления',
        );
      } else {
        throw Exception('Ошибка удаления категории: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
