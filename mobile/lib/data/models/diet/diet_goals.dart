class DietGoals {
  final int calories;
  final double protein;
  final double fat;
  final double carbohydrates;

  DietGoals({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
  });

  factory DietGoals.fromJson(Map<String, dynamic> json) {
    return DietGoals(
      calories: json['calories'],
      protein: json['protein'].toDouble(),
      fat: json['fat'].toDouble(),
      carbohydrates: json['carbohydrates'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbohydrates': carbohydrates,
    };
  }
}