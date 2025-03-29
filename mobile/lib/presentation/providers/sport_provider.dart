import 'package:flutter/material.dart';
import 'package:mobile/data/models/sport/sport.dart';
import 'package:mobile/data/models/sport/training_program.dart';
import 'package:mobile/data/models/sport/training_history.dart';
import 'package:mobile/data/repositories/sport/sport_repository.dart';

class SportState {
  final List<Sport>? allSports;
  final List<Sport>? userSports;
  final List<TrainingProgram>? userPrograms;
  final List<TrainingHistory>? trainingHistory;
  final TrainingProgram? currentProgram;
  final bool isLoading;
  final String? error;

  SportState({
    this.allSports,
    this.userSports,
    this.userPrograms,
    this.trainingHistory,
    this.currentProgram,
    this.isLoading = false,
    this.error,
  });

  SportState copyWith({
    List<Sport>? allSports,
    List<Sport>? userSports,
    List<TrainingProgram>? userPrograms,
    List<TrainingHistory>? trainingHistory,
    TrainingProgram? currentProgram,
    bool? isLoading,
    String? error,
  }) {
    return SportState(
      allSports: allSports ?? this.allSports,
      userSports: userSports ?? this.userSports,
      userPrograms: userPrograms ?? this.userPrograms,
      trainingHistory: trainingHistory ?? this.trainingHistory,
      currentProgram: currentProgram ?? this.currentProgram,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SportProvider extends ChangeNotifier {
  final SportRepository _sportRepository;
  SportState _state = SportState(isLoading: false);

  SportProvider(this._sportRepository) {
    loadInitialData();
  }

  SportState get state => _state;

  // Геттеры для удобного доступа к данным
  List<Sport>? get allSports => _state.allSports;
  List<Sport>? get userSports => _state.userSports;
  List<TrainingHistory>? get trainingHistory => _state.trainingHistory;
  TrainingProgram? get currentProgram => _state.currentProgram;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;

  // Загрузка начальных данных
  Future<void> loadInitialData() async {
    await Future.wait([
      loadSports(),
      loadUserSports(),
      loadTrainingHistory(),
    ]);
  }

  // Загрузка всех видов спорта
  Future<void> loadSports() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final response = await _sportRepository.getSportList();
      if (response.success && response.data != null) {
        _state = _state.copyWith(
          allSports: response.data,
          isLoading: false,
        );
      } else {
        _state = _state.copyWith(
          error: response.message ?? 'Не удалось загрузить виды спорта',
          isLoading: false,
        );
      }
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
    notifyListeners();
  }

  // Загрузка видов спорта пользователя
  Future<void> loadUserSports() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final response = await _sportRepository.getUserSportList();
      if (response.success && response.data != null) {
        _state = _state.copyWith(
          userSports: response.data,
          isLoading: false,
        );
      } else {
        _state = _state.copyWith(
          error: response.message ?? 'Не удалось загрузить виды спорта пользователя',
          isLoading: false,
        );
      }
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
    notifyListeners();
  }

  // Выбор вида спорта пользователем
  Future<bool> selectUserSport(int sportId) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final response = await _sportRepository.selectUserSport(sportId);
      if (response.success) {
        await loadUserSports(); // Перезагрузить список спортов пользователя
        return true;
      } else {
        _state = _state.copyWith(
          error: response.message ?? 'Не удалось выбрать вид спорта',
          isLoading: false,
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      notifyListeners();
      return false;
    }
  }

  // Получение базовой программы тренировок
  Future<Map<String, String>?> getBasicTrainingProgram(int sportId, String goal) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final response = await _sportRepository.getBasicTrainingProgram(sportId, goal);
      _state = _state.copyWith(isLoading: false);
      notifyListeners();

      if (response.success && response.data != null) {
        return {
          'message': response.data?['message'],
          'advice': response.data?['advice'],
        };
      } else {
        _state = _state.copyWith(
          error: response.message ?? 'Не удалось получить программу тренировок',
        );
        notifyListeners();
        return null;
      }
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      notifyListeners();
      return null;
    }
  }

  // Создание персональной программы тренировок
  Future<bool> createPersonalTrainingProgram(TrainingProgram program) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final response = await _sportRepository.createPersonalTrainingProgram(program);
      if (response.success && response.data != null) {
        _state = _state.copyWith(
          currentProgram: response.data,
          isLoading: false,
        );
        notifyListeners();
        return true;
      } else {
        _state = _state.copyWith(
          error: response.message ?? 'Не удалось создать программу тренировок',
          isLoading: false,
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      notifyListeners();
      return false;
    }
  }

  // Завершение тренировки
  Future<bool> completeTraining(int trainingProgramId, int duration, int caloriesBurned) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final response = await _sportRepository.completeTraining(
          trainingProgramId,
          duration,
          caloriesBurned
      );

      if (response.success) {
        await loadTrainingHistory(); // Перезагрузить историю тренировок
        return true;
      } else {
        _state = _state.copyWith(
          error: response.message ?? 'Не удалось завершить тренировку',
          isLoading: false,
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      notifyListeners();
      return false;
    }
  }

  // Загрузка программы тренировок по ID
  Future<void> loadTrainingProgramById(int id) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final response = await _sportRepository.getTrainingProgram(id);
      if (response.success && response.data != null) {
        _state = _state.copyWith(
          currentProgram: response.data,
          isLoading: false,
        );
      } else {
        _state = _state.copyWith(
          error: response.message ?? 'Не удалось загрузить программу тренировок',
          isLoading: false,
        );
      }
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
    notifyListeners();
  }

  // Загрузка истории тренировок
  Future<void> loadTrainingHistory() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final response = await _sportRepository.getTrainingHistory();
      if (response.success && response.data != null) {
        _state = _state.copyWith(
          trainingHistory: response.data,
          isLoading: false,
        );
      } else {
        _state = _state.copyWith(
          error: response.message ?? 'Не удалось загрузить историю тренировок',
          isLoading: false,
        );
      }
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
    notifyListeners();
  }

  // Удаление вида спорта пользователя
  Future<bool> deleteUserSport(int id) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final response = await _sportRepository.deleteUserSport(id);
      if (response.success) {
        await loadUserSports(); // Перезагрузить список спортов пользователя
        return true;
      } else {
        _state = _state.copyWith(
          error: response.message ?? 'Не удалось удалить вид спорта',
          isLoading: false,
        );
        notifyListeners();
        return false;
      }
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      notifyListeners();
      return false;
    }
  }
}