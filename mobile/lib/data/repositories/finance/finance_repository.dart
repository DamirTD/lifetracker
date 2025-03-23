import '../../api/api_client.dart';
import '../../models/finance/finance_budget.dart';
import '../../models/finance/finance_calculation.dart';
import '../../models/finance/finance_category.dart';
import '../../models/finance/finance_goal.dart';
import '../../models/finance/finance_record.dart';
import '../../models/finance/finance_summary.dart';
import '../../models/finance/financial_advice.dart';

class FinanceRepository {
  final ApiClient _apiClient;

  FinanceRepository(this._apiClient);

  Future<FinanceCalculation> calculateFinance(double salary,
      String rule) async {
    final response = await _apiClient.post('finance/calculate', {
      'salary': salary,
      'rule': rule,
    });
    return FinanceCalculation.fromJson(response);
  }

  Future<List<FinancialAdvice>> getFinancialAdvice() async {
    final response = await _apiClient.get('finance/advice', queryParams: {});
    return (response['advice'] as List)
        .map((advice) => FinancialAdvice.fromJson(advice))
        .toList();
  }

  Future<FinanceRecord> createFinanceRecord(FinanceRecord record) async {
    final response = await _apiClient.post(
        '/finance/record', record.toJson());
    return FinanceRecord.fromJson(response['record']);
  }

  Future<Map<String, dynamic>> getFinanceRecords({
    String? period,
    String? type,
    int? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'date',
    String sortDirection = 'desc',
    int page = 1,
    int perPage = 15,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      'sort_by': sortBy,
      'sort_direction': sortDirection,
    };

    if (period != null) queryParams['period'] = period;
    if (type != null) queryParams['type'] = type;
    if (categoryId != null) queryParams['category_id'] = categoryId.toString();
    if (startDate != null) {
      queryParams['start_date'] = startDate
        .toIso8601String()
        .split('T')
        .first;
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate
        .toIso8601String()
        .split('T')
        .first;
    }

    final response = await _apiClient.get(
        'finance/records', queryParams: queryParams);

    final records = (response['records']['data'] as List)
        .map((record) => FinanceRecord.fromJson(record))
        .toList();

    final summary = FinanceSummary.fromJson(response['summary']);

    return {
      'records': records,
      'summary': summary,
      'pagination': {
        'current_page': response['records']['current_page'],
        'total': response['records']['total'],
        'per_page': response['records']['per_page'],
        'last_page': response['records']['last_page'],
      },
    };
  }

  Future<FinanceRecord> updateFinanceRecord(int id,
      FinanceRecord record) async {
    final response = await _apiClient.put(
        'finance/record/$id', record.toJson());
    return FinanceRecord.fromJson(response['record']);
  }

  Future<void> deleteFinanceRecord(int id) async {
    await _apiClient.delete('finance/record/$id');
  }

  Future<Map<String, dynamic>> getFinanceStatistics({
    String period = 'month',
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    String groupBy = 'day',
  }) async {
    final queryParams = <String, dynamic>{
      'period': period,
      'group_by': groupBy,
    };

    if (type != null) queryParams['type'] = type;
    if (startDate != null) {
      queryParams['start_date'] = startDate
        .toIso8601String()
        .split('T')
        .first;
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate
        .toIso8601String()
        .split('T')
        .first;
    }

    return await _apiClient.get(
        'finance/statistics', queryParams: queryParams);
  }

  Future<Budget> createBudget(Budget budget) async {
    final response = await _apiClient.post(
        'finance/budget', budget.toJson());
    return Budget.fromJson(response['budget']);
  }

  Future<List<Budget>> getBudgets({String? period, int? categoryId}) async {
    try {
      final queryParams = <String, dynamic>{};

      if (period != null) queryParams['period'] = period;
      if (categoryId != null) queryParams['category_id'] = categoryId.toString();

      final response = await _apiClient.get(
          'finance/budgets', queryParams: queryParams);

      if (response == null || response['budgets'] == null) {
        return [];
      }

      return (response['budgets'] as List)
          .map((budget) => Budget.fromJson(budget))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<FinancialGoal> createFinancialGoal(FinancialGoal goal) async {
    final response = await _apiClient.post('finance/goal', goal.toJson());
    return FinancialGoal.fromJson(response['goal']);
  }

  Future<List<FinancialGoal>> getFinancialGoals({
    String status = 'active',
    String? priority,
  }) async {
    final queryParams = <String, dynamic>{
      'status': status,
    };

    if (priority != null) queryParams['priority'] = priority;

    final response = await _apiClient.get(
        'finance/goals', queryParams: queryParams);
    return (response['goals'] as List)
        .map((goal) => FinancialGoal.fromJson(goal))
        .toList();
  }

  Future<FinancialGoal> updateGoalProgress(int goalId, double amount) async {
    final response = await _apiClient.put(
        'finance/goal/$goalId/progress', {
      'amount': amount,
    });
    return FinancialGoal.fromJson(response['goal']);
  }

  Future<FinanceCategory> createCategory({
    required String name,
    required String type,
    String? icon,
  }) async {
    final response = await _apiClient.post('finance/category', {
      'name': name,
      'type': type,
      'icon': icon,
    });
    return FinanceCategory.fromJson(response['category']);
  }

  Future<List<FinanceCategory>> getCategories({String? type}) async {
    final queryParams = <String, dynamic>{};

    if (type != null) queryParams['type'] = type;

    final response = await _apiClient.get(
        'finance/categories', queryParams: queryParams);
    return (response['categories'] as List)
        .map((category) => FinanceCategory.fromJson(category))
        .toList();
  }

  Future<String> exportFinanceData({
    required String format,
    required String period,
    DateTime? startDate,
    DateTime? endDate,
    String type = 'all',
  }) async {
    final data = <String, dynamic>{
      'format': format,
      'period': period,
      'type': type,
    };

    if (startDate != null) {
      data['start_date'] = startDate
        .toIso8601String()
        .split('T')
        .first;
    }
    if (endDate != null) {
      data['end_date'] = endDate
        .toIso8601String()
        .split('T')
        .first;
    }

    final response = await _apiClient.post('finance/export', data);
    return response['file_url'];
  }

  Future<int> importFinanceData(String filePath) async {
    final response = await _apiClient.uploadFile(
        'finance/import', filePath);
    return response['imported_count'];
  }

  Future<Budget> updateBudget(int id, Budget budget) async {
    final response = await _apiClient.put(
      'finance/budget/$id',
      budget.toJson(),
    );
    return Budget.fromJson(response['budget']);
  }

  Future<FinanceCategory> updateCategory(
      int id, {
        required String name,
        required String type,
        String? icon,
      }) async {
    final response = await _apiClient.put('finance/category/$id', {
      'name': name,
      'type': type,
      'icon': icon,
    });
    return FinanceCategory.fromJson(response['category']);
  }

  Future<FinancialGoal> updateFinancialGoal(int id, FinancialGoal goal) async {
    final response = await _apiClient.put(
      'finance/goal/$id',
      goal.toJson(),
    );
    return FinancialGoal.fromJson(response['goal']);
  }

  Future<void> deleteCategory(int id) async {
    await _apiClient.delete('finance/category/$id');
  }
}