import 'package:mobile/data/models/task_category.dart';

class Task {
  final int? id;
  final String title;
  final String? description;
  final int priority;
  final int categoryId;
  final TaskCategory? category;
  final String? dueDate;
  final bool isCompleted;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.categoryId,
    this.category,
    this.dueDate,
    this.isCompleted = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    if (json['title'] == null) {
      throw FormatException('Missing required field: title');
    }

    int? extractedCategoryId;
    if (json['category'] is Map && json['category']['id'] != null) {
      extractedCategoryId = json['category']['id'];
    } else if (json['category_id'] != null) {
      extractedCategoryId = json['category_id'] is String
          ? int.tryParse(json['category_id'])
          : json['category_id'];
    }

    if (extractedCategoryId == null) {
      throw FormatException('Missing required field: category_id');
    }

    return Task(
      id: json['id'],
      title: json['title'].toString(),
      description: json['description']?.toString(),
      priority: _parsePriority(json['priority']),
      categoryId: extractedCategoryId,
      category: json['category'] is Map
          ? TaskCategory.fromJson(json['category'])
          : null,
      dueDate: json['due_date']?.toString() ?? '',
      isCompleted: json['is_completed'] ?? false,
    );
  }

  static int _parsePriority(dynamic priorityValue) {
    if (priorityValue == null) {
      return 1;
    }

    if (priorityValue is int) {
      return priorityValue.clamp(1, 3);
    }

    if (priorityValue is String) {
      if (priorityValue.isEmpty) {
        return 1;
      }

      try {
        return int.parse(priorityValue).clamp(1, 3);
      } catch (e) {
        switch (priorityValue.toLowerCase()) {
          case 'high':
          case 'высокий':
            return 3;
          case 'medium':
          case 'средний':
            return 2;
          case 'low':
          case 'низкий':
            return 1;
          default:
            return 1;
        }
      }
    }
    return 1;
  }

  Map<String, dynamic> toJson() {
    return {
      'id':           id,
      'title':        title,
      'description':  description,
      'priority':     priority,
      'category_id':  categoryId,
      'due_date':     dueDate,
      'is_completed': isCompleted,
    };
  }

  Task copyWith({
    int?          id,
    String?       title,
    String?       description,
    int?          priority,
    int?          categoryId,
    TaskCategory? category,
    String?       dueDate,
    bool?         isCompleted,
  }) {
    return Task(
      id:          id ?? this.id,
      title:       title ?? this.title,
      description: description ?? this.description,
      priority:    priority ?? this.priority,
      categoryId:  categoryId ?? this.categoryId,
      category:    category ?? this.category,
      dueDate:     dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}