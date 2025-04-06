class WeeklySummary {
  final String date;
  final Map<String, dynamic> goal;
  final Map<String, dynamic> total;
  final Map<String, dynamic> progress;

  WeeklySummary({
    required this.date,
    required this.goal,
    required this.total,
    required this.progress,
  });

  factory WeeklySummary.fromJson(Map<String, dynamic> json) {
    return WeeklySummary(
      date: json['date'],
      goal: json['goal'],
      total: {
        'calories': json['calories'],
        'protein': json['protein'],
        'fat': json['fat'],
        'carbohydrates': json['carbohydrates'],
      },
      progress: json['progress'],
    );
  }
}