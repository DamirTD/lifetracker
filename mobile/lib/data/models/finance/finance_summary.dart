class FinanceSummary {
  final double totalIncome;
  final double totalExpense;
  final double totalSaving;
  final double totalInvestment;
  final double balance;
  final double? savingRate;
  final double? expenseRate;

  FinanceSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSaving,
    required this.totalInvestment,
    required this.balance,
    this.savingRate,
    this.expenseRate,
  });

  factory FinanceSummary.fromJson(Map<String, dynamic> json) {
    return FinanceSummary(
      totalIncome: (json['total_income'] ?? 0).toDouble(),
      totalExpense: (json['total_expense'] ?? 0).toDouble(),
      totalSaving: (json['total_saving'] ?? 0).toDouble(),
      totalInvestment: (json['total_investment'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      savingRate: json['saving_rate']?.toDouble(),
      expenseRate: json['expense_rate']?.toDouble(),
    );
  }
}