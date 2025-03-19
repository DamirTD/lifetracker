class TaskCategory {
  final int? id;
  final String name;

  TaskCategory({
    this.id,
    required this.name,
  });

  factory TaskCategory.fromJson(Map<String, dynamic> json) {
    return TaskCategory(
      id:   json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':   id,
      'name': name,
    };
  }
}