import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/config.dart';
import 'package:mobile/data/models/grouped_tasks.dart';
import 'package:mobile/data/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskRepository {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Токен авторизации отсутствует. Пожалуйста, войдите в систему.');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<GroupedTasks>> getTasks() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('${Config.apiUrl}/tasks'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          return (data['data'] as List)
              .map((taskGroup) => GroupedTasks.fromJson(taskGroup))
              .toList();
        }
        return [];
      } else if (response.statusCode == 401) {
        // Обработка устаревшего токена
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        throw Exception('Сессия истекла. Пожалуйста, войдите в систему повторно.');
      } else {
        throw Exception('Ошибка загрузки задач: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Task> createTask(Task task) async {
    try {
      final headers = await _getHeaders();

      final response = await http.post(
        Uri.parse('${Config.apiUrl}/tasks'),
        headers: headers,
        body: jsonEncode(task.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Task.fromJson(data['data']);
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        throw Exception('Сессия истекла. Пожалуйста, войдите в систему повторно.');
      } else {
        throw Exception('Ошибка создания задачи: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Task> updateTask(int taskId, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();

      if (data['due_date'] == '') {
        data['due_date'] = null;
      }

      final response = await http.put(
        Uri.parse('${Config.apiUrl}/tasks/$taskId'),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Task.fromJson(responseData['data']);
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        throw Exception('Сессия истекла. Пожалуйста, войдите в систему повторно.');
      } else if (response.statusCode == 422) {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Ошибка валидации';

        if (errorData['errors'] != null) {
          final errors = <String>[];
          (errorData['errors'] as Map<String, dynamic>).forEach((key, value) {
            if (value is List) {
              errors.addAll(value.map((e) => e.toString()));
            } else {
              errors.add('$key: $value');
            }
          });
          errorMessage = errors.join('\n');
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }

        throw Exception('Ошибка валидации: $errorMessage');
      } else {
        throw Exception('Ошибка обновления задачи: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.delete(
        Uri.parse('${Config.apiUrl}/tasks/$taskId'),
        headers: headers,
      );

      if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        throw Exception('Сессия истекла. Пожалуйста, войдите в систему повторно.');
      } else if (response.statusCode != 204) {
        throw Exception('Ошибка удаления задачи: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Task> markTaskAsCompleted(int taskId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.patch(
        Uri.parse('${Config.apiUrl}/tasks/$taskId/complete'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Task.fromJson(data['data']);
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        throw Exception('Сессия истекла. Пожалуйста, войдите в систему повторно.');
      } else {
        throw Exception('Ошибка отметки задачи: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}