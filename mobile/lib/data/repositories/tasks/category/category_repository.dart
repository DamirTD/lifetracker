import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/config.dart';
import 'package:mobile/data/models/task_category.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryRepository {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    
    
    return {
      'Content-Type':  'application/json',
      'Accept':        'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<TaskCategory>> getCategories() async {
    final headers = await _getHeaders();
    final url = '${Config.apiUrl}/categories';
    
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List)
            .map((category) => TaskCategory.fromJson(category))
            .toList();
      } else {
        throw Exception('Ошибка загрузки категорий: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskCategory> createCategory(String name) async {
    final headers = await _getHeaders();
    final url = '${Config.apiUrl}/categories';
    final body = jsonEncode({'name': name});
    
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return TaskCategory.fromJson(data);
      } else {
        throw Exception('Ошибка создания категории: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}