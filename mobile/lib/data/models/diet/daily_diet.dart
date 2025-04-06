import 'diet_entry.dart';

class DailyDiet {
  final String date;
  final Map<String, dynamic> goal;
  final Map<String, dynamic> total;
  final Map<String, dynamic> remaining;
  final Map<String, dynamic> progress;
  final List<DietEntry> entries;

  DailyDiet({
    required this.date,
    required this.goal,
    required this.total,
    required this.remaining,
    required this.progress,
    required this.entries,
  });

  factory DailyDiet.fromJson(Map<String, dynamic> json) {
    return DailyDiet(
      date: json['date'],
      goal: json['goal'],
      total: json['total'],
      remaining: json['remaining'],
      progress: json['progress'],
      entries: (json['entries'] as List)
          .map((entry) => DietEntry.fromJson(entry))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'goal': goal,
      'total': total,
      'remaining': remaining,
      'progress': progress,
      'entries': entries.map((entry) => entry.toJson()).toList(),
    };
  }
}