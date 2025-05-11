class TrainingExercise {
  final int? id;
  final String name;
  final int reps;
  final String? videoUrl;

  TrainingExercise({
    this.id,
    required this.name,
    required this.reps,
    this.videoUrl,
  });

  factory TrainingExercise.fromJson(Map<String, dynamic> json) {
    return TrainingExercise(
      id: json['id'],
      name: json['name'],
      reps: json['reps'],
      videoUrl: json['video_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'reps': reps,
      'video_url':
          (videoUrl != null && videoUrl!.trim().isNotEmpty) ? videoUrl : null,
    };
  }
}
