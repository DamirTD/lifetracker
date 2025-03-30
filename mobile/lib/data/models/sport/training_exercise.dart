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
    final Map<String, dynamic> data = {
      'name': name,
      'reps': reps,
    };

    if (videoUrl != null) {
      data['video_url'] = videoUrl;
    }

    return data;
  }
}