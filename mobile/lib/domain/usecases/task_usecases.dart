import 'package:mobile/data/models/grouped_tasks.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/repositories/tasks/task_repository.dart';

class TaskUseCases {
  final TaskRepository _repository;

  TaskUseCases(this._repository);

  Future<List<GroupedTasks>> getTasks() {
    return _repository.getTasks();
  }

  Future<Task> createTask(Task task) {
    // Преобразуем данные перед отправкой
    Task preparedTask = _prepareTaskForApi(task);
    return _repository.createTask(preparedTask);
  }

  Future<Task> updateTask(Task task) {
    // Убедимся, что у задачи есть ID
    if (task.id == null) {
      throw Exception('Невозможно обновить задачу без ID');
    }

    // Преобразуем данные перед отправкой
    Task preparedTask = _prepareTaskForApi(task);

    // Извлекаем ID и преобразуем задачу в Map для отправки
    final taskId = preparedTask.id!;
    final taskData = preparedTask.toJson();

    print('Отправка задачи ID $taskId: $taskData');

    // Вызываем метод репозитория с двумя аргументами
    return _repository.updateTask(taskId, taskData);
  }

  Future<void> deleteTask(int taskId) {
    return _repository.deleteTask(taskId);
  }

  Future<Task> markTaskAsCompleted(int taskId) {
    return _repository.markTaskAsCompleted(taskId);
  }

  // Вспомогательный метод для подготовки задачи перед отправкой
  Task _prepareTaskForApi(Task task) {
    // Здесь мы обрабатываем пустую строку даты как null
    // и добавляем время к дате, если его нет
    String? formattedDueDate;

    if (task.dueDate == null || task.dueDate!.isEmpty) {
      formattedDueDate = null;
    } else if (!task.dueDate!.contains(':')) {
      // Если в дате нет двоеточия, значит нет времени
      formattedDueDate = '${task.dueDate} 00:00:00';
    } else {
      formattedDueDate = task.dueDate;
    }

    return Task(
      id: task.id,
      title: task.title,
      description: task.description,
      priority: task.priority,
      categoryId: task.categoryId,
      category: task.category,
      dueDate: formattedDueDate,
      isCompleted: task.isCompleted,
    );
  }
}