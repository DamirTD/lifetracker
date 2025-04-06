import '../../models/diet/daily_diet.dart';
import '../../models/diet/diet_entry.dart';
import '../../models/diet/diet_goals.dart';
import '../../models/diet/food.dart';
import '../../models/diet/weekly_summary.dart';
import '../../api/api_client.dart';

class DietRepository {
  final ApiClient _apiClient;

  DietRepository(this._apiClient);

  Future<List<Food>> getFoods({String? search}) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await _apiClient.get('diet/foods', queryParams: queryParams);
    final data = response as List;
    return data.map((json) => Food.fromJson(json)).toList();
  }

  // Получение рациона на день
  Future<DailyDiet> getDailyDiet(String date, {String? mealType}) async {
    final queryParams = <String, dynamic>{};
    if (mealType != null) {
      queryParams['meal_type'] = mealType;
    }

    final response = await _apiClient.get('diet/daily/$date', queryParams: queryParams);
    return DailyDiet.fromJson(response);
  }

  // Получение недельной статистики
  Future<List<WeeklySummary>> getWeeklyDiet({String? date}) async {
    final queryParams = <String, dynamic>{};
    if (date != null) {
      queryParams['date'] = date;
    }

    final response = await _apiClient.get('diet/weekly', queryParams: queryParams);
    final data = response as List;
    return data.map((json) => WeeklySummary.fromJson(json)).toList();
  }

  // Получение месячной статистики
  Future<Map<String, dynamic>> getMonthlyDiet({int? year, int? month}) async {
    final queryParams = <String, dynamic>{};
    if (year != null) {
      queryParams['year'] = year;
    }
    if (month != null) {
      queryParams['month'] = month;
    }

    return await _apiClient.get('diet/monthly', queryParams: queryParams);
  }

  // Получение статистики за период
  Future<Map<String, dynamic>> getStatistics(String period) async {
    final queryParams = {'period': period};
    return await _apiClient.get('diet/statistics', queryParams: queryParams);
  }

  // Добавление продукта в рацион
  Future<DietEntry> addFood(DietEntry entry) async {
    final response = await _apiClient.post('diet/food', entry.toJson());
    return DietEntry.fromJson(response);
  }

  // Обновление записи в рационе
  Future<DietEntry> updateFood(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('diet/food/$id', data);
    return DietEntry.fromJson(response);
  }

  // Удаление записи из рациона
  Future<void> deleteFood(int id) async {
    await _apiClient.delete('diet/food/$id');
  }

  // Получение целей питания
  Future<DietGoals> getDietGoals() async {
    final response = await _apiClient.get('diet/goals', queryParams: {});
    return DietGoals.fromJson(response);
  }

  // Обновление целей питания
  Future<DietGoals> updateDietGoals(DietGoals goals) async {
    final response = await _apiClient.put('diet/goals', goals.toJson());
    return DietGoals.fromJson(response);
  }
}