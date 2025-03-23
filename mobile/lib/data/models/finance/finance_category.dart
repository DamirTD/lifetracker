class FinanceCategory {
  final int id;
  final String name;
  final String type;
  final String? icon;
  final String? color;

  FinanceCategory({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
  });

  factory FinanceCategory.fromJson(Map<String, dynamic> json) {
    return FinanceCategory(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      icon: json['icon'],
      color: json['color'],
    );
  }
}