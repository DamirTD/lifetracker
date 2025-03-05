import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config.dart';
import '../models/user_model.dart';

class UserRepository {
  Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      if (token.isEmpty) return null;

      final response = await http
          .get(
            Uri.parse("${Config.apiUrl}/user"),
            headers: {"Authorization": "Bearer $token"},
          )
          .timeout(const Duration(seconds: 5)); // ⏳ Таймаут 5 сек

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      } else {
        return null;
      }
    } on TimeoutException {
      // ignore: avoid_print
      print("⏳ Запрос превысил время ожидания");
      return null;
    } on http.ClientException catch (e) {
      // ignore: avoid_print
      print("🌐 Ошибка сети: $e");
      return null;
    } catch (e) {
      // ignore: avoid_print
      print("❌ Неизвестная ошибка: $e");
      return null;
    }
  }
}
