class Budget {
  final int id;
  final int categoryId;
  final String? categoryName;
  final double amount;
  final double spent;
  final double remaining;
  final double percentageUsed;
  final String period;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? notes;

  Budget({
    required this.id,
    required this.categoryId,
    this.categoryName,
    required this.amount,
    required this.spent,
    required this.remaining,
    required this.percentageUsed,
    required this.period,
    this.startDate,
    this.endDate,
    this.notes,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      spent: (json['spent'] ?? 0.0).toDouble(),
      remaining: (json['remaining'] ?? 0.0).toDouble(),
      percentageUsed: (json['percentage_used'] ?? 0.0).toDouble(),
      period: json['period'] ?? 'month',
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'amount': amount,
      'period': period,
      'start_date': startDate?.toIso8601String().split('T').first,
      'end_date': endDate?.toIso8601String().split('T').first,
      'notes': notes,
    };
  }
}