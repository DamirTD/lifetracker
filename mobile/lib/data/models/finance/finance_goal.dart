class FinancialGoal {
  final int? id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String? description;
  final String priority;
  final String status;
  final double progress;
  final int? daysRemaining;
  final double? amountNeededPerDay;

  FinancialGoal({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    this.description,
    required this.priority,
    required this.status,
    required this.progress,
    this.daysRemaining,
    this.amountNeededPerDay,
  });

  factory FinancialGoal.fromJson(Map<String, dynamic> json) {
    return FinancialGoal(
      id: json['id'], // Allow null
      name: json['name'] ?? '',
      targetAmount: (json['target_amount'] ?? 0).toDouble(),
      currentAmount: (json['current_amount'] ?? 0).toDouble(),
      targetDate: json['target_date'] != null
          ? DateTime.parse(json['target_date'])
          : DateTime.now().add(const Duration(days: 30)),
      description: json['description'],
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'active',
      progress: (json['progress'] ?? 0).toDouble(),
      daysRemaining: json['days_remaining'],
      amountNeededPerDay: json['amount_needed_per_day']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'name': name,
      'target_amount': targetAmount,
      'target_date': targetDate.toIso8601String().split('T').first,
      'current_amount': currentAmount,
      'priority': priority,
      'status': status,
    };

    if (id != null) map['id'] = id as Object;
    if (description != null) map['description'] = description as Object;

    return map;
  }
}