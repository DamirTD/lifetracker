import 'package:flutter/foundation.dart';

import '../../data/models/finance/finance_budget.dart';
import '../../data/models/finance/finance_calculation.dart';
import '../../data/models/finance/finance_category.dart';
import '../../data/models/finance/finance_goal.dart';
import '../../data/models/finance/finance_record.dart';
import '../../data/models/finance/finance_summary.dart';
import '../../data/models/finance/financial_advice.dart';
import '../../data/repositories/finance/finance_repository.dart';

class FinanceProvider extends ChangeNotifier {
  final FinanceRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<FinanceRecord> _records = [];
  FinanceSummary? _summary;
  List<Budget> _budgets = [];
  List<FinancialGoal> _goals = [];
  List<FinanceCategory> _categories = [];
  List<FinancialAdvice> _advice = [];
  FinanceCalculation? _calculation;
  Map<String, dynamic>? _statistics;
  Map<String, dynamic>? _pagination;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<FinanceRecord> get records => _records;
  FinanceSummary? get summary => _summary;
  List<Budget> get budgets => _budgets;
  List<FinancialGoal> get goals => _goals;
  List<FinanceCategory> get categories => _categories;
  List<FinancialAdvice> get advice => _advice;
  FinanceCalculation? get calculation => _calculation;
  Map<String, dynamic>? get statistics => _statistics;
  Map<String, dynamic>? get pagination => _pagination;

  FinanceProvider(this._repository);

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> calculateFinance(double salary, String rule) async {
    _setLoading(true);
    _setError(null);

    try {
      _calculation = await _repository.calculateFinance(salary, rule);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getFinancialAdvice() async {
    _setLoading(true);
    _setError(null);

    try {
      _advice = await _repository.getFinancialAdvice();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<FinanceRecord?> createFinanceRecord(Map<String, dynamic> data) async {
    _setLoading(true);
    _setError(null);

    try {
      final newRecord = await _repository.createFinanceRecord(data);
      _records.add(newRecord);
      notifyListeners();
      return newRecord;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getFinanceRecords({
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
    _setLoading(true);
    _setError(null);

    try {
      final result = await _repository.getFinanceRecords(
        period: period,
        type: type,
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
        sortBy: sortBy,
        sortDirection: sortDirection,
        page: page,
        perPage: perPage,
      );

      _records = result['records'];
      _summary = result['summary'];
      _pagination = result['pagination'];
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<FinanceRecord?> updateFinanceRecord(
    int id,
    Map<String, dynamic> data,
  ) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedRecord = await _repository.updateFinanceRecord(id, data);
      final index = _records.indexWhere((r) => r.id == id);
      if (index != -1) {
        _records[index] = updatedRecord;
        notifyListeners();
      }
      return updatedRecord;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteFinanceRecord(int id) async {
    _setLoading(true);
    _setError(null);

    try {
      await _repository.deleteFinanceRecord(id);

      _records.removeWhere((record) => record.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getFinanceStatistics({
    String period = 'month',
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    String groupBy = 'day',
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      _statistics = await _repository.getFinanceStatistics(
        period: period,
        type: type,
        startDate: startDate,
        endDate: endDate,
        groupBy: groupBy,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<Budget?> createBudget(Budget budget) async {
    _setLoading(true);
    _setError(null);

    try {
      final newBudget = await _repository.createBudget(budget);
      _budgets.add(newBudget);
      notifyListeners();
      return newBudget;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getBudgets({String? period, int? categoryId}) async {
    _setLoading(true);
    _setError(null);

    try {
      _budgets = await _repository.getBudgets(
        period: period,
        categoryId: categoryId,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<FinancialGoal?> createFinancialGoal(FinancialGoal goal) async {
    _setLoading(true);
    _setError(null);

    try {
      final newGoal = await _repository.createFinancialGoal(goal);
      _goals.add(newGoal);
      notifyListeners();
      return newGoal;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getFinancialGoals({
    String status = 'active',
    String? priority,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      _goals = await _repository.getFinancialGoals(
        status: status,
        priority: priority,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<FinancialGoal?> updateGoalProgress(int goalId, double amount) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedGoal = await _repository.updateGoalProgress(goalId, amount);

      final index = _goals.indexWhere((goal) => goal.id == goalId);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
      }

      return updatedGoal;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<FinanceCategory?> createCategory({
    required String name,
    required String type,
    String? icon,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final newCategory = await _repository.createCategory(
        name: name,
        type: type,
        icon: icon,
      );
      _categories.add(newCategory);
      notifyListeners();
      return newCategory;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getCategories({String? type}) async {
    _setLoading(true);
    _setError(null);

    try {
      _categories = await _repository.getCategories(type: type);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> exportFinanceData({
    required String format,
    required String period,
    DateTime? startDate,
    DateTime? endDate,
    String type = 'all',
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final fileUrl = await _repository.exportFinanceData(
        format: format,
        period: period,
        startDate: startDate,
        endDate: endDate,
        type: type,
      );
      return fileUrl;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Budget?> updateBudget(int id, Budget budget) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedBudget = await _repository.updateBudget(id, budget);

      final index = _budgets.indexWhere((b) => b.id == id);
      if (index != -1) {
        _budgets[index] = updatedBudget;
        notifyListeners();
      }

      return updatedBudget;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<FinanceCategory?> updateCategory(
    int id, {
    required String name,
    required String type,
    String? icon,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedCategory = await _repository.updateCategory(
        id,
        name: name,
        type: type,
        icon: icon,
      );

      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _categories[index] = updatedCategory;
        notifyListeners();
      }

      return updatedCategory;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<FinancialGoal?> updateFinancialGoal(int id, FinancialGoal goal) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedGoal = await _repository.updateFinancialGoal(id, goal);

      final index = _goals.indexWhere((g) => g.id == id);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
      }

      return updatedGoal;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCategory(int id) async {
    _setLoading(true);
    _setError(null);

    try {
      await _repository.deleteCategory(id);

      _categories.removeWhere((category) => category.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<int?> importFinanceData(String filePath) async {
    _setLoading(true);
    _setError(null);

    try {
      final importedCount = await _repository.importFinanceData(filePath);
      return importedCount;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }
}
