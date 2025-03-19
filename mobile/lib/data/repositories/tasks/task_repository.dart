import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/config.dart';
import 'package:mobile/data/models/grouped_tasks.dart';
import 'package:mobile/data/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskRepository {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<GroupedTasks>> getTasks() async {
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
    } else {
      throw Exception('Ошибка загрузки задач: ${response.statusCode}');
    }
  }

  Future<Task> createTask(Task task) async {
    final headers = await _getHeaders();
    
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/tasks'),
      headers: headers,
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Task.fromJson(data['data']);
    } else {
      throw Exception('Ошибка создания задачи: ${response.statusCode}');
    }
  }

  Future<Task> updateTask(Task task) async {
    final headers = await _getHeaders();
    
    final response = await http.put(
      Uri.parse('${Config.apiUrl}/tasks/${task.id}'),
      headers: headers,
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Task.fromJson(data['data']);
    } else {
      throw Exception('Ошибка обновления задачи: ${response.statusCode}');
    }
  }

  Future<void> deleteTask(int taskId) async {
    final headers = await _getHeaders();
    
    final response = await http.delete(
      Uri.parse('${Config.apiUrl}/tasks/$taskId'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Ошибка удаления задачи: ${response.statusCode}');
    }
  }

  Future<Task> markTaskAsCompleted(int taskId) async {
    final headers = await _getHeaders();
    
    final response = await http.patch(
      Uri.parse('${Config.apiUrl}/tasks/$taskId/complete'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Task.fromJson(data['data']);
    } else {
      throw Exception('Ошибка отметки задачи: ${response.statusCode}');
    }
  }
}