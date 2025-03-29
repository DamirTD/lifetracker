import 'sport.dart';
import 'training_section.dart';

class TrainingProgram {
  final int? id;
  final int? userId;
  final int sportId;
  final String goal;
  final String name;
  final String? recommendation;
  final Sport? sport;
  final List<TrainingSection>? sections;

  TrainingProgram({
    this.id,
    this.userId,
    required this.sportId,
    required this.goal,
    required this.name,
    this.recommendation,
    this.sport,
    this.sections,
  });

  factory TrainingProgram.fromJson(Map<String, dynamic> json) {
    List<TrainingSection>? sectionsList;

    if (json['sections'] != null) {
      sectionsList = List<TrainingSection>.from(
        json['sections'].map((x) => TrainingSection.fromJson(x)),
      );
    }

    return TrainingProgram(
      id: json['id'],
      userId: json['user_id'],
      sportId: json['sport_id'],
      goal: json['goal'],
      name: json['name'],
      recommendation: json['recommendation'],
      sport: json['sport'] != null ? Sport.fromJson(json['sport']) : null,
      sections: sectionsList,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'sport_id': sportId,
      'goal': goal,
      'name': name,
    };

    if (recommendation != null) {
      data['recommendation'] = recommendation;
    }

    if (sections != null) {
      data['sections'] = sections!.map((section) => section.toJson()).toList();
    }

    return data;
  }
}