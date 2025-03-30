class WaterProgress {
  final DateTime date;
  final int dailyGoalMl;
  final int consumedMl;
  final int remainingMl;
  final int glassesToday;
  final int glassVolumeMl;
  final DateTime? lastAddedAt;
  final int percentComplete;

  WaterProgress({
    required this.date,
    required this.dailyGoalMl,
    required this.consumedMl,
    required this.remainingMl,
    required this.glassesToday,
    required this.glassVolumeMl,
    this.lastAddedAt,
    required this.percentComplete,
  });

  factory WaterProgress.fromJson(Map<String, dynamic> json) {
    return WaterProgress(
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      dailyGoalMl: json['daily_goal_ml'] ?? 0,
      consumedMl: json['consumed_ml'] ?? 0,
      remainingMl: json['remaining_ml'] ?? 0,
      glassesToday: json['glasses_today'] ?? 0,
      glassVolumeMl: json['glass_volume_ml'] ?? 250,
      lastAddedAt: json['last_added_at'] != null ? DateTime.parse(json['last_added_at']) : null,
      percentComplete: json['percent_complete'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'daily_goal_ml': dailyGoalMl,
      'consumed_ml': consumedMl,
      'remaining_ml': remainingMl,
      'glasses_today': glassesToday,
      'glass_volume_ml': glassVolumeMl,
      'last_added_at': lastAddedAt?.toIso8601String(),
      'percent_complete': percentComplete,
    };
  }
}