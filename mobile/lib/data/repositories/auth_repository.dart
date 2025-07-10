import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import '../../core/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  Future<UserModel?> login(String login, String password) async {
    final response = await http.post(
      Uri.parse("${Config.apiUrl}/login"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "login": login,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token']);
      final storedToken = prefs.getString('auth_token');
      if (storedToken != data['token']) {
        throw Exception("Токен не сохранился в SharedPreferences");
      }
      return UserModel.fromJson(data);
    }
    return null;
  }

  Future<Map<String, dynamic>> register(Map<String, String> userData) async {
    final response = await http.post(
      Uri.parse("${Config.apiUrl}/register"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(userData),
    );

    return {
      "status": response.statusCode,
      "body": jsonDecode(response.body),
    };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse("${Config.apiUrl}/logout"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        await prefs.remove('auth_token');
      } else {
        throw Exception("Ошибка выхода: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      // ignore: avoid_print
      print("Ошибка сети при выходе: $e");
    }
  }
}
