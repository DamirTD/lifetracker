import 'package:flutter/material.dart';
import 'package:mobile/data/models/grouped_tasks.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/models/task_category.dart';
import 'package:mobile/data/repositories/tasks/category/category_repository.dart';
import 'package:mobile/data/repositories/tasks/task_repository.dart';
import 'task_form_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskRepository _taskRepository = TaskRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  List<GroupedTasks>? _groupedTasks;
  List<TaskCategory>? _categories;
  bool _isLoading = true;
  String? _error;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Безопасный setState, который проверяет, не удалён ли виджет
  void _safeSetState(VoidCallback fn) {
    if (!_disposed && mounted) {
      setState(fn);
    }
  }

  Future<void> _loadData() async {
    if (_disposed) return;
    
    _safeSetState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tasks = await _taskRepository.getTasks();
      final categories = await _categoryRepository.getCategories();
      
      if (_disposed) return;
      
      _safeSetState(() {
        _groupedTasks = tasks;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      if (_disposed) return;
      
      _safeSetState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsCompleted(int taskId) async {
    try {
      await _taskRepository.markTaskAsCompleted(taskId);
      if (!mounted) return;
      _loadData(); // Обновляем список после изменения
    } catch (e) {
      if (!mounted) return;
      
      // Безопасно используем контекст
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteTask(int taskId) async {
    try {
      await _taskRepository.deleteTask(taskId);
      if (!mounted) return;
      _loadData(); // Обновляем список после удаления
    } catch (e) {
      if (!mounted) return;
      
      // Безопасно используем контекст
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}')),
        );
      }
    }
  }

  void _showAddCategoryDialog() {
    final textController = TextEditingController();
    
    // Сохраняем ScaffoldMessenger до показа диалога
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Новая категория'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Название категории',
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Отмена'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            child: const Text('Добавить'),
            onPressed: () async {
              if (textController.text.isNotEmpty) {
                try {
                  // Закрываем диалог ДО выполнения асинхронной операции
                  Navigator.of(dialogContext).pop();
                  
                  await _categoryRepository.createCategory(textController.text);
                  
                  if (!mounted) return;
                  _loadData(); // Обновляем список после добавления
                } catch (e) {
                  // Проверяем, монтирован ли виджет, прежде чем использовать сохраненный scaffoldMessenger
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Ошибка: ${e.toString()}')),
                    );
                  }
                } finally {
                  textController.dispose();
                }
              } else {
                Navigator.of(dialogContext).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _navigateToTaskForm(Task? task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(
          task: task,
          categories: _categories ?? [],
          onSave: () {
            if (mounted) {
              _loadData();
            }
          },
        ),
      ),
    );
  }

  void _confirmDeleteTask(int taskId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удаление задачи'),
        content: const Text('Вы уверены, что хотите удалить эту задачу?'),
        actions: [
          TextButton(
            child: const Text('Отмена'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            child: const Text('Удалить'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _deleteTask(taskId);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Задачи'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showAddCategoryDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_categories == null || _categories!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Сначала создайте категорию')),
            );
          } else {
            _navigateToTaskForm(null);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ошибка: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      );
    }

    if (_groupedTasks == null || _groupedTasks!.isEmpty) {
      return const Center(
        child: Text('У вас пока нет задач. Добавьте новую!'),
      );
    }

    return ListView.builder(
      itemCount: _groupedTasks!.length,
      itemBuilder: (context, index) {
        final group = _groupedTasks![index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    group.date,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(group.category.name),
                    backgroundColor: Colors.blue.shade100,
                  ),
                ],
              ),
            ),
            ...group.tasks.map((task) => _buildTaskItem(task)),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildTaskItem(Task task) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: task.description != null && task.description!.isNotEmpty
            ? Text(
                task.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            if (!task.isCompleted && task.id != null) {
              _markAsCompleted(task.id!);
            }
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getPriorityIcon(task.priority),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToTaskForm(task),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => task.id != null ? _confirmDeleteTask(task.id!) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPriorityIcon(int priority) {
    IconData iconData;
    Color color;

    switch (priority) {
      case 1:
        iconData = Icons.flag;
        color = Colors.green;
        break;
      case 2:
        iconData = Icons.flag;
        color = Colors.orange;
        break;
      case 3:
        iconData = Icons.flag;
        color = Colors.red;
        break;
      default:
        iconData = Icons.flag_outlined;
        color = Colors.grey;
    }

    return Icon(iconData, color: color);
  }
}