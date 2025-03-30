class WaterEcoReport {
  final int bottlesSaved;
  final int plasticSavedG;
  final int co2SavedG;
  final int waterSavedL;
  final double treesEquivalent;

  WaterEcoReport({
    required this.bottlesSaved,
    required this.plasticSavedG,
    required this.co2SavedG,
    required this.waterSavedL,
    required this.treesEquivalent,
  });

  factory WaterEcoReport.fromJson(Map<String, dynamic> json) {
    return WaterEcoReport(
      bottlesSaved: json['bottles_saved'] ?? 0,
      plasticSavedG: json['plastic_saved_g'] ?? 0,
      co2SavedG: json['co2_saved_g'] ?? 0,
      waterSavedL: json['water_saved_l'] ?? 0,
      treesEquivalent: (json['trees_equivalent'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bottles_saved': bottlesSaved,
      'plastic_saved_g': plasticSavedG,
      'co2_saved_g': co2SavedG,
      'water_saved_l': waterSavedL,
      'trees_equivalent': treesEquivalent,
    };
  }
}