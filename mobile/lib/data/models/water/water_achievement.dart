class WaterAchievement {
  final String id;
  final String name;
  final String description;
  final String icon;

  WaterAchievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  factory WaterAchievement.fromJson(Map<String, dynamic> json) {
    return WaterAchievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
    };
  }
}