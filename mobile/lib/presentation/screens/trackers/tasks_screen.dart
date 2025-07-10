import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/models/task_category.dart';
import 'package:mobile/presentation/screens/trackers/task_form_screen.dart';
import 'package:mobile/presentation/screens/trackers/day_tasks_screen.dart';
import 'package:mobile/presentation/providers/tasks.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool _isEditMode = false;
  DateTime _selectedDay = DateTime.now();
  String? _lastSavedSnapshot;
  Timer? _periodicSaveTimer;
  Set<String> _savedDates = <String>{};

  @override
  void initState() {
    super.initState();
    _loadSavedDates();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TasksProvider>(context, listen: false).loadData().then((_) {
        // Сохраняем снимок состояния после загрузки данных
        Future.delayed(const Duration(milliseconds: 1000), () {
          _saveDailySnapshot();
        });
      });
    });
    
    // Периодическое сохранение снимков каждые 5 минут
    _periodicSaveTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _saveDailySnapshot();
    });
  }

  Future<void> _loadSavedDates() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    setState(() {
      _savedDates = keys
          .where((key) => key.startsWith('daily_snapshot_'))
          .map((key) => key.replaceFirst('daily_snapshot_', ''))
          .toSet();
    });
  }

  @override
  void dispose() {
    _periodicSaveTimer?.cancel();
    // Сохраняем снимок при выходе из экрана
    _saveDailySnapshot();
    super.dispose();
  }

  // Сохранение снимка состояния на день
  Future<void> _saveDailySnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
    
    if (tasksProvider.groupedTasks != null) {
      final today = DateTime.now();
      final dateKey = '${today.year}-${today.month}-${today.day}';
      
      // Создаем снимок всех задач и категорий
      final snapshot = {
        'date': dateKey,
        'timestamp': today.millisecondsSinceEpoch,
        'tasks': tasksProvider.groupedTasks!.map((group) => {
          'category': group.category.toJson(),
          'tasks': group.tasks.map((task) => task.toJson()).toList(),
        }).toList(),
      };
      
      final snapshotString = json.encode(snapshot);
      
      // Сохраняем только если данные изменились
      if (_lastSavedSnapshot != snapshotString) {
        await prefs.setString('daily_snapshot_$dateKey', snapshotString);
        _lastSavedSnapshot = snapshotString;
        
        // Обновляем множество сохраненных дат
        if (mounted) {
          setState(() {
            _savedDates.add(dateKey);
          });
        }
      }
    }
  }

  void _navigateToTaskForm(Task? task, List<TaskCategory> categories) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(
          task: task,
          categories: categories,
          onSave: () {
            if (mounted) {
              Provider.of<TasksProvider>(context, listen: false).loadData();
              // Сохраняем снимок после изменения данных
              Future.delayed(const Duration(milliseconds: 500), () {
                _saveDailySnapshot();
              });
            }
          },
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
    
    if (tasksProvider.categories == null || tasksProvider.categories!.isEmpty) {
      _showCreateCategoryDialog();
      return;
    }
    
    _navigateToTaskForm(null, tasksProvider.categories!);
  }

  void _showCreateCategoryDialog() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Создайте категорию',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Сначала создайте категорию для ваших задач',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: 'Название категории',
                hintText: 'Например: Работа, Дом, Учеба',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              autofocus: true,
            ),
          ],
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
                  await Provider.of<TasksProvider>(context, listen: false)
                      .createCategory(textController.text);
                  
                  // Сохраняем снимок после создания категории
                  Future.delayed(const Duration(milliseconds: 500), () {
                    _saveDailySnapshot();
                  });
                  
                  // После создания категории сразу открываем форму задачи
                  final categories = Provider.of<TasksProvider>(context, listen: false).categories;
                  if (categories != null && categories.isNotEmpty) {
                    _navigateToTaskForm(null, categories);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ошибка: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text(
              'Создать',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task, {bool isReorderable = false}) {
    final theme = Theme.of(context);
    
    return Container(
      key: isReorderable ? ValueKey(task.id) : null,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: _isEditMode ? Border.all(
          color: theme.primaryColor.withOpacity(0.3),
          width: 2,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isEditMode ? null : () {
            final categories = Provider.of<TasksProvider>(context, listen: false).categories;
            if (categories != null && categories.isNotEmpty) {
              _navigateToTaskForm(task, categories);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Drag handle or checkbox
                if (_isEditMode)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.drag_handle,
                      size: 20,
                      color: theme.primaryColor,
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () {
                      if (!task.isCompleted && task.id != null) {
                        Provider.of<TasksProvider>(context, listen: false)
                            .markTaskAsCompleted(task.id!);
                        // Сохраняем снимок после изменения состояния
                        Future.delayed(const Duration(milliseconds: 500), () {
                          _saveDailySnapshot();
                        });
                      }
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.isCompleted ? theme.primaryColor : Colors.grey[400]!,
                          width: 2,
                        ),
                        color: task.isCompleted ? theme.primaryColor : Colors.transparent,
                      ),
                      child: task.isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                
                const SizedBox(width: 16),
                
                // Task content
                Expanded(
                                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? Colors.grey[400] : Colors.grey[800],
                          ),
                        ),
                        if (task.description != null && task.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
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
                        if (task.dueDate != null && task.dueDate!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 14,
                                  color: _getDateColor(task.dueDate!),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTaskDate(task.dueDate!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getDateColor(task.dueDate!),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                ),
                
                const SizedBox(width: 12),
                
                // Priority indicator
                _buildPriorityIndicator(task.priority),
                
                if (!_isEditMode) ...[
                  const SizedBox(width: 8),
                  
                  // Delete button
                  GestureDetector(
                    onTap: () => _showDeleteConfirmation(task),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red[400],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(int priority) {
    Color color;
    String label;

    switch (priority) {
      case 1:
        color = Colors.green;
        label = 'Низкий';
        break;
      case 2:
        color = Colors.orange;
        label = 'Средний';
        break;
      case 3:
        color = Colors.red;
        label = 'Высокий';
        break;
      default:
        color = Colors.grey;
        label = 'Обычный';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Удалить задачу?',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Задача "${task.title}" будет удалена безвозвратно.',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            child: const Text('Отмена'),
            onPressed: () => Navigator.of(ctx).pop(),
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
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (task.id != null) {
                await Provider.of<TasksProvider>(context, listen: false)
                    .deleteTask(task.id!);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String categoryName, List<Task> tasks, int categoryIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            children: [
              if (_isEditMode)
                Container(
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.drag_handle,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                categoryName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${tasks.where((t) => t.isCompleted).length}',
                      style: TextStyle(
                        color: Colors.green[600],
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '/',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${tasks.length}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_isEditMode && tasks.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            onReorder: (oldIndex, newIndex) {
              _reorderTasks(categoryIndex, oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskCard(task, isReorderable: true);
            },
          )
        else
          ...tasks.map((task) => _buildTaskCard(task)),
      ],
    );
  }

  void _reorderTasks(int categoryIndex, int oldIndex, int newIndex) {
    Provider.of<TasksProvider>(context, listen: false)
        .reorderTasks(categoryIndex, oldIndex, newIndex);
    // Сохраняем снимок после изменения порядка
    Future.delayed(const Duration(milliseconds: 300), () {
      _saveDailySnapshot();
    });
  }

  void _reorderCategories(int oldIndex, int newIndex) {
    Provider.of<TasksProvider>(context, listen: false)
        .reorderCategories(oldIndex, newIndex);
    // Сохраняем снимок после изменения порядка
    Future.delayed(const Duration(milliseconds: 300), () {
      _saveDailySnapshot();
    });
  }

  String _formatTaskDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final taskDate = DateTime(date.year, date.month, date.day);
      
      // Форматируем время
      String timeString = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      
      if (taskDate == today) {
        return 'Сегодня $timeString';
      } else if (taskDate == tomorrow) {
        return 'Завтра $timeString';
      } else {
        return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')} $timeString';
      }
    } catch (e) {
      return dateString; // Возвращаем исходную строку если не удалось распарсить
    }
  }

  Color _getDateColor(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = date.difference(now).inHours;
      
      if (difference < 0) {
        return Colors.red[600]!; // Просрочено
      } else if (difference < 24) {
        return Colors.orange[600]!; // Скоро
      } else {
        return Colors.grey[600]!; // Обычное
      }
    } catch (e) {
      return Colors.grey[600]!;
    }
  }

  void _showTaskHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Заголовок
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'История задач',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            
            // Подзаголовок
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Выберите день для просмотра задач',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Календарь
            Expanded(
              child: TableCalendar<String>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _selectedDay,
                calendarFormat: CalendarFormat.month,
                eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(color: Colors.red[400]),
                  holidayTextStyle: TextStyle(color: Colors.red[600]),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.blue[300],
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                  });
                  Navigator.pop(context);
                  _showDayTasks(selectedDay);
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
              ),
            ),
            
            // Нижняя панель с информацией
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.blue[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Дни с сохраненными задачами',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getEventsForDay(DateTime day) {
    final dateKey = '${day.year}-${day.month}-${day.day}';
    
    if (_savedDates.contains(dateKey)) {
      return ['saved']; // Индикатор что есть сохраненные данные
    }
    return [];
  }

  void _showDayTasks(DateTime selectedDay) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DayTasksScreen(selectedDay: selectedDay),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.task_alt_rounded,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Пока нет задач',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Создайте свою первую задачу\nи начните планировать день',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddTaskDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Создать задачу',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksProvider = Provider.of<TasksProvider>(context);
    final groupedTasks = tasksProvider.groupedTasks;
    final isLoading = tasksProvider.isLoading;
    final error = tasksProvider.error;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.black,
            ),
          ),
        ),
        title: Text(
          _isEditMode ? 'Редактирование' : 'Мои задачи',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        actions: [
          // Кнопка истории
          IconButton(
            onPressed: _showTaskHistory,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 20,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Кнопка настроек/редактирования
          IconButton(
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isEditMode ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isEditMode ? Icons.check : Icons.settings,
                size: 20,
                color: _isEditMode ? Theme.of(context).primaryColor : Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: !_isEditMode && groupedTasks != null && groupedTasks.isNotEmpty ? Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: _showAddTaskDialog,
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 8,
          extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 24,
          ),
          label: const Text(
            'Новая задача',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ) : null,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Ошибка загрузки',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => Provider.of<TasksProvider>(
                            context,
                            listen: false,
                          ).loadData(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Попробовать снова'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                             : groupedTasks == null || groupedTasks.isEmpty
                   ? _buildEmptyState()
                   : Column(
                       children: [
                         if (_isEditMode)
                           Container(
                             width: double.infinity,
                             margin: const EdgeInsets.all(16),
                             padding: const EdgeInsets.all(16),
                             decoration: BoxDecoration(
                               color: Theme.of(context).primaryColor.withOpacity(0.1),
                               borderRadius: BorderRadius.circular(12),
                               border: Border.all(
                                 color: Theme.of(context).primaryColor.withOpacity(0.3),
                               ),
                             ),
                             child: Row(
                               children: [
                                 Icon(
                                   Icons.info_outline,
                                   color: Theme.of(context).primaryColor,
                                   size: 20,
                                 ),
                                 const SizedBox(width: 12),
                                 Expanded(
                                   child: Text(
                                     'Режим редактирования: перетаскивайте задачи и категории для изменения порядка',
                                     style: TextStyle(
                                       color: Theme.of(context).primaryColor,
                                       fontWeight: FontWeight.w500,
                                       fontSize: 14,
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                           ),
                         Expanded(
                           child: RefreshIndicator(
                             onRefresh: () async {
                               await Provider.of<TasksProvider>(
                                 context,
                                 listen: false,
                               ).loadData();
                             },
                             child: _isEditMode 
                               ? ReorderableListView.builder(
                                   padding: const EdgeInsets.only(bottom: 100),
                                   itemCount: groupedTasks.length,
                                   onReorder: (oldIndex, newIndex) {
                                     _reorderCategories(oldIndex, newIndex);
                                   },
                                   itemBuilder: (context, index) {
                                     final group = groupedTasks[index];
                                     return Container(
                                       key: ValueKey(group.category.id),
                                       child: _buildCategorySection(
                                         group.category.name,
                                         group.tasks,
                                         index,
                                       ),
                                     );
                                   },
                                 )
                               : ListView.builder(
                                   padding: const EdgeInsets.only(bottom: 100),
                                   itemCount: groupedTasks.length,
                                   itemBuilder: (context, index) {
                                     final group = groupedTasks[index];
                                     return _buildCategorySection(
                                       group.category.name,
                                       group.tasks,
                                       index,
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
