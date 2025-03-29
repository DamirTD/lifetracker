import 'training_program.dart';

class TrainingHistory {
  final int id;
  final int userId;
  final int trainingProgramId;
  final int duration;
  final int caloriesBurned;
  final DateTime createdAt;
  final TrainingProgram? trainingProgram;

  TrainingHistory({
    required this.id,
    required this.userId,
    required this.trainingProgramId,
    required this.duration,
    required this.caloriesBurned,
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
      createdAt: DateTime.parse(json['created_at']),
      trainingProgram: json['program'] != null
          ? TrainingProgram.fromJson(json['program'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'training_program_id': trainingProgramId,
      'duration': duration,
      'calories_burned': caloriesBurned,
    };
  }
}