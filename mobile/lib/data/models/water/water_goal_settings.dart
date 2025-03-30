class WaterGoalSettings {
  final int weight;
  final int height;
  final int glassVolumeMl;

  WaterGoalSettings({
    required this.weight,
    required this.height,
    required this.glassVolumeMl,
  });

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'height': height,
      'glass_volume_ml': glassVolumeMl,
    };
  }
}