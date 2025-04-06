class DietEntry {
  final int? id;
  final int foodId;
  final String foodName;
  final double quantity;
  final String date;
  final String mealType;
  final int calories;
  final double protein;
  final double fat;
  final double carbohydrates;

  DietEntry({
    this.id,
    required this.foodId,
    required this.foodName,
    required this.quantity,
    required this.date,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
  });

  factory DietEntry.fromJson(Map<String, dynamic> json) {
    return DietEntry(
      id: json['id'],
      foodId: json['food_id'],
      foodName: json['food_name'] ?? '',
      quantity: json['quantity'].toDouble(),
      date: json['date'],
      mealType: json['meal_type'],
      calories: json['calories'],
      protein: json['protein'].toDouble(),
      fat: json['fat'].toDouble(),
      carbohydrates: json['carbohydrates'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'food_id': foodId,
      'quantity': quantity,
      'date': date,
      'meal_type': mealType,
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  DietEntry copyWith({
    int? id,
    int? foodId,
    String? foodName,
    double? quantity,
    String? date,
    String? mealType,
    int? calories,
    double? protein,
    double? fat,
    double? carbohydrates,
  }) {
    return DietEntry(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      quantity: quantity ?? this.quantity,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbohydrates: carbohydrates ?? this.carbohydrates,
    );
  }
}