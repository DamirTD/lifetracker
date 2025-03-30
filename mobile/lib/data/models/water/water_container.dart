class WaterContainer {
  final int? id;
  final String name;
  final int volumeMl;
  final String icon;
  final bool isDefault;

  WaterContainer({
    this.id,
    required this.name,
    required this.volumeMl,
    required this.icon,
    this.isDefault = false,
  });

  factory WaterContainer.fromJson(Map<String, dynamic> json) {
    return WaterContainer(
      id: json['id'],
      name: json['name'],
      volumeMl: json['volume_ml'],
      icon: json['icon'] ?? 'glass',
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'volume_ml': volumeMl,
      'icon': icon,
      'is_default': isDefault,
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  WaterContainer copyWith({
    int? id,
    String? name,
    int? volumeMl,
    String? icon,
    bool? isDefault,
  }) {
    return WaterContainer(
      id: id ?? this.id,
      name: name ?? this.name,
      volumeMl: volumeMl ?? this.volumeMl,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}