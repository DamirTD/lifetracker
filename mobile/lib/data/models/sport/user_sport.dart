import 'sport.dart';

class UserSport {
  final int id;
  final int userId;
  final int sportId;
  final Sport? sport;

  UserSport({
    required this.id,
    required this.userId,
    required this.sportId,
    this.sport,
  });

  factory UserSport.fromJson(Map<String, dynamic> json) {
    return UserSport(
      id: json['id'],
      userId: json['user_id'],
      sportId: json['sport_id'],
      sport: json['sport'] != null ? Sport.fromJson(json['sport']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'sport_id': sportId,
    };
  }
}