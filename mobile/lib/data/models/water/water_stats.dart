class WaterStats {
  final int totalMl;
  final int totalDays;
  final int daysReachedGoal;
  final int successRate;
  final int averageDailyMl;
  final int currentStreak;
  final int bestStreak;

  WaterStats({
    required this.totalMl,
    required this.totalDays,
    required this.daysReachedGoal,
    required this.successRate,
    required this.averageDailyMl,
    required this.currentStreak,
    required this.bestStreak,
  });

  factory WaterStats.fromJson(Map<String, dynamic> json) {
    return WaterStats(
      totalMl: json['total_ml'] ?? 0,
      totalDays: json['total_days'] ?? 0,
      daysReachedGoal: json['days_reached_goal'] ?? 0,
      successRate: json['success_rate'] ?? 0,
      averageDailyMl: json['average_daily_ml'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      bestStreak: json['best_streak'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_ml': totalMl,
      'total_days': totalDays,
      'days_reached_goal': daysReachedGoal,
      'success_rate': successRate,
      'average_daily_ml': averageDailyMl,
      'current_streak': currentStreak,
      'best_streak': bestStreak,
    };
  }
}