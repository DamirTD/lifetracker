import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/models/grouped_tasks.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/models/task_category.dart';
import 'package:mobile/data/repositories/tasks/category/category_repository.dart';
import 'package:mobile/data/repositories/tasks/task_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  
  // Локальное состояние для порядка
  Map<int, List<int>> _taskOrderByCategoryId = {}; // categoryId -> [taskId1, taskId2, ...]
  List<int> _categoryOrder = []; // [categoryId1, categoryId2, ...]

  TasksProvider(this._taskRepository, this._categoryRepository) {
    _loadOrderFromPreferences();
    loadData();
  }

  // Сохранение и загрузка порядка из SharedPreferences
  Future<void> _saveOrderToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Сохраняем порядок категорий
    await prefs.setStringList('category_order', _categoryOrder.map((e) => e.toString()).toList());
    
    // Сохраняем порядок задач для каждой категории
    for (final entry in _taskOrderByCategoryId.entries) {
      final categoryId = entry.key;
      final taskIds = entry.value;
      await prefs.setStringList('task_order_$categoryId', taskIds.map((e) => e.toString()).toList());
    }
  }

  Future<void> _loadOrderFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Загружаем порядок категорий
    final categoryOrderStrings = prefs.getStringList('category_order') ?? [];
    _categoryOrder = categoryOrderStrings
        .map((e) => int.tryParse(e))
        .where((e) => e != null)
        .map((e) => e!)
        .toList();
    
    // Загружаем порядок задач для каждой категории
    final keys = prefs.getKeys().where((key) => key.startsWith('task_order_'));
    for (final key in keys) {
      final categoryIdString = key.replaceFirst('task_order_', '');
      final categoryId = int.tryParse(categoryIdString);
      if (categoryId != null) {
        final taskOrderStrings = prefs.getStringList(key) ?? [];
        final taskIds = taskOrderStrings
            .map((e) => int.tryParse(e))
            .where((e) => e != null)
            .map((e) => e!)
            .toList();
        _taskOrderByCategoryId[categoryId] = taskIds;
      }
    }
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

      // Сохраняем порядок категорий при первой загрузке, если он еще не был сохранен
      if (_categoryOrder.isEmpty && taskGroups.isNotEmpty) {
        _categoryOrder = taskGroups
            .map((g) => g.category.id)
            .where((id) => id != null)
            .map((id) => id!)
            .toList();
      }
      
      // Сохраняем порядок задач для каждой категории при первой загрузке
      for (final group in taskGroups) {
        final categoryId = group.category.id;
        if (categoryId != null && !_taskOrderByCategoryId.containsKey(categoryId) && group.tasks.isNotEmpty) {
          _taskOrderByCategoryId[categoryId] = group.tasks
              .map((t) => t.id)
              .where((id) => id != null)
              .map((id) => id!)
              .toList();
        }
      }
      
      // Сохраняем в SharedPreferences если были изменения
      if (_categoryOrder.isNotEmpty || _taskOrderByCategoryId.isNotEmpty) {
        _saveOrderToPreferences();
      }

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
      final categoryId = category.id;

      // Применяем сохраненный порядок задач для этой категории
      List<Task> orderedTasks = List.from(groupedTask.tasks);
      if (categoryId != null && _taskOrderByCategoryId.containsKey(categoryId)) {
        final savedOrder = _taskOrderByCategoryId[categoryId]!;
        final tasksMap = {for (var task in orderedTasks) task.id: task};
        
        // Сначала добавляем задачи в сохраненном порядке
        final reorderedTasks = <Task>[];
        for (final taskId in savedOrder) {
          if (tasksMap.containsKey(taskId)) {
            reorderedTasks.add(tasksMap[taskId]!);
            tasksMap.remove(taskId);
          }
        }
        
        // Добавляем новые задачи, которых не было в сохраненном порядке
        reorderedTasks.addAll(tasksMap.values);
        orderedTasks = reorderedTasks;
      }

      final taskGroup = TaskGroup(
        date: groupedTask.date,
        category: category,
        tasks: orderedTasks,
      );

      result.add(taskGroup);
    }

    // Применяем сохраненный порядок категорий
    if (_categoryOrder.isNotEmpty) {
      final categoriesMap = {for (var group in result) group.category.id: group};
      final reorderedResult = <TaskGroup>[];
      
      // Сначала добавляем категории в сохраненном порядке
      for (final categoryId in _categoryOrder) {
        if (categoriesMap.containsKey(categoryId)) {
          reorderedResult.add(categoriesMap[categoryId]!);
          categoriesMap.remove(categoryId);
        }
      }
      
      // Добавляем новые категории, которых не было в сохраненном порядке
      reorderedResult.addAll(categoriesMap.values);
      return reorderedResult;
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

  Future<void> markTaskAsIncomplete(int id) async {
    try {
      await _taskRepository.markTaskAsIncomplete(id);
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

  // Методы для перестановки задач и категорий
  void reorderTasks(int categoryIndex, int oldIndex, int newIndex) {
    if (_state.groupedTasks == null) return;
    
    final groupedTasks = List<TaskGroup>.from(_state.groupedTasks!);
    if (categoryIndex >= groupedTasks.length) return;
    
    final category = groupedTasks[categoryIndex];
    final tasks = List<Task>.from(category.tasks);
    
    // Корректируем newIndex если элемент перемещается вниз
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    
    if (oldIndex < tasks.length && newIndex < tasks.length) {
      final task = tasks.removeAt(oldIndex);
      tasks.insert(newIndex, task);
      
      // Сохраняем новый порядок задач в локальном состоянии
      final categoryId = category.category.id;
      if (categoryId != null) {
        _taskOrderByCategoryId[categoryId] = tasks
            .map((t) => t.id)
            .where((id) => id != null)
            .map((id) => id!)
            .toList();
        _saveOrderToPreferences(); // Сохраняем в SharedPreferences
      }
      
      // Создаем новую группу с переставленными задачами
      final newGroup = TaskGroup(
        date: category.date,
        category: category.category,
        tasks: tasks,
      );
      
      groupedTasks[categoryIndex] = newGroup;
      
      _state = _state.copyWith(groupedTasks: groupedTasks);
      notifyListeners();
    }
  }

  void reorderCategories(int oldIndex, int newIndex) {
    if (_state.groupedTasks == null) return;
    
    final groupedTasks = List<TaskGroup>.from(_state.groupedTasks!);
    
    // Корректируем newIndex если элемент перемещается вниз
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    
    if (oldIndex < groupedTasks.length && newIndex < groupedTasks.length) {
      final group = groupedTasks.removeAt(oldIndex);
      groupedTasks.insert(newIndex, group);
      
      // Сохраняем новый порядок категорий в локальном состоянии
      _categoryOrder = groupedTasks
          .map((g) => g.category.id)
          .where((id) => id != null)
          .map((id) => id!)
          .toList();
      _saveOrderToPreferences(); // Сохраняем в SharedPreferences
      
      _state = _state.copyWith(groupedTasks: groupedTasks);
      notifyListeners();
    }
  }
}