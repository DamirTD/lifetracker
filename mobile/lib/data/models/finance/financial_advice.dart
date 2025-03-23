class FinancialAdvice {
  final String title;
  final String description;
  final String type;

  FinancialAdvice({
    required this.title,
    required this.description,
    required this.type,
  });

  factory FinancialAdvice.fromJson(Map<String, dynamic> json) {
    return FinancialAdvice(
      title: json['title'],
      description: json['description'],
      type: json['type'],
    );
  }
}