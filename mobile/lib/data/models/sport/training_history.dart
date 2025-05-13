import 'package:mobile/data/models/sport/training_program.dart';

class TrainingHistory {
  final int id;
  final int userId;
  final int trainingProgramId;
  final int duration;
  final int? caloriesBurned;
  final double? weightBefore;
  final double? weightAfter;
  final DateTime createdAt;
  final TrainingProgram? trainingProgram;

  TrainingHistory({
    required this.id,
    required this.userId,
    required this.trainingProgramId,
    required this.duration,
    this.caloriesBurned,
    this.weightBefore,
    this.weightAfter,
    required this.createdAt,
    this.trainingProgram,
  });

  factory TrainingHistory.fromJson(Map<String, dynamic> json) {
    return TrainingHistory(
      id: json['id'],
      userId: json['user_id'],
      trainingProgramId: json['training_program_id'],
      duration: json['duration'],
      caloriesBurned: json['calories_burned'],
      weightBefore: (json['weight_before'] as num?)?.toDouble(),
      weightAfter: (json['weight_after'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      trainingProgram:
          json['program'] != null
              ? TrainingProgram.fromJson(json['program'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'training_program_id': trainingProgramId,
      'duration': duration,
      'calories_burned': caloriesBurned,
      'weight_before': weightBefore,
      'weight_after': weightAfter,
    };
  }
}
