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
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  TaskCategory? _selectedCategory;
  int _selectedPriority = 1;
  bool _isLoading = false;

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
      }

      _selectedPriority = widget.task!.priority;

      if (widget.categories.isNotEmpty) {
        _selectedCategory = widget.categories.firstWhere(
          (category) => category.id == widget.task!.categoryId,
          orElse: () => widget.categories.first,
        );
      }
    } else {
      _selectedCategory =
          widget.categories.isNotEmpty ? widget.categories.first : null;
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
      setState(() => _isLoading = true);

      try {
        final formattedDate =
            _selectedDate != null
                ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDate!)
                : null;

        final task = Task(
          id: widget.task?.id,
          title: _titleController.text,
          description:
              _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
          priority: _selectedPriority,
          categoryId: _selectedCategory!.id!,
          dueDate: formattedDate,
          isCompleted: widget.task?.isCompleted ?? false,
        );

        final tasksProvider = Provider.of<TasksProvider>(
          context,
          listen: false,
        );

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
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Ошибка: ${e.toString()}')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Новая задача' : 'Редактирование'),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildSectionTitle('Основное'),
                      _buildInputCard(
                        child: TextFormField(
                          controller: _titleController,
                          decoration: _inputDecoration('Название', Icons.edit),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Введите название'
                                      : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInputCard(
                        child: TextFormField(
                          controller: _descriptionController,
                          decoration: _inputDecoration('Описание', Icons.notes),
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Категория и приоритет'),
                      _buildInputCard(
                        child: DropdownButtonFormField<TaskCategory>(
                          decoration: _inputDecoration(
                            'Категория',
                            Icons.category,
                          ),
                          value: _selectedCategory,
                          items:
                              widget.categories
                                  .map(
                                    (cat) => DropdownMenuItem(
                                      value: cat,
                                      child: Text(cat.name),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (newValue) => setState(() {
                                _selectedCategory = newValue;
                              }),
                          validator:
                              (value) =>
                                  value == null ? 'Выберите категорию' : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInputCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Приоритет'),
                          trailing: DropdownButton<int>(
                            value: _selectedPriority,
                            underline: const SizedBox(),
                            items: [
                              _priorityItem(1, 'Низкий', Colors.green),
                              _priorityItem(2, 'Средний', Colors.orange),
                              _priorityItem(3, 'Высокий', Colors.red),
                            ],
                            onChanged:
                                (newValue) => setState(() {
                                  if (newValue != null)
                                    _selectedPriority = newValue;
                                }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Срок'),
                      _buildInputCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            _selectedDate != null
                                ? DateFormat(
                                  'dd.MM.yyyy',
                                ).format(_selectedDate!)
                                : 'Дата не выбрана',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_selectedDate != null)
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: _clearDate,
                                ),
                              IconButton(
                                icon: const Icon(Icons.edit_calendar),
                                onPressed: () => _selectDate(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: Text(
                            widget.task == null ? 'Создать' : 'Сохранить',
                          ),
                          onPressed: _saveTask,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildInputCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: child,
      ),
    );
  }

  DropdownMenuItem<int> _priorityItem(int value, String label, Color color) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(Icons.flag, color: color),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
