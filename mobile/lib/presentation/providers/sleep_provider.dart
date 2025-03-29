import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/repositories/sleep/sleep_repository.dart';

import '../../data/models/sleep/sleep.dart';
import '../../data/models/sleep/sleep_goal.dart';
import '../../data/models/sleep/sleep_statistics.dart';

final sleepProvider = ChangeNotifierProvider<SleepProvider>((ref) {
  throw UnimplementedError('sleepProvider was not initialized');
});

class SleepState {
  final List<Sleep>? sleepRecords;
  final SleepStatistics? statistics;
  final SleepTrend? trend;
  final List<SleepCorrelation>? correlations;
  final SleepGoal? goal;
  final SleepGoalProgress? goalProgress;
  final List<String>? recommendations;
  final bool isLoading;
  final String? error;

  SleepState({
    this.sleepRecords,
    this.statistics,
    this.trend,
    this.correlations,
    this.goal,
    this.goalProgress,
    this.recommendations,
    this.isLoading = false,
    this.error,
  });

  SleepState copyWith({
    List<Sleep>? sleepRecords,
    SleepStatistics? statistics,
    SleepTrend? trend,
    List<SleepCorrelation>? correlations,
    SleepGoal? goal,
    SleepGoalProgress? goalProgress,
    List<String>? recommendations,
    bool? isLoading,
    String? error,
  }) {
    return SleepState(
      sleepRecords: sleepRecords ?? this.sleepRecords,
      statistics: statistics ?? this.statistics,
      trend: trend ?? this.trend,
      correlations: correlations ?? this.correlations,
      goal: goal ?? this.goal,
      goalProgress: goalProgress ?? this.goalProgress,
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SleepProvider extends ChangeNotifier {
  final SleepRepository _sleepRepository;
  SleepState _state = SleepState(isLoading: true);

  SleepProvider(this._sleepRepository) {
    loadData();
  }

  SleepState get state => _state;

  List<Sleep>? get sleepRecords => _state.sleepRecords;
  SleepStatistics? get statistics => _state.statistics;
  SleepTrend? get trend => _state.trend;
  List<SleepCorrelation>? get correlations => _state.correlations;
  SleepGoal? get goal => _state.goal;
  SleepGoalProgress? get goalProgress => _state.goalProgress;
  List<String>? get recommendations => _state.recommendations;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;

  Future<void> loadData() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      await Future.wait([
        loadStatistics(),
        loadTrends(),
        loadCorrelations(),
        loadGoal(),
        loadGoalProgress(),
        loadRecommendations(),
      ]);

      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      notifyListeners();
    }
  }

  // Загрузка статистики сна
  Future<void> loadStatistics([String period = 'week']) async {
    try {
      final response = await _sleepRepository.getStatistics(period);
      if (response.success && response.data != null) {
        _state = _state.copyWith(statistics: response.data);
        notifyListeners();
      } else {
        _state = _state.copyWith(error: response.message);
        notifyListeners();
      }
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    }
  }

  // Загрузка тенденций сна
  Future<void> loadTrends([int months = 3]) async {
    try {
      final response = await _sleepRepository.getTrends(months);
      if (response.success && response.data != null) {
        _state = _state.copyWith(trend: response.data);
        notifyListeners();
      } else {
        _state = _state.copyWith(error: response.message);
        notifyListeners();
      }
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    }
  }

  // Загрузка корреляций сна
  Future<void> loadCorrelations() async {
    try {
      final response = await _sleepRepository.getSleepCorrelations();
      if (response.success && response.data != null) {
        _state = _state.copyWith(correlations: response.data);
        notifyListeners();
      } else {
        _state = _state.copyWith(error: response.message);
        notifyListeners();
      }
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    }
  }

  // Загрузка цели по сну
  Future<void> loadGoal() async {
    try {
      // Предполагаем, что у нас уже есть установленная цель
      final response = await _sleepRepository.getGoalsProgress();
      if (response.success && response.data != null) {
        // Здесь мы просто загружаем прогресс, но цель нужно получить отдельно
        // В реальном приложении вам может понадобиться дополнительный API-вызов
        notifyListeners();
      }
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    }
  }

  // Загрузка прогресса по целям сна
  Future<void> loadGoalProgress() async {
    try {
      final response = await _sleepRepository.getGoalsProgress();
      if (response.success && response.data != null) {
        _state = _state.copyWith(goalProgress: response.data);
        notifyListeners();
      } else {
        _state = _state.copyWith(error: response.message);
        notifyListeners();
      }
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    }
  }

  // Загрузка рекомендаций по сну
  Future<void> loadRecommendations() async {
    try {
      final response = await _sleepRepository.getRecommendations();
      if (response.success && response.data != null) {
        _state = _state.copyWith(recommendations: response.data);
        notifyListeners();
      } else {
        _state = _state.copyWith(error: response.message);
        notifyListeners();
      }
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
    }
  }

  // Запись данных о сне
  Future<bool> recordSleep(Sleep sleep) async {
    try {
      _state = _state.copyWith(isLoading: true, error: null);
      notifyListeners();

      final response = await _sleepRepository.recordSleep(sleep);
      if (response.success && response.data != null) {
        await loadData(); // Перезагружаем данные после успешной записи
        return true;
      } else {
        _state = _state.copyWith(
          isLoading: false,
          error: response.message,
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      notifyListeners();
      return false;
    }
  }

  // Установка цели по сну
  Future<bool> setSleepGoal(SleepGoal goal) async {
    try {
      _state = _state.copyWith(isLoading: true, error: null);
      notifyListeners();

      final response = await _sleepRepository.setSleepGoals(goal);
      if (response.success && response.data != null) {
        _state = _state.copyWith(
          goal: response.data,
          isLoading: false,
        );
        notifyListeners();
        return true;
      } else {
        _state = _state.copyWith(
          isLoading: false,
          error: response.message,
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> importDeviceData(String deviceType, Map<String, dynamic> data) async {
    try {
      _state = _state.copyWith(isLoading: true, error: null);
      notifyListeners();

      final response = await _sleepRepository.importDeviceData(deviceType, data);
      if (response.success) {
        await loadData();
        return true;
      } else {
        _state = _state.copyWith(
          isLoading: false,
          error: response.message,
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _state = _state.copyWith(error: null);
    notifyListeners();
  }
}
