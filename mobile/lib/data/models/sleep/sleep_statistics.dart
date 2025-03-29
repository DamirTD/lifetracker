class SleepStatistics {
  final int averageDuration;
  final String averageQuality;
  final int longestSleep;
  final int shortestSleep;
  final int totalInterruptions;
  final double sleepEfficiency;
  final String mostCommonBedtime;
  final String bestSleepDay;

  SleepStatistics({
    required this.averageDuration,
    required this.averageQuality,
    required this.longestSleep,
    required this.shortestSleep,
    required this.totalInterruptions,
    required this.sleepEfficiency,
    required this.mostCommonBedtime,
    required this.bestSleepDay,
  });

  factory SleepStatistics.fromJson(Map<String, dynamic> json) {
    return SleepStatistics(
      averageDuration: json['average_duration'],
      averageQuality: json['average_quality'],
      longestSleep: json['longest_sleep'],
      shortestSleep: json['shortest_sleep'],
      totalInterruptions: json['total_interruptions'],
      sleepEfficiency: json['sleep_efficiency'].toDouble(),
      mostCommonBedtime: json['most_common_bedtime'],
      bestSleepDay: json['best_sleep_day'],
    );
  }

  String get averageDurationFormatted {
    final hours = averageDuration ~/ 60;
    final minutes = averageDuration % 60;
    return '$hoursч $minutesм';
  }

  String get longestSleepFormatted {
    final hours = longestSleep ~/ 60;
    final minutes = longestSleep % 60;
    return '$hoursч $minutesм';
  }

  String get shortestSleepFormatted {
    final hours = shortestSleep ~/ 60;
    final minutes = shortestSleep % 60;
    return '$hoursч $minutesм';
  }
}

class SleepTrend {
  final String durationTrend;
  final String qualityTrend;
  final String interruptionsTrend;
  final SleepTrendData trendData;
  final List<String> insights;

  SleepTrend({
    required this.durationTrend,
    required this.qualityTrend,
    required this.interruptionsTrend,
    required this.trendData,
    required this.insights,
  });

  factory SleepTrend.fromJson(Map<String, dynamic> json) {
    return SleepTrend(
      durationTrend: json['duration_trend'],
      qualityTrend: json['quality_trend'],
      interruptionsTrend: json['interruptions_trend'],
      trendData: SleepTrendData.fromJson(json['trend_data']),
      insights: List<String>.from(json['insights']),
    );
  }

  String get durationIcon {
    switch (durationTrend) {
      case 'increasing':
        return '↑';
      case 'decreasing':
        return '↓';
      case 'stable':
        return '→';
      default:
        return '?';
    }
  }

  String get qualityIcon {
    switch (qualityTrend) {
      case 'increasing':
        return '↑';
      case 'decreasing':
        return '↓';
      case 'stable':
        return '→';
      default:
        return '?';
    }
  }

  String get interruptionsIcon {
    switch (interruptionsTrend) {
      case 'increasing':
        return '↑';
      case 'decreasing':
        return '↓';
      case 'stable':
        return '→';
      default:
        return '?';
    }
  }
}

class SleepTrendData {
  final List<String> labels;
  final List<int> duration;
  final List<double> qualityScore;
  final List<double> interruptions;

  SleepTrendData({
    required this.labels,
    required this.duration,
    required this.qualityScore,
    required this.interruptions,
  });

  factory SleepTrendData.fromJson(Map<String, dynamic> json) {
    return SleepTrendData(
      labels: List<String>.from(json['labels']),
      duration: List<int>.from(json['duration']),
      qualityScore: List<double>.from(json['quality_score'].map((x) => x.toDouble())),
      interruptions: List<double>.from(json['interruptions'].map((x) => x.toDouble())),
    );
  }
}

class SleepCorrelation {
  final String factor;
  final double correlation;
  final String impact;
  final String description;

  SleepCorrelation({
    required this.factor,
    required this.correlation,
    required this.impact,
    required this.description,
  });

  factory SleepCorrelation.fromJson(Map<String, dynamic> json) {
    return SleepCorrelation(
      factor: json['factor'],
      correlation: json['correlation'].toDouble(),
      impact: json['impact'],
      description: json['description'],
    );
  }

  String get impactColor {
    switch (impact) {
      case 'positive':
        return '#4CAF50';
      case 'negative':
        return '#F44336';
      default:
        return '#9E9E9E';
    }
  }

  int get correlationPercentage {
    return (correlation.abs() * 100).round();
  }
}