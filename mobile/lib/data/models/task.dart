import 'package:intl/intl.dart';

class Task {
  final int? id;
  final String title;
  final String? description;
  final int priority;
  final int categoryId;
  final DateTime dueDate;
  final bool isCompleted;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.categoryId,
    required this.dueDate,
    this.isCompleted = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    // Handle category_id which might come as string
    int parsedCategoryId;
    if (json['category_id'] is String) {
      parsedCategoryId = int.tryParse(json['category_id']) ?? 0;
    } else {
      parsedCategoryId = json['category_id'] ?? 0;
    }
    
    // Handle priority which might come as string
    int parsedPriority;
    if (json['priority'] is String) {
      parsedPriority = int.tryParse(json['priority']) ?? 1;
    } else {
      parsedPriority = json['priority'] ?? 1;
    }
    
    // Handle date in format DD.MM.YYYY
    DateTime parsedDate;
    try {
      if (json['due_date'] is String) {
        if (json['due_date'].contains('.')) {
          // Parse DD.MM.YYYY format
          List<String> parts = json['due_date'].split('.');
          if (parts.length == 3) {
            parsedDate = DateTime(
              int.parse(parts[2]), // year
              int.parse(parts[1]), // month
              int.parse(parts[0]), // day
            );
          } else {
            parsedDate = DateTime.now(); // Fallback
          }
        } else {
          // Try standard ISO format
          parsedDate = DateTime.parse(json['due_date']);
        }
      } else {
        parsedDate = DateTime.now(); // Fallback
      }
    } catch (e) {
      parsedDate = DateTime.now(); // Fallback on any error
    }
    
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      priority: parsedPriority,
      categoryId: parsedCategoryId,
      dueDate: parsedDate,
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'category_id': categoryId,
      'due_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(dueDate),
      'is_completed': isCompleted,
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    int? priority,
    int? categoryId,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      categoryId: categoryId ?? this.categoryId,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}