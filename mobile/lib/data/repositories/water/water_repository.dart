import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/config.dart';
import '../../models/water/water_progress.dart';
import '../../models/water/water_container.dart';
import '../../models/water/water_reminder.dart';
import '../../models/water/water_stats.dart';
import '../../models/water/water_eco_report.dart';
import '../../models/water/water_goal_settings.dart';

class WaterRepository {
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
        throw Exception(error['message'] ?? 'Неизвестная ошибка');
      } catch (e) {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    }
  }

  Future<Map<String, dynamic>> setDailyGoal(WaterGoalSettings settings) async {
    try {
      final headers = await _getHeaders();

      final response = await http.post(
        Uri.parse('${Config.apiUrl}/water/set-daily-goal'),
        headers: headers,
        body: jsonEncode(settings.toJson()),
      );

      final data = _processResponse(response);
      return data['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addGlass({int? containerId, int? volumeMl}) async {
    try {
      final headers = await _getHeaders();
      final Map<String, dynamic> data = {};

      if (containerId != null) data['container_id'] = containerId;
      if (volumeMl != null) data['volume_ml'] = volumeMl;

      final response = await http.post(
        Uri.parse('${Config.apiUrl}/water/add-glass'),
        headers: headers,
        body: data.isNotEmpty ? jsonEncode(data) : null,
      );

      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> removeGlass() async {
    try {
      final headers = await _getHeaders();

      final response = await http.post(
        Uri.parse('${Config.apiUrl}/water/remove-glass'),
        headers: headers,
      );

      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<WaterProgress> getDailyStats() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('${Config.apiUrl}/water/daily-stats'),
        headers: headers,
      );

      final data = _processResponse(response);
      return WaterProgress.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<WaterStats> getOverallStats() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('${Config.apiUrl}/water/overall-stats'),
        headers: headers,
      );

      final data = _processResponse(response);
      return WaterStats.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDailyConsumption({String? date}) async {
    try {
      final headers = await _getHeaders();

      Uri uri = Uri.parse('${Config.apiUrl}/water/daily-consumption');
      if (date != null) {
        uri = uri.replace(queryParameters: {'date': date});
      }

      final response = await http.get(
        uri,
        headers: headers,
      );

      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getWeeklyConsumption({String? startDate}) async {
    try {
      final headers = await _getHeaders();

      Uri uri = Uri.parse('${Config.apiUrl}/water/weekly-consumption');
      if (startDate != null) {
        uri = uri.replace(queryParameters: {'start_date': startDate});
      }

      final response = await http.get(
        uri,
        headers: headers,
      );

      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMonthlyConsumption({String? yearMonth}) async {
    try {
      final headers = await _getHeaders();

      Uri uri = Uri.parse('${Config.apiUrl}/water/monthly-consumption');
      if (yearMonth != null) {
        uri = uri.replace(queryParameters: {'year_month': yearMonth});
      }

      final response = await http.get(
        uri,
        headers: headers,
      );

      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getHistory({
    String? startDate,
    String? endDate,
    int perPage = 10,
  }) async {
    try {
      final headers = await _getHeaders();

      Map<String, String> queryParams = {'per_page': perPage.toString()};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final uri = Uri.parse('${Config.apiUrl}/water/history')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: headers,
      );

      return _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<WaterContainer>> getContainers() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('${Config.apiUrl}/water/containers'),
        headers: headers,
      );

      final data = _processResponse(response);
      return (data as List).map((item) => WaterContainer.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<WaterContainer> saveContainer(WaterContainer container) async {
    try {
      final headers = await _getHeaders();

      final response = await http.post(
        Uri.parse('${Config.apiUrl}/water/save-container'),
        headers: headers,
        body: jsonEncode(container.toJson()),
      );

      final data = _processResponse(response);
      return WaterContainer.fromJson(data['container']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteContainer(int containerId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.delete(
        Uri.parse('${Config.apiUrl}/water/containers/$containerId'),
        headers: headers,
      );

      _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<WaterReminder>> getReminders() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('${Config.apiUrl}/water/reminders'),
        headers: headers,
      );

      // Handle 500 error by returning an empty list instead of throwing
      if (response.statusCode == 500) {
        return [];
      }

      final data = _processResponse(response);
      return (data as List).map((item) => WaterReminder.fromJson(item)).toList();
    } catch (e) {
      // Return empty list for any error
      return [];
    }
  }

  Future<WaterReminder> setReminder(WaterReminder reminder) async {
    try {
      final headers = await _getHeaders();

      final response = await http.post(
        Uri.parse('${Config.apiUrl}/water/set-reminder'),
        headers: headers,
        body: jsonEncode(reminder.toJson()),
      );

      final data = _processResponse(response);
      return WaterReminder.fromJson(data['reminder']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteReminder(int reminderId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.delete(
        Uri.parse('${Config.apiUrl}/water/reminders/$reminderId'),
        headers: headers,
      );

      _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleReminder(int reminderId, bool isEnabled) async {
    try {
      final headers = await _getHeaders();

      final response = await http.put(
        Uri.parse('${Config.apiUrl}/water/reminders/$reminderId/toggle'),
        headers: headers,
        body: jsonEncode({'is_enabled': isEnabled}),
      );

      _processResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getInsights() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('${Config.apiUrl}/water/insights'),
        headers: headers,
      );

      if (response.statusCode == 500 || response.statusCode == 404) {
        // Return placeholder data for specific error codes
        return {
          'best_time': 'Нет данных',
          'best_day': 'Нет данных',
          'regularity_score': 0,
          'recommendation_time': 'Старайтесь пить воду регулярно в течение дня',
          'recommendation_volume': 'Стремитесь потреблять рекомендуемое количество воды каждый день',
          'recommendation_distribution': 'Равномерно распределяйте потребление воды в течение дня'
        };
      }

      return _processResponse(response);
    } catch (e) {
      // Return placeholder data for any error
      return {
        'best_time': 'Нет данных',
        'best_day': 'Нет данных',
        'regularity_score': 0,
        'recommendation_time': 'Старайтесь пить воду регулярно в течение дня',
        'recommendation_volume': 'Стремитесь потреблять рекомендуемое количество воды каждый день',
        'recommendation_distribution': 'Равномерно распределяйте потребление воды в течение дня'
      };
    }
  }

  Future<Map<String, dynamic>> getComparison() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('${Config.apiUrl}/water/comparison'),
        headers: headers,
      );

      if (response.statusCode == 500 || response.statusCode == 404) {
        // Return placeholder data for specific error codes
        return {
          'your_daily_consumption': 0,
          'avg_daily_consumption': 0,
          'your_consistency': 0,
          'avg_consistency': 0
        };
      }

      return _processResponse(response);
    } catch (e) {
      // Return placeholder data for any error
      return {
        'your_daily_consumption': 0,
        'avg_daily_consumption': 0,
        'your_consistency': 0,
        'avg_consistency': 0
      };
    }
  }

  Future<WaterEcoReport> getEcoReport() async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('${Config.apiUrl}/water/eco-report'),
        headers: headers,
      );

      final data = _processResponse(response);
      return WaterEcoReport.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}