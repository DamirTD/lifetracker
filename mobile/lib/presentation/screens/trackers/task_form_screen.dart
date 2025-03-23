import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/models/task_category.dart';
import 'package:mobile/presentation/providers/tasks.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  final List<TaskCategory> categories;
  final Function onSave;

  const TaskFormScreen({
    super.key,
    this.task,
    required this.categories,
    required this.onSave,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey               = GlobalKey<FormState>();
  final _titleController       = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime?     _selectedDate;
  TaskCategory? _selectedCategory;

  int _selectedPriority = 1;
  bool _isLoading       = false;


  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';

      if (widget.task!.dueDate != null && widget.task!.dueDate!.isNotEmpty) {
        try {
          _selectedDate = DateFormat('dd.MM.yyyy').parse(widget.task!.dueDate!);
        } catch (e) {
          try {
            _selectedDate = DateTime.parse(widget.task!.dueDate!);
          } catch (_) {
            _selectedDate = null;
          }
        }
      } else {
        _selectedDate = null;
      }

      _selectedPriority = widget.task!.priority;

      if (widget.categories.isNotEmpty) {
        _selectedCategory = widget.categories.firstWhere(
              (category) => category.id == widget.task!.categoryId,
          orElse: () => widget.categories.first,
        );
      }
    } else {
      _selectedDate     = null;
      _selectedCategory = widget.categories.isNotEmpty ? widget.categories.first : null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
    });
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final formattedDate = _selectedDate != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDate!)
            : null;

        final task = Task(
          id: widget.task?.id,
          title: _titleController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          priority: _selectedPriority,
          categoryId: _selectedCategory!.id!,
          dueDate: formattedDate,
          isCompleted: widget.task?.isCompleted ?? false,
        );

        final tasksProvider = Provider.of<TasksProvider>(context, listen: false);

        if (widget.task == null) {
          await tasksProvider.createTask(task);
        } else {
          if (task.id != null) {
            final data = {
              'title': task.title,
              'description': task.description,
              'priority': task.priority,
              'category_id': task.categoryId,
              'due_date': task.dueDate,
            };
            await tasksProvider.updateTask(task.id!, data);
          }
        }

        widget.onSave();
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Новая задача' : 'Редактирование задачи'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название задачи',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите название задачи';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание (опционально)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskCategory>(
              decoration: const InputDecoration(
                labelText: 'Категория',
                border: OutlineInputBorder(),
              ),
              value: _selectedCategory,
              items: widget.categories.map((category) {
                return DropdownMenuItem<TaskCategory>(
                  value: category,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (TaskCategory? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Выберите категорию';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Приоритет'),
              trailing: DropdownButton<int>(
                value: _selectedPriority,
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Низкий'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Средний'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Высокий'),
                      ],
                    ),
                  ),
                ],
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedPriority = newValue;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            // Due date section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 12.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Text('Срок выполнения'),
                      SizedBox(width: 4),
                      Text('(опционально)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _selectedDate == null
                              ? const Text('Не указан')
                              : Text(DateFormat('dd.MM.yyyy').format(_selectedDate!)),
                        ),
                        const SizedBox(width: 8),
                        // Use a more compact layout for buttons
                        if (_selectedDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: _clearDate,
                            tooltip: 'Очистить дату',
                          ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.calendar_today, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _selectDate(context),
                          tooltip: 'Выбрать дату',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(widget.task == null ? 'Создать задачу' : 'Сохранить изменения'),
            ),
          ],
        ),
      ),
    );
  }
}