// lib/presentation/providers/diet_provider.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/diet/daily_diet.dart';
import 'package:mobile/data/models/diet/diet_entry.dart';
import 'package:mobile/data/models/diet/diet_goals.dart';
import 'package:mobile/data/models/diet/food.dart';
import 'package:mobile/data/models/diet/weekly_summary.dart';
import 'package:mobile/data/repositories/diet/diet_repository.dart';

class DietState {
  final DailyDiet? dailyDiet;
  final List<WeeklySummary>? weeklySummaries;
  final List<Food>? foodsList;
  final DietGoals? dietGoals;
  final bool isLoading;
  final String? error;

  DietState({
    this.dailyDiet,
    this.weeklySummaries,
    this.foodsList,
    this.dietGoals,
    this.isLoading = false,
    this.error,
  });

  DietState copyWith({
    DailyDiet? dailyDiet,
    List<WeeklySummary>? weeklySummaries,
    List<Food>? foodsList,
    DietGoals? dietGoals,
    bool? isLoading,
    String? error,
  }) {
    return DietState(
      dailyDiet: dailyDiet ?? this.dailyDiet,
      weeklySummaries: weeklySummaries ?? this.weeklySummaries,
      foodsList: foodsList ?? this.foodsList,
      dietGoals: dietGoals ?? this.dietGoals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DietProvider extends ChangeNotifier {
  final DietRepository _dietRepository;
  DietState _state = DietState(isLoading: true);
  String _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  DietProvider(this._dietRepository) {
    loadInitialData();
  }

  DietState get state => _state;
  String get currentDate => _currentDate;

  // Геттеры для удобного доступа к данным
  DailyDiet? get dailyDiet => _state.dailyDiet;
  List<WeeklySummary>? get weeklySummaries => _state.weeklySummaries;
  List<Food>? get foodsList => _state.foodsList;
  DietGoals? get dietGoals => _state.dietGoals;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;

  void setDate(String date) {
    _currentDate = date;
    loadDailyDiet();
  }

  Future<void> loadInitialData() async {
    await Future.wait([
      loadDailyDiet(),
      loadWeeklyDiet(),
      loadFoods(),
      loadDietGoals(),
    ]);
  }

  Future<void> loadDailyDiet() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final dailyDiet = await _dietRepository.getDailyDiet(_currentDate);
      _state = _state.copyWith(
        dailyDiet: dailyDiet,
        isLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
    notifyListeners();
  }

  Future<void> loadWeeklyDiet() async {
    try {
      final weeklySummaries = await _dietRepository.getWeeklyDiet();
      _state = _state.copyWith(
        weeklySummaries: weeklySummaries,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> loadFoods({String? search}) async {
    try {
      final foodsList = await _dietRepository.getFoods(search: search);
      _state = _state.copyWith(
        foodsList: foodsList,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> loadDietGoals() async {
    try {
      final dietGoals = await _dietRepository.getDietGoals();
      _state = _state.copyWith(
        dietGoals: dietGoals,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
      );
      notifyListeners();
    }
  }

  Future<bool> addFood(DietEntry entry) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      await _dietRepository.addFood(entry);
      await loadDailyDiet();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateFood(int id, Map<String, dynamic> data) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      await _dietRepository.updateFood(id, data);
      await loadDailyDiet();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteFood(int id) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      await _dietRepository.deleteFood(id);
      await loadDailyDiet();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDietGoals(DietGoals goals) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final updatedGoals = await _dietRepository.updateDietGoals(goals);
      _state = _state.copyWith(
        dietGoals: updatedGoals,
        isLoading: false,
      );
      await loadDailyDiet(); // Обновить данные с новыми целями
      return true;
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _state = _state.copyWith(error: null);
    notifyListeners();
  }

  Future<Map<String, dynamic>> loadStatisticsForPeriod(String period) async {
    try {
      final statistics = await _dietRepository.getStatistics(period);
      return statistics;
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
      );
      notifyListeners();
      rethrow;
    }
  }
}