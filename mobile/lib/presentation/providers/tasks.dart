import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/models/grouped_tasks.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/models/task_category.dart';
import 'package:mobile/data/repositories/tasks/category/category_repository.dart';
import 'package:mobile/data/repositories/tasks/task_repository.dart';

final tasksProvider = ChangeNotifierProvider<TasksProvider>((ref) {
  throw UnimplementedError('tasksProvider was not initialized');
});

class TaskState {
  final List<TaskCategory>? categories;
  final List<TaskGroup>? groupedTasks;
  final bool isLoading;
  final String? error;

  TaskState({
    this.categories,
    this.groupedTasks,
    this.isLoading = false,
    this.error,
  });

  TaskState copyWith({
    List<TaskCategory>? categories,
    List<TaskGroup>? groupedTasks,
    bool? isLoading,
    String? error,
  }) {
    return TaskState(
      categories: categories ?? this.categories,
      groupedTasks: groupedTasks ?? this.groupedTasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TaskGroup {
  final String date;
  final TaskCategory category;
  final List<Task> tasks;

  TaskGroup({
    required this.date,
    required this.category,
    required this.tasks,
  });
}

class TasksProvider extends ChangeNotifier {
  final TaskRepository _taskRepository;
  final TaskCategoryRepository _categoryRepository;
  TaskState _state = TaskState(isLoading: true);

  TasksProvider(this._taskRepository, this._categoryRepository) {
    loadData();
  }

  TaskState get state => _state;

  List<TaskCategory>? get categories => _state.categories;
  List<TaskGroup>? get groupedTasks => _state.groupedTasks;
  bool get isLoading => _state.isLoading;
  String? get error => _state.error;

  Future<void> loadData() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final categories = await _categoryRepository.getCategories();
      final groupedTasks = await _taskRepository.getTasks();

      final taskGroups = _processGroupedTasks(groupedTasks, categories);

      _state = _state.copyWith(
        categories: categories,
        groupedTasks: taskGroups,
        isLoading: false,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      notifyListeners();
    }
  }

  List<TaskGroup> _processGroupedTasks(List<GroupedTasks> groupedTasks, List<TaskCategory> categories) {
    final List<TaskGroup> result = [];

    for (var groupedTask in groupedTasks) {
      final category = groupedTask.category;

      final taskGroup = TaskGroup(
        date: groupedTask.date,
        category: category,
        tasks: groupedTask.tasks,
      );

      result.add(taskGroup);
    }

    return result;
  }

  Future<void> createCategory(String name) async {
    try {
      await _categoryRepository.createCategory(name);
      await loadData();
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateCategory(int id, String name) async {
    try {
      await _categoryRepository.updateCategory(id, name);
      await loadData();
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _categoryRepository.deleteCategory(id);
      await loadData();
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createTask(Task task) async {
    try {
      await _taskRepository.createTask(task);
      await loadData();
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTask(int id, Map<String, dynamic> data) async {
    try {
      await _taskRepository.updateTask(id, data);
      await loadData();
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTaskObject(Task task) async {
    if (task.id == null) {
      throw Exception('Невозможно обновить задачу без ID');
    }

    final data = {
      'title': task.title,
      'description': task.description,
      'priority': task.priority,
      'category_id': task.categoryId,
      'due_date': task.dueDate,
    };

    await updateTask(task.id!, data);
  }

  Future<void> markTaskAsCompleted(int id) async {
    try {
      await _taskRepository.markTaskAsCompleted(id);
      await loadData();
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _taskRepository.deleteTask(id);
      await loadData();
    } catch (e) {
      _state = _state.copyWith(error: e.toString());
      notifyListeners();
      rethrow;
    }
  }
}