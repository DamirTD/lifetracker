import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/models/task_category.dart';
import 'package:mobile/data/models/grouped_tasks.dart';
import 'package:mobile/data/repositories/tasks/task_repository.dart';
import 'package:mobile/data/repositories/tasks/category/category_repository.dart';
import 'package:mobile/domain/usecases/category_usecases.dart';
import 'package:mobile/domain/usecases/task_usecases.dart';

class TasksState {
  final bool isLoading;
  final String? error;
  final List<TaskCategory>? categories;
  final List<GroupedTasks>? groupedTasks;

  TasksState({
    this.isLoading = false,
    this.error,
    this.categories,
    this.groupedTasks,
  });

  TasksState copyWith({
    bool? isLoading,
    String? error,
    List<TaskCategory>? categories,
    List<GroupedTasks>? groupedTasks,
  }) {
    return TasksState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      categories: categories ?? this.categories,
      groupedTasks: groupedTasks ?? this.groupedTasks,
    );
  }
}

class TasksNotifier extends StateNotifier<TasksState> {
  final TaskUseCases _taskUseCases;
  final CategoryUseCases _categoryUseCases;

  TasksNotifier(this._taskUseCases, this._categoryUseCases) : super(TasksState());

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final categories = await _categoryUseCases.getCategories();
      final groupedTasks = await _taskUseCases.getTasks();

      state = state.copyWith(
        isLoading: false,
        categories: categories,
        groupedTasks: groupedTasks,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createTask(Task task) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _taskUseCases.createTask(task);
      await loadData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _taskUseCases.updateTask(task);
      await loadData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteTask(int taskId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _taskUseCases.deleteTask(taskId);
      await loadData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> markTaskAsCompleted(int taskId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _taskUseCases.markTaskAsCompleted(taskId);
      await loadData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createCategory(String name) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _categoryUseCases.createCategory(name);
      await loadData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateCategory(int categoryId, String name) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _categoryUseCases.updateCategory(categoryId, name);
      await loadData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _categoryUseCases.deleteCategory(categoryId);
      await loadData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}

// Repository providers
final taskRepositoryProvider = Provider((ref) => TaskRepository());
final categoryRepositoryProvider = Provider((ref) => TaskCategoryRepository());

// UseCase providers
final taskUseCasesProvider = Provider((ref) =>
    TaskUseCases(ref.watch(taskRepositoryProvider))
);

final categoryUseCasesProvider = Provider((ref) =>
    CategoryUseCases(ref.watch(categoryRepositoryProvider))
);

// State provider
final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  final taskUseCases = ref.watch(taskUseCasesProvider);
  final categoryUseCases = ref.watch(categoryUseCasesProvider);
  return TasksNotifier(taskUseCases, categoryUseCases);
});