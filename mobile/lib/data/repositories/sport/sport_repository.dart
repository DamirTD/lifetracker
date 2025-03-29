import 'package:mobile/data/api/api_client.dart';
import 'package:mobile/data/models/api_response.dart';
import 'package:mobile/data/models/sport/sport.dart';
import 'package:mobile/data/models/sport/user_sport.dart';
import 'package:mobile/data/models/sport/training_program.dart';
import 'package:mobile/data/models/sport/training_history.dart';

class SportRepository {
  final ApiClient _apiClient;

  SportRepository(this._apiClient);

  // Получение списка видов спорта
  Future<ApiResponse<List<Sport>>> getSportList() async {
    try {
      final response = await _apiClient.get('sport/list', queryParams: {});
      final sports = List<Sport>.from(
        (response['sports'] as List).map((x) => Sport.fromJson(x)),
      );
      return ApiResponse<List<Sport>>(
        success: true,
        data: sports,
      );
    } catch (e) {
      return ApiResponse<List<Sport>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // Получение списка видов спорта пользователя
  Future<ApiResponse<List<Sport>>> getUserSportList() async {
    try {
      final response = await _apiClient.get('sport/user-sport-list', queryParams: {});
      final sports = List<Sport>.from(
        (response['data'] as List).map((x) => Sport.fromJson(x)),
      );
      return ApiResponse<List<Sport>>(
        success: true,
        data: sports,
        message: response['message'],
      );
    } catch (e) {
      return ApiResponse<List<Sport>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // Выбор вида спорта
  Future<ApiResponse<UserSport>> selectUserSport(int sportId) async {
    try {
      final response = await _apiClient.post('sport/select-user-sport', {
        'sport_id': sportId,
      });
      return ApiResponse<UserSport>(
        success: true,
        data: UserSport.fromJson(response['data']),
        message: response['message'],
      );
    } catch (e) {
      return ApiResponse<UserSport>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // Получение базовой программы тренировок
  Future<ApiResponse<Map<String, dynamic>>> getBasicTrainingProgram(int sportId, String goal) async {
    try {
      final response = await _apiClient.post('sport/basic-training-program', {
        'sport_id': sportId,
        'goal': goal,
      });
      return ApiResponse<Map<String, dynamic>>(
        success: true,
        data: {
          'message': response['message'],
          'advice': response['advice'],
        },
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // Добавление пользовательской программы тренировок
  Future<ApiResponse<TrainingProgram>> createPersonalTrainingProgram(TrainingProgram program) async {
    try {
      final response = await _apiClient.post(
        'sport/create-personal-training-program',
        program.toJson(),
      );
      return ApiResponse<TrainingProgram>(
        success: true,
        data: TrainingProgram.fromJson(response['data']),
        message: response['message'],
      );
    } catch (e) {
      return ApiResponse<TrainingProgram>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // Завершение тренировки
  Future<ApiResponse<void>> completeTraining(int trainingProgramId, int duration, int caloriesBurned) async {
    try {
      final response = await _apiClient.post('sport/complete-training', {
        'training_program_id': trainingProgramId,
        'duration': duration,
        'calories_burned': caloriesBurned,
      });
      return ApiResponse<void>(
        success: true,
        message: response['message'],
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // Получение программы тренировок по ID
  Future<ApiResponse<TrainingProgram>> getTrainingProgram(int id) async {
    try {
      final response = await _apiClient.get('sport/training-program/$id', queryParams: {});
      return ApiResponse<TrainingProgram>(
        success: true,
        data: TrainingProgram.fromJson(response['data']),
        message: response['message'],
      );
    } catch (e) {
      return ApiResponse<TrainingProgram>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // Получение истории тренировок
  Future<ApiResponse<List<TrainingHistory>>> getTrainingHistory() async {
    try {
      final response = await _apiClient.get('sport/training-history', queryParams: {});
      final history = List<TrainingHistory>.from(
        (response['data'] as List).map((x) => TrainingHistory.fromJson(x)),
      );
      return ApiResponse<List<TrainingHistory>>(
        success: true,
        data: history,
        message: response['message'],
      );
    } catch (e) {
      return ApiResponse<List<TrainingHistory>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // Редактирование вида спорта (для админов)
  Future<ApiResponse<Sport>> editSport(int id, String name, String goal) async {
    try {
      final response = await _apiClient.put('sport/edit/$id', {
        'name': name,
        'goal': goal,
      });
      return ApiResponse<Sport>(
        success: true,
        data: Sport.fromJson(response['data']),
        message: response['message'],
      );
    } catch (e) {
      return ApiResponse<Sport>(
        success: false,
        message: e.toString(),
      );
    }
  }

  // Удаление вида спорта пользователя
  Future<ApiResponse<void>> deleteUserSport(int id) async {
    try {
      final response = await _apiClient.delete('sport/user-sport/$id');
      return ApiResponse<void>(
        success: true,
        message: response['message'],
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: e.toString(),
      );
    }
  }
}