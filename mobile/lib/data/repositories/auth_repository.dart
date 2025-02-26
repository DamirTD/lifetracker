import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import '../../core/config.dart';

class AuthRepository {
  Future<UserModel?> login(String login, String password) async {
    final response = await http.post(
      Uri.parse("${Config.apiUrl}/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "login": login,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<UserModel?> register({
    required String name,
    required String surname,
    required String login,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse("${Config.apiUrl}/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name":                  name,
        "surname":               surname,
        "login":                 login,
        "email":                 email,
        "password":              password,
        "password_confirmation": passwordConfirmation,
      }),
    );

    if (response.statusCode == 201) {
      return UserModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }
}
