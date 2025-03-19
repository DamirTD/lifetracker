import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get apiUrl => dotenv.env['API_URL'] ?? "http://10.0.2.2:80/api";
}