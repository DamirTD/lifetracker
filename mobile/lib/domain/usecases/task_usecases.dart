
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
    return _repository.createTask(task);
  }

  Future<Task> updateTask(Task task) {
    return _repository.updateTask(task);
  }

  Future<void> deleteTask(int taskId) {
    return _repository.deleteTask(taskId);
  }

  Future<Task> markTaskAsCompleted(int taskId) {
    return _repository.markTaskAsCompleted(taskId);
  }
}