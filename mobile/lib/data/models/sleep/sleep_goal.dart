class SleepGoal {
  final int? id;
  final int? userId;
  final int targetHours;
  final String targetBedtime;
  final String targetWakeTime;
  final int maxInterruptions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SleepGoal({
    this.id,
    this.userId,
    required this.targetHours,
    required this.targetBedtime,
    required this.targetWakeTime,
    this.maxInterruptions = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory SleepGoal.fromJson(Map<String, dynamic> json) {
    return SleepGoal(
      id: json['id'],
      userId: json['user_id'],
      targetHours: json['target_hours'],
      targetBedtime: json['target_bedtime'],
      targetWakeTime: json['target_wake_time'],
      maxInterruptions: json['max_interruptions'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'target_hours': targetHours,
      'target_bedtime': targetBedtime,
      'target_wake_time': targetWakeTime,
      'max_interruptions': maxInterruptions,
    };
  }
}

class SleepGoalProgress {
  final int hoursProgress;
  final int bedtimeAdherence;
  final int wakeTimeAdherence;
  final int interruptionsSuccess;
  final int overallProgress;
  final int streak;

  SleepGoalProgress({
    required this.hoursProgress,
    required this.bedtimeAdherence,
    required this.wakeTimeAdherence,
    required this.interruptionsSuccess,
    required this.overallProgress,
    required this.streak,
  });

  factory SleepGoalProgress.fromJson(Map<String, dynamic> json) {
    return SleepGoalProgress(
      hoursProgress: json['hours_progress'],
      bedtimeAdherence: json['bedtime_adherence'],
      wakeTimeAdherence: json['wake_time_adherence'],
      interruptionsSuccess: json['interruptions_success'],
      overallProgress: json['overall_progress'],
      streak: json['streak'],
    );
  }
}