import 'package:intl/intl.dart';

class Sleep {
  final int? id;
  final int? userId;
  final String bedtime;
  final String wakeUpTime;
  final List<SleepInterruption>? interruptions;
  final String? moodOnWaking;
  final SleepEnvironment? sleepEnvironment;
  final int duration;
  final String quality;
  final Map<String, dynamic>? deviceData;
  final DateTime? createdAt;

  Sleep({
    this.id,
    this.userId,
    required this.bedtime,
    required this.wakeUpTime,
    this.interruptions,
    this.moodOnWaking,
    this.sleepEnvironment,
    required this.duration,
    required this.quality,
    this.deviceData,
    this.createdAt,
  });

  factory Sleep.fromJson(Map<String, dynamic> json) {
    List<SleepInterruption>? interruptionsList;
    if (json['interruptions'] != null) {
      interruptionsList = List<SleepInterruption>.from(
        json['interruptions'].map((x) => SleepInterruption.fromJson(x)),
      );
    }

    SleepEnvironment? environment;
    if (json['sleep_environment'] != null) {
      environment = SleepEnvironment.fromJson(json['sleep_environment']);
    }

    DateTime? createdAt;
    if (json['created_at'] != null) {
      createdAt = DateTime.parse(json['created_at']);
    }

    return Sleep(
      id: json['id'],
      userId: json['user_id'],
      bedtime: json['bedtime'],
      wakeUpTime: json['wake_up_time'],
      interruptions: interruptionsList,
      moodOnWaking: json['mood_on_waking'],
      sleepEnvironment: environment,
      duration: json['duration'],
      quality: json['quality'],
      deviceData: json['device_data'],
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bedtime': bedtime,
      'wake_up_time': wakeUpTime,
      'interruptions': interruptions?.map((i) => i.toJson()).toList(),
      'mood_on_waking': moodOnWaking,
      'sleep_environment': sleepEnvironment?.toJson(),
    };
  }

  // Получение длительности сна в формате часов и минут
  String get durationFormatted {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    return '$hoursч $minutesм';
  }

  // Дата записи в формате "дд.мм.гггг"
  String get dateFormatted {
    if (createdAt == null) return '';
    return DateFormat('dd.MM.yyyy').format(createdAt!);
  }
}

class SleepInterruption {
  final String time;
  final String reason;

  SleepInterruption({
    required this.time,
    required this.reason,
  });

  factory SleepInterruption.fromJson(Map<String, dynamic> json) {
    return SleepInterruption(
      time: json['time'],
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'reason': reason,
    };
  }
}

class SleepEnvironment {
  final double? temperature;
  final String? noiseLevel;
  final String? lightLevel;

  SleepEnvironment({
    this.temperature,
    this.noiseLevel,
    this.lightLevel,
  });

  factory SleepEnvironment.fromJson(Map<String, dynamic> json) {
    return SleepEnvironment(
      temperature: json['temperature']?.toDouble(),
      noiseLevel: json['noise_level'],
      lightLevel: json['light_level'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'noise_level': noiseLevel,
      'light_level': lightLevel,
    };
  }
}