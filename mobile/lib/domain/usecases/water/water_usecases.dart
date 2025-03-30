
import '../../../data/models/water/water_container.dart';
import '../../../data/models/water/water_eco_report.dart';
import '../../../data/models/water/water_goal_settings.dart';
import '../../../data/models/water/water_progress.dart';
import '../../../data/models/water/water_reminder.dart';
import '../../../data/models/water/water_stats.dart';
import '../../../data/repositories/water/water_repository.dart';

class SetDailyGoalUseCase {
  final WaterRepository repository;

  SetDailyGoalUseCase(this.repository);

  Future<Map<String, dynamic>> execute(WaterGoalSettings settings) {
    return repository.setDailyGoal(settings);
  }
}

class AddGlassUseCase {
  final WaterRepository repository;

  AddGlassUseCase(this.repository);

  Future<Map<String, dynamic>> execute({int? containerId, int? volumeMl}) {
    return repository.addGlass(containerId: containerId, volumeMl: volumeMl);
  }
}

class RemoveGlassUseCase {
  final WaterRepository repository;

  RemoveGlassUseCase(this.repository);

  Future<Map<String, dynamic>> execute() {
    return repository.removeGlass();
  }
}

class GetDailyStatsUseCase {
  final WaterRepository repository;

  GetDailyStatsUseCase(this.repository);

  Future<WaterProgress> execute() {
    return repository.getDailyStats();
  }
}

class GetOverallStatsUseCase {
  final WaterRepository repository;

  GetOverallStatsUseCase(this.repository);

  Future<WaterStats> execute() {
    return repository.getOverallStats();
  }
}

class GetEcoReportUseCase {
  final WaterRepository repository;

  GetEcoReportUseCase(this.repository);

  Future<WaterEcoReport> execute() {
    return repository.getEcoReport();
  }
}

class GetContainersUseCase {
  final WaterRepository repository;

  GetContainersUseCase(this.repository);

  Future<List<WaterContainer>> execute() {
    return repository.getContainers();
  }
}

class SaveContainerUseCase {
  final WaterRepository repository;

  SaveContainerUseCase(this.repository);

  Future<WaterContainer> execute(WaterContainer container) {
    return repository.saveContainer(container);
  }
}

class DeleteContainerUseCase {
  final WaterRepository repository;

  DeleteContainerUseCase(this.repository);

  Future<void> execute(int containerId) {
    return repository.deleteContainer(containerId);
  }
}

class GetRemindersUseCase {
  final WaterRepository repository;

  GetRemindersUseCase(this.repository);

  Future<List<WaterReminder>> execute() {
    return repository.getReminders();
  }
}

class SaveReminderUseCase {
  final WaterRepository repository;

  SaveReminderUseCase(this.repository);

  Future<WaterReminder> execute(WaterReminder reminder) {
    return repository.setReminder(reminder);
  }
}

class DeleteReminderUseCase {
  final WaterRepository repository;

  DeleteReminderUseCase(this.repository);

  Future<void> execute(int reminderId) {
    return repository.deleteReminder(reminderId);
  }
}

class ToggleReminderUseCase {
  final WaterRepository repository;

  ToggleReminderUseCase(this.repository);

  Future<void> execute(int reminderId, bool isEnabled) {
    return repository.toggleReminder(reminderId, isEnabled);
  }
}

class GetWeeklyConsumptionUseCase {
  final WaterRepository repository;

  GetWeeklyConsumptionUseCase(this.repository);

  Future<Map<String, dynamic>> execute({String? startDate}) {
    return repository.getWeeklyConsumption(startDate: startDate);
  }
}

class GetMonthlyConsumptionUseCase {
  final WaterRepository repository;

  GetMonthlyConsumptionUseCase(this.repository);

  Future<Map<String, dynamic>> execute({String? yearMonth}) {
    return repository.getMonthlyConsumption(yearMonth: yearMonth);
  }
}

class GetWaterInsightsUseCase {
  final WaterRepository repository;

  GetWaterInsightsUseCase(this.repository);

  Future<Map<String, dynamic>> execute() {
    return repository.getInsights();
  }
}