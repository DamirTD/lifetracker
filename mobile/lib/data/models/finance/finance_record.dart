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
      id: json['id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? 'expense',
      period: json['period'] ?? 'month',
      categoryId: json['category_id'] ?? 0, // Default to 0 if null
      categoryName: json['category_name'],
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      description: json['description'],
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