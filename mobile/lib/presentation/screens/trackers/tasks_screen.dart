import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/models/task_category.dart';
import 'package:mobile/presentation/screens/trackers/task_form_screen.dart';
import 'package:mobile/presentation/providers/tasks.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _showCategories = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TasksProvider>(context, listen: false).loadData();
    });
  }

  void _showAddCategoryDialog() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Новая категория'),
            content: TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Название категории',
              ),
              autofocus: true,
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
                      Navigator.of(dialogContext).pop();

                      await Provider.of<TasksProvider>(
                        context,
                        listen: false,
                      ).createCategory(textController.text);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
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

  void _showEditCategoryDialog(TaskCategory category) {
    final textController = TextEditingController(text: category.name);

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Редактирование категории'),
            content: TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Название категории',
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                child: const Text('Отмена'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              TextButton(
                child: const Text('Сохранить'),
                onPressed: () async {
                  if (textController.text.isNotEmpty) {
                    try {
                      Navigator.of(dialogContext).pop();

                      await Provider.of<TasksProvider>(
                        context,
                        listen: false,
                      ).updateCategory(category.id!, textController.text);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
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

  void _confirmDeleteCategory(TaskCategory category) {
    final tasksProvider = Provider.of<TasksProvider>(context, listen: false);

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Удаление категории'),
            content: Text(
              'Вы уверены, что хотите удалить категорию "${category.name}"? Все связанные задачи также будут удалены.',
            ),
            actions: [
              TextButton(
                child: const Text('Отмена'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              TextButton(
                child: const Text('Удалить'),
                onPressed: () async {
                  if (tasksProvider.categories!.length <= 1) {
                    Navigator.of(
                      dialogContext,
                    ).pop(); // Закрываем окно подтверждения удаления
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Удаление невозможно'),
                            content: const Text(
                              'Вы не можете удалить последнюю категорию. Сначала создайте новую.',
                            ),
                            actions: [
                              TextButton(
                                child: const Text('ОК'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                    );
                    return;
                  }

                  try {
                    Navigator.of(dialogContext).pop();
                    await tasksProvider.deleteCategory(category.id!);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка: ${e.toString()}')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
    );
  }

  void _showCategoryOptionsBottomSheet(TaskCategory category) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Редактировать'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditCategoryDialog(category);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Удалить',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteCategory(category);
                },
              ),
            ],
          ),
    );
  }

  void _navigateToTaskForm(Task? task, List<TaskCategory> categories) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => TaskFormScreen(
              task: task,
              categories: categories,
              onSave: () {
                if (mounted) {
                  Provider.of<TasksProvider>(context, listen: false).loadData();
                }
              },
            ),
      ),
    );
  }

  void _confirmDeleteTask(int taskId) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
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
                  Provider.of<TasksProvider>(
                    context,
                    listen: false,
                  ).deleteTask(taskId);
                },
              ),
            ],
          ),
    );
  }

  void _showAddOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        final tasksProvider = Provider.of<TasksProvider>(context);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Что хотите добавить?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.task, color: Colors.white),
                ),
                title: const Text('Добавить задачу'),
                onTap: () {
                  Navigator.pop(context);

                  if (tasksProvider.categories == null ||
                      tasksProvider.categories!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Сначала создайте категорию'),
                      ),
                    );
                  } else {
                    _navigateToTaskForm(null, tasksProvider.categories!);
                  }
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.category, color: Colors.white),
                ),
                title: const Text('Добавить категорию'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddCategoryDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskItem(Task task) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: task.isCompleted,
              onChanged: (value) {
                if (!task.isCompleted && task.id != null) {
                  Provider.of<TasksProvider>(
                    context,
                    listen: false,
                  ).markTaskAsCompleted(task.id!);
                }
              },
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? Colors.grey : null,
                    ),
                  ),
                  if (task.description != null && task.description!.isNotEmpty)
                    Text(
                      task.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),

            _getPriorityIcon(task.priority),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
              onPressed: () {
                final categories =
                    Provider.of<TasksProvider>(
                      context,
                      listen: false,
                    ).categories;
                if (categories != null && categories.isNotEmpty) {
                  _navigateToTaskForm(task, categories);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
              onPressed:
                  () => task.id != null ? _confirmDeleteTask(task.id!) : null,
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

  Widget _buildCategoryChip(TaskCategory category) {
    return InkWell(
      onTap: () => _showCategoryOptionsBottomSheet(category),
      child: Chip(
        label: Text(category.name),
        backgroundColor: Colors.blue.shade100,
        deleteIcon: const Icon(Icons.more_vert, size: 18),
        onDeleted: () => _showCategoryOptionsBottomSheet(category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksProvider = Provider.of<TasksProvider>(context);
    final categories = tasksProvider.categories;
    final groupedTasks = tasksProvider.groupedTasks;
    final isLoading = tasksProvider.isLoading;
    final error = tasksProvider.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Задачи'),
        actions: [
          // Categories toggle button
          if (categories != null && categories.isNotEmpty)
            IconButton(
              icon: Icon(
                _showCategories ? Icons.category : Icons.category_outlined,
                color: _showCategories ? Colors.blue : null,
              ),
              onPressed: () {
                setState(() {
                  _showCategories = !_showCategories;
                });
              },
              tooltip: 'Категории',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () =>
                    Provider.of<TasksProvider>(
                      context,
                      listen: false,
                    ).loadData(),
            tooltip: 'Обновить',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptionsBottomSheet,
        tooltip: 'Добавить',
        child: const Icon(Icons.add),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Ошибка: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          () =>
                              Provider.of<TasksProvider>(
                                context,
                                listen: false,
                              ).loadData(),
                      child: const Text('Попробовать снова'),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  if (_showCategories &&
                      categories != null &&
                      categories.isNotEmpty)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Card(
                        margin: const EdgeInsets.all(8.0),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Категории',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Добавить'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.blue,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                    ),
                                    onPressed: _showAddCategoryDialog,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    categories
                                        .map(
                                          (category) =>
                                              _buildCategoryChip(category),
                                        )
                                        .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  Expanded(
                    child:
                        groupedTasks == null || groupedTasks.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.task_alt,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'У вас пока нет задач',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.add),
                                    label: const Text('Добавить задачу'),
                                    onPressed: () {
                                      if (categories == null ||
                                          categories.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Сначала создайте категорию',
                                            ),
                                          ),
                                        );
                                        _showAddCategoryDialog();
                                      } else {
                                        _navigateToTaskForm(null, categories);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              itemCount: groupedTasks.length,
                              itemBuilder: (context, index) {
                                final group = groupedTasks[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            group.date,
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.titleLarge,
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.blue.shade100,
                                              ),
                                            ),
                                            child: Text(
                                              group.category.name,
                                              style: TextStyle(
                                                color: Colors.blue.shade800,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ...group.tasks.map(
                                      (task) => _buildTaskItem(task),
                                    ),
                                    const Divider(),
                                  ],
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
