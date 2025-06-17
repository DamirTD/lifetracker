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
              decoration: InputDecoration(
                labelText: 'Название категории',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              autofocus: true,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                child: const Text('Отмена'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                          SnackBar(
                            content: Text('Ошибка: ${e.toString()}'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    } finally {
                      textController.dispose();
                    }
                  } else {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: const Text(
                  'Добавить',
                  style: TextStyle(color: Colors.white),
                ),
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
              decoration: InputDecoration(
                labelText: 'Название категории',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              autofocus: true,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                child: const Text('Отмена'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                          SnackBar(
                            content: Text('Ошибка: ${e.toString()}'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    } finally {
                      textController.dispose();
                    }
                  } else {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: const Text(
                  'Сохранить',
                  style: TextStyle(color: Colors.white),
                ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                child: const Text('Отмена'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (tasksProvider.categories!.length <= 1) {
                    Navigator.of(dialogContext).pop();
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Удаление невозможно'),
                            content: const Text(
                              'Вы не можете удалить последнюю категорию. Сначала создайте новую.',
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
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
                        SnackBar(
                          content: Text('Ошибка: ${e.toString()}'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'Удалить',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showCategoryOptionsBottomSheet(TaskCategory category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha((255 * 0.2).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit, color: Colors.blue),
                  ),
                  title: const Text('Редактировать'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditCategoryDialog(category);
                  },
                ),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha((255 * 0.2).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
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

  void _showAddOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final tasksProvider = Provider.of<TasksProvider>(context);

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Что хотите добавить?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha((255 * 0.2).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.task, color: Colors.blue),
                ),
                title: const Text('Добавить задачу'),
                subtitle: const Text('Создать новую задачу'),
                onTap: () {
                  Navigator.pop(context);

                  if (tasksProvider.categories == null ||
                      tasksProvider.categories!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Сначала создайте категорию'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  } else {
                    _navigateToTaskForm(null, tasksProvider.categories!);
                  }
                },
              ),
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha((255 * 0.2).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.category, color: Colors.green),
                ),
                title: const Text('Добавить категорию'),
                subtitle: const Text('Создать новую категорию задач'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddCategoryDialog();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskItem(Task task) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withAlpha((255 * 0.2).round()),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final categories =
              Provider.of<TasksProvider>(context, listen: false).categories;
          if (categories != null && categories.isNotEmpty) {
            _navigateToTaskForm(task, categories);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Checkbox
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    if (!task.isCompleted && task.id != null) {
                      Provider.of<TasksProvider>(
                        context,
                        listen: false,
                      ).markTaskAsCompleted(task.id!);
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration:
                            task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                        color: task.isCompleted ? Colors.grey : null,
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          task.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              _getPriorityIcon(task.priority),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.red[400],
                ),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: const Text('Удалить задачу'),
                          content: const Text(
                            'Вы уверены, что хотите удалить эту задачу?',
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Отмена'),
                              onPressed: () => Navigator.of(ctx).pop(false),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Удалить',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () => Navigator.of(ctx).pop(true),
                            ),
                          ],
                        ),
                  );

                  if (confirm == true && task.id != null) {
                    await Provider.of<TasksProvider>(
                      context,
                      listen: false,
                    ).deleteTask(task.id!);
                  }
                },
              ),
            ],
          ),
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

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.2).round()),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(iconData, color: color, size: 18),
    );
  }

  Widget _buildCategoryChip(TaskCategory category) {
    return InkWell(
      onTap: () => _showCategoryOptionsBottomSheet(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(
              context,
            ).primaryColor.withAlpha((255 * 0.3).round()),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category.name,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.more_vert,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
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
        title: const Text(
          'Задачи',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: false,
        actions: [
          if (categories != null && categories.isNotEmpty)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color:
                      _showCategories
                          ? Theme.of(
                            context,
                          ).primaryColor.withAlpha((255 * 0.2).round())
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _showCategories ? Icons.category : Icons.category_outlined,
                  color:
                      _showCategories
                          ? Theme.of(context).primaryColor
                          : Colors.grey[700],
                ),
              ),
              onPressed: () {
                setState(() {
                  _showCategories = !_showCategories;
                });
              },
              tooltip: 'Категории',
            ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha((255 * 0.1).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.refresh, color: Colors.grey[700]),
            ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddOptionsBottomSheet,
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
      ),

      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Ошибка загрузки данных',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Попробовать снова'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onPressed:
                          () =>
                              Provider.of<TasksProvider>(
                                context,
                                listen: false,
                              ).loadData(),
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
                        margin: const EdgeInsets.all(16.0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.grey.withAlpha((255 * 0.2).round()),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Категории',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  TextButton.icon(
                                    icon: Icon(
                                      Icons.add,
                                      size: 18,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    label: Text(
                                      'Добавить',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                    ),
                                    onPressed: _showAddCategoryDialog,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children:
                                      categories
                                          .map(
                                            (category) => Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8.0,
                                              ),
                                              child: _buildCategoryChip(
                                                category,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (_showCategories &&
                      categories != null &&
                      categories.isNotEmpty)
                    const Divider(height: 1, thickness: 1),

                  Expanded(
                    child:
                        groupedTasks == null || groupedTasks.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.task_alt,
                                    size: 72,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'У вас пока нет задач',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Добавьте задачу, нажав на кнопку ниже',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.add),
                                    label: const Text('Добавить задачу'),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () {
                                      if (categories == null ||
                                          categories.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              'Сначала создайте категорию',
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                            : RefreshIndicator(
                              onRefresh: () async {
                                await Provider.of<TasksProvider>(
                                  context,
                                  listen: false,
                                ).loadData();
                              },
                              child: ListView.builder(
                                itemCount: groupedTasks.length,
                                itemBuilder: (context, index) {
                                  final group = groupedTasks[index];
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          24,
                                          16,
                                          24,
                                          8,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              group.date,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor.withAlpha(
                                                  (255 * 0.1).round(),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor.withAlpha(
                                                    (255 * 0.3).round(),
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                group.category.name,
                                                style: TextStyle(
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).primaryColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ...group.tasks.map(
                                        (task) => _buildTaskItem(task),
                                      ),
                                      if (index < groupedTasks.length - 1)
                                        const Divider(height: 8, thickness: 1),
                                    ],
                                  );
                                },
                              ),
                            ),
                  ),
                ],
              ),
    );
  }
}
