import 'task.dart';
import 'task_category.dart';

class GroupedTasks {
  final String date;
  final TaskCategory category;
  final List<Task> tasks;

  GroupedTasks({
    required this.date,
    required this.category,
    required this.tasks,
  });

  factory GroupedTasks.fromJson(Map<String, dynamic> json) {
    return GroupedTasks(
      date: json['date'],
      category: TaskCategory.fromJson(json['category']),
      tasks: (json['tasks'] as List).map((task) => Task.fromJson(task)).toList(),
    );
  }
}