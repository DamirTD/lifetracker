import 'package:mobile/data/api/api_client.dart';

import '../../models/api_response.dart';
import '../../models/sleep/sleep.dart';
import '../../models/sleep/sleep_goal.dart';
import '../../models/sleep/sleep_statistics.dart';

class SleepRepository {
  final ApiClient _apiClient;

  SleepRepository(this._apiClient);

  Future<ApiResponse<Sleep>> recordSleep(Sleep sleep) async {
    try {
      final response = await _apiClient.post('sleep/record', sleep.toJson());
      return ApiResponse<Sleep>(
        success: true,
        data: Sleep.fromJson(response['sleep_data']),
        message: response['message'],
      );
    } catch (e) {
      return ApiResponse<Sleep>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<List<String>>> getRecommendations() async {
    try {
      final response = await _apiClient.get('sleep/recommendations', queryParams: {});
      final recommendations = List<String>.from(response['recommendations']);
      return ApiResponse<List<String>>(
        success: true,
        data: recommendations,
      );
    } catch (e) {
      return ApiResponse<List<String>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<SleepStatistics>> getStatistics(String period) async {
    try {
      final response = await _apiClient.get('sleep/stats', queryParams: {'period': period});
      return ApiResponse<SleepStatistics>(
        success: true,
        data: SleepStatistics.fromJson(response),
      );
    } catch (e) {
      return ApiResponse<SleepStatistics>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<SleepTrend>> getTrends(int months) async {
    try {
      final response = await _apiClient.get('sleep/trends', queryParams: {'months': months});
      return ApiResponse<SleepTrend>(
        success: true,
        data: SleepTrend.fromJson(response),
      );
    } catch (e) {
      return ApiResponse<SleepTrend>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<SleepGoal>> setSleepGoals(SleepGoal goal) async {
    try {
      final response = await _apiClient.post('sleep/goals', goal.toJson());
      return ApiResponse<SleepGoal>(
        success: true,
        data: SleepGoal.fromJson(response['goals']),
        message: response['message'],
      );
    } catch (e) {
      return ApiResponse<SleepGoal>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<SleepGoalProgress>> getGoalsProgress() async {
    try {
      final response = await _apiClient.get('sleep/goals/progress', queryParams: {});
      return ApiResponse<SleepGoalProgress>(
        success: true,
        data: SleepGoalProgress.fromJson(response['progress']),
      );
    } catch (e) {
      return ApiResponse<SleepGoalProgress>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> importDeviceData(String deviceType, Map<String, dynamic> data) async {
    try {
      final payload = {
        'device_type': deviceType,
        'data': data,
      };
      final response = await _apiClient.post('sleep/import', payload);
      return ApiResponse<Map<String, dynamic>>(
        success: true,
        data: {
          'processed_entries': response['processed_entries'],
          'sleep_records': response['sleep_records'],
        },
        message: response['message'],
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<List<SleepCorrelation>>> getSleepCorrelations() async {
    try {
      final response = await _apiClient.get('sleep/correlations', queryParams: {});
      final correlations = List<SleepCorrelation>.from(
        response['correlations'].map((x) => SleepCorrelation.fromJson(x)),
      );
      return ApiResponse<List<SleepCorrelation>>(
        success: true,
        data: correlations,
      );
    } catch (e) {
      return ApiResponse<List<SleepCorrelation>>(
        success: false,
        message: e.toString(),
      );
    }
  }
}