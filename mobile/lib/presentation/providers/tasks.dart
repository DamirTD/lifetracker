import 'package:flutter/material.dart';
import 'package:mobile/data/models/grouped_tasks.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/models/task_category.dart';
import 'package:mobile/data/repositories/tasks/category/category_repository.dart';
import 'package:mobile/data/repositories/tasks/task_repository.dart';


class TaskProvider extends ChangeNotifier {
  final TaskRepository _taskRepository = TaskRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  
  List<GroupedTasks>? _groupedTasks;
  List<TaskCategory>? _categories;
  bool _isLoading = false;
  String? _error;

  List<GroupedTasks>? get groupedTasks => _groupedTasks;
  List<TaskCategory>? get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TaskProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final tasks = await _taskRepository.getTasks();
      final categories = await _categoryRepository.getCategories();
      
      _groupedTasks = tasks;
      _categories = categories;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTask(Task task) async {
    try {
      await _taskRepository.createTask(task);
      await loadData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _taskRepository.updateTask(task);
      await loadData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      await _taskRepository.deleteTask(taskId);
      await loadData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markTaskAsCompleted(int taskId) async {
    try {
      await _taskRepository.markTaskAsCompleted(taskId);
      await loadData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createCategory(String name) async {
    try {
      await _categoryRepository.createCategory(name);
      await loadData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}