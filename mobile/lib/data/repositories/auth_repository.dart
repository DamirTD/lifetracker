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
    final url = "${Config.apiUrl}/register";
    print("🔵 [REGISTER] Отправка запроса на: $url");
    print("🔵 [REGISTER] Данные: ${userData.keys.map((k) => '$k: ***').join(', ')}");
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(userData),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print("❌ [REGISTER] Таймаут запроса");
          throw Exception("Таймаут запроса. Проверьте подключение к интернету.");
        },
      );

      print("🔵 [REGISTER] Статус ответа: ${response.statusCode}");
      print("🔵 [REGISTER] Тело ответа: ${response.body}");

      Map<String, dynamic> body;
      try {
        if (response.body.isEmpty) {
          body = {'error': 'Пустой ответ от сервера'};
        } else {
          body = jsonDecode(response.body) as Map<String, dynamic>;
        }
      } catch (e) {
        print("❌ [REGISTER] Ошибка парсинга JSON: $e");
        body = {
          'error': 'Неверный формат ответа от сервера',
          'raw_response': response.body,
        };
      }

      return {
        "status": response.statusCode,
        "body": body,
      };
    } catch (e) {
      print("❌ [REGISTER] Ошибка сети: $e");
      return {
        "status": 0,
        "body": {
          "error": e.toString(),
          "message": "Ошибка соединения с сервером. Проверьте подключение к интернету.",
        },
      };
    }
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
