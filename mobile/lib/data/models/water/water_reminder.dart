class WaterReminder {
  final int? id;
  final String startTime;
  final String endTime;
  final int intervalMinutes;
  final List<int> daysOfWeek;
  final bool isEnabled;
  final String? message;

  WaterReminder({
    this.id,
    required this.startTime,
    required this.endTime,
    required this.intervalMinutes,
    required this.daysOfWeek,
    this.isEnabled = true,
    this.message,
  });

  factory WaterReminder.fromJson(Map<String, dynamic> json) {
    List<int> days = [];
    if (json['days_of_week'] is List) {
      days = List<int>.from(json['days_of_week']);
    }

    return WaterReminder(
      id: json['id'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      intervalMinutes: json['interval_minutes'],
      daysOfWeek: days,
      isEnabled: json['is_enabled'] ?? true,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'start_time': startTime,
      'end_time': endTime,
      'interval_minutes': intervalMinutes,
      'days_of_week': daysOfWeek,
      'is_enabled': isEnabled,
    };

    if (id != null) {
      data['id'] = id;
    }

    if (message != null) {
      data['message'] = message;
    }

    return data;
  }

  WaterReminder copyWith({
    int? id,
    String? startTime,
    String? endTime,
    int? intervalMinutes,
    List<int>? daysOfWeek,
    bool? isEnabled,
    String? message,
  }) {
    return WaterReminder(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isEnabled: isEnabled ?? this.isEnabled,
      message: message ?? this.message,
    );
  }
}