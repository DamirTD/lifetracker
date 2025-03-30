import 'training_exercise.dart';

class TrainingSection {
  final int? id;
  final String name;
  final List<TrainingExercise> exercises;

  TrainingSection({
    this.id,
    required this.name,
    required this.exercises,
  });

  factory TrainingSection.fromJson(Map<String, dynamic> json) {
    List<TrainingExercise> exercisesList = [];

    if (json['exercises'] != null) {
      exercisesList = List<TrainingExercise>.from(
        json['exercises'].map((x) => TrainingExercise.fromJson(x)),
      );
    }

    return TrainingSection(
      id: json['id'],
      name: json['name'],
      exercises: exercisesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
    };
  }
}