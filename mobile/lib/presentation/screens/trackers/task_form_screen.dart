import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/models/task_category.dart';
import 'package:mobile/data/repositories/tasks/task_repository.dart';

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
  final _formKey = GlobalKey<FormState>();
  final TaskRepository _taskRepository = TaskRepository();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  int _priority = 1;
  int? _selectedCategoryId;
  bool _isCompleted = false;
  bool _isLoading = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _selectedDate = widget.task?.dueDate ?? DateTime.now();
    _priority = widget.task?.priority ?? 1;
    
    if (widget.task?.categoryId != null) {
      final categoryExists = widget.categories.any((category) => category.id == widget.task!.categoryId);
      if (categoryExists) {
        _selectedCategoryId = widget.task!.categoryId;
      }
    }
    
    if (_selectedCategoryId == null && widget.categories.isNotEmpty) {
      _selectedCategoryId = widget.categories.first.id;
    }
    
    _isCompleted = widget.task?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _disposed = true;
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _safeSetState(VoidCallback fn) {
    if (!_disposed && mounted) {
      setState(fn);
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      _safeSetState(() {
        _isLoading = true;
      });

      try {
        final task = Task(
          id: widget.task?.id,
          title: _titleController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          priority: _priority,
          categoryId: _selectedCategoryId!,
          dueDate: _selectedDate,
          isCompleted: _isCompleted,
        );

        if (widget.task == null) {
          await _taskRepository.createTask(task);
        } else {
          await _taskRepository.updateTask(task);
        }

        if (!mounted) return;
        widget.onSave();
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          _safeSetState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 1:
        return 'Низкий';
      case 2:
        return 'Средний';
      case 3:
        return 'Высокий';
      default:
        return 'Неизвестно';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Новая задача' : 'Редактирование задачи'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              widget.categories.isEmpty
                ? const Text('Нет доступных категорий. Пожалуйста, создайте категорию сначала.')
                : DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Категория',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _safeSetState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Пожалуйста, выберите категорию';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Срок выполнения'),
                subtitle: Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null && mounted) {
                    _safeSetState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text('Приоритет'),
              Slider(
                value: _priority.toDouble(),
                min: 1,
                max: 3,
                divisions: 2,
                label: _getPriorityLabel(_priority),
                onChanged: (value) {
                  _safeSetState(() {
                    _priority = value.toInt();
                  });
                },
              ),
              
              if (widget.task != null)
                CheckboxListTile(
                  title: const Text('Выполнено'),
                  value: _isCompleted,
                  onChanged: (value) {
                    _safeSetState(() {
                      _isCompleted = value ?? false;
                    });
                  },
                ),
              
              const SizedBox(height: 24),
              
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: widget.categories.isEmpty ? null : _saveTask,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        widget.task == null ? 'Создать задачу' : 'Сохранить изменения',
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}