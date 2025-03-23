class FinanceCalculation {
  final double essentials;
  final double wants;
  final double savings;
  final List<String> advice;

  FinanceCalculation({
    required this.essentials,
    required this.wants,
    required this.savings,
    required this.advice,
  });

  factory FinanceCalculation.fromJson(Map<String, dynamic> json) {
    return FinanceCalculation(
      essentials: json['essentials'].toDouble(),
      wants: json['wants'].toDouble(),
      savings: json['savings'].toDouble(),
      advice: (json['advice'] as List).map((e) => e.toString()).toList(),
    );
  }
}