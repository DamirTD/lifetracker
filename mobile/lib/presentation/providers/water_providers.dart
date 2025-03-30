import 'package:flutter/foundation.dart';
import '../../data/models/water/water_progress.dart';
import '../../data/models/water/water_container.dart';
import '../../data/models/water/water_reminder.dart';
import '../../data/models/water/water_stats.dart';
import '../../data/models/water/water_eco_report.dart';
import '../../data/models/water/water_goal_settings.dart';
import '../../data/repositories/water/water_repository.dart';

class WaterProvider extends ChangeNotifier {
  final WaterRepository _repository;

  bool _isLoading = false;
  String? _error;
  WaterProgress? _dailyProgress;
  WaterStats? _overallStats;
  WaterEcoReport? _ecoReport;
  List<WaterContainer> _containers = [];
  List<WaterReminder> _reminders = [];
  Map<String, dynamic>? _weeklyData;
  Map<String, dynamic>? _monthlyData;
  Map<String, dynamic>? _insights;
  Map<String, dynamic>? _comparison;

  bool get isLoading => _isLoading;
  String? get error => _error;
  WaterProgress? get dailyProgress => _dailyProgress;
  WaterStats? get overallStats => _overallStats;
  WaterEcoReport? get ecoReport => _ecoReport;
  List<WaterContainer> get containers => _containers;
  List<WaterReminder> get reminders => _reminders;
  Map<String, dynamic>? get weeklyData => _weeklyData;
  Map<String, dynamic>? get monthlyData => _monthlyData;
  Map<String, dynamic>? get insights => _insights;
  Map<String, dynamic>? get comparison => _comparison;

  WaterProvider(this._repository) {
    loadDailyStats();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<WaterProgress?> loadDailyStats() async {
    _setLoading(true);
    _setError(null);

    try {
      _dailyProgress = await _repository.getDailyStats();
      notifyListeners();
      return _dailyProgress;
    } catch (e) {
      if (e.toString().contains('404') || e.toString().contains('Неизвестная ошибка')) {
        _dailyProgress = null;
        notifyListeners();
      } else {
        _setError(e.toString());
      }
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadOverallStats() async {
    _setLoading(true);
    _setError(null);

    try {
      _overallStats = await _repository.getOverallStats();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setDailyGoal(WaterGoalSettings settings) async {
    _setLoading(true);
    _setError(null);

    try {
      await _repository.setDailyGoal(settings);
      await loadDailyStats();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addGlass({int? containerId, int? volumeMl}) async {
    _setLoading(true);
    _setError(null);

    try {
      await _repository.addGlass(containerId: containerId, volumeMl: volumeMl);
      await loadDailyStats();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeGlass() async {
    _setLoading(true);
    _setError(null);

    try {
      await _repository.removeGlass();
      await loadDailyStats();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadContainers() async {
    _setLoading(true);
    _setError(null);

    try {
      _containers = await _repository.getContainers();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<WaterContainer?> saveContainer(WaterContainer container) async {
    _setLoading(true);
    _setError(null);

    try {
      final savedContainer = await _repository.saveContainer(container);
      await loadContainers();
      return savedContainer;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteContainer(int containerId) async {
    _setLoading(true);
    _setError(null);

    try {
      await _repository.deleteContainer(containerId);
      _containers.removeWhere((container) => container.id == containerId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadReminders() async {
    _setLoading(true);
    _setError(null);

    try {
      _reminders = await _repository.getReminders();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<WaterReminder?> saveReminder(WaterReminder reminder) async {
    _setLoading(true);
    _setError(null);

    try {
      final savedReminder = await _repository.setReminder(reminder);
      await loadReminders();
      return savedReminder;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteReminder(int reminderId) async {
    _setLoading(true);
    _setError(null);

    try {
      await _repository.deleteReminder(reminderId);
      _reminders.removeWhere((reminder) => reminder.id == reminderId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleReminder(int reminderId, bool isEnabled) async {
    _setLoading(true);
    _setError(null);

    try {
      await _repository.toggleReminder(reminderId, isEnabled);

      final index = _reminders.indexWhere((reminder) => reminder.id == reminderId);
      if (index != -1) {
        _reminders[index] = _reminders[index].copyWith(isEnabled: isEnabled);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadEcoReport() async {
    _setLoading(true);
    _setError(null);

    try {
      _ecoReport = await _repository.getEcoReport();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadWeeklyConsumption({String? startDate}) async {
    _setLoading(true);
    _setError(null);

    try {
      _weeklyData = await _repository.getWeeklyConsumption(startDate: startDate);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMonthlyConsumption({String? yearMonth}) async {
    _setLoading(true);
    _setError(null);

    try {
      _monthlyData = await _repository.getMonthlyConsumption(yearMonth: yearMonth);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> getHistory({
    String? startDate,
    String? endDate,
    int perPage = 10,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _repository.getHistory(
        startDate: startDate,
        endDate: endDate,
        perPage: perPage,
      );
      return result;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadInsights() async {
    _setLoading(true);
    _setError(null);

    try {
      _insights = await _repository.getInsights();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadComparison() async {
    _setLoading(true);
    _setError(null);

    try {
      _comparison = await _repository.getComparison();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}