class FinanceRecord {
  final int id;
  final double amount;
  final String type;
  final String period;
  final int categoryId;
  final String? categoryName;
  final DateTime date;
  final String? description;
  final bool isRecurring;
  final String? recurringFrequency;

  FinanceRecord({
    required this.id,
    required this.amount,
    required this.type,
    required this.period,
    required this.categoryId,
    this.categoryName,
    required this.date,
    this.description,
    required this.isRecurring,
    this.recurringFrequency,
  });

  factory FinanceRecord.fromJson(Map<String, dynamic> json) {
    return FinanceRecord(
      id: json['id'],
      amount: double.parse(json['amount'].toString()),
      type: json['type'],
      period: json['period'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      isRecurring: json['is_recurring'] ?? false,
      recurringFrequency: json['recurring_frequency'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'amount': amount,
      'type': type,
      'period': period,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'is_recurring': isRecurring,
    };

    if (description != null) map['description'] = description as Object;
    if (isRecurring && recurringFrequency != null) {
      map['recurring_frequency'] = recurringFrequency as Object;
    }

    return map;
  }
}
