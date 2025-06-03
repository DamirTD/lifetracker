import 'package:flutter/material.dart';
import 'package:mobile/data/models/finance/finance_goal.dart';
import 'package:mobile/presentation/providers/finance_provider.dart';
import 'package:provider/provider.dart';

class FinanceGoalFormScreen extends StatefulWidget {
  final FinancialGoal? goal;

  const FinanceGoalFormScreen({super.key, this.goal});

  @override
  State<FinanceGoalFormScreen> createState() => _FinanceGoalFormScreenState();
}

class _FinanceGoalFormScreenState extends State<FinanceGoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _initialAmountController = TextEditingController();

  String _selectedPriority = 'medium';
  DateTime _targetDate = DateTime.now().add(const Duration(days: 180));
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _nameController.text = widget.goal!.name;
      _descriptionController.text = widget.goal!.description ?? '';
      _targetAmountController.text = widget.goal!.targetAmount.toString();
      _initialAmountController.text = widget.goal!.currentAmount.toString();
      _selectedPriority = widget.goal!.priority;
      _targetDate = widget.goal!.targetDate;
    } else {
      _initialAmountController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _initialAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.goal == null ? 'Создать цель' : 'Редактировать цель',
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Название цели',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Введите название'
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _targetAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Целевая сумма',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите сумму';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Неверная сумма';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _initialAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Начальная сумма',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.savings),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final amount = double.tryParse(value ?? '');
                        if (amount == null || amount < 0) {
                          return 'Неверное значение';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Приоритет',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.priority_high),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Низкий')),
                        DropdownMenuItem(
                          value: 'medium',
                          child: Text('Средний'),
                        ),
                        DropdownMenuItem(value: 'high', child: Text('Высокий')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedPriority = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    InkWell(
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _targetDate,
                          firstDate: DateTime.now().add(
                            const Duration(days: 1),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 3650),
                          ),
                        );
                        if (selectedDate != null) {
                          setState(() => _targetDate = selectedDate);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Целевая дата',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          '${_targetDate.day.toString().padLeft(2, '0')}.${_targetDate.month.toString().padLeft(2, '0')}.${_targetDate.year}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Описание (необязательно)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.text_snippet),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: Text(widget.goal == null ? 'Создать' : 'Обновить'),
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<FinanceProvider>(context, listen: false);
      final targetAmount = double.parse(_targetAmountController.text);
      final currentAmount = double.parse(_initialAmountController.text);
      final daysRemaining = _targetDate.difference(DateTime.now()).inDays;
      final progress = (currentAmount / targetAmount * 100).clamp(0, 100);
      final amountPerDay =
          daysRemaining > 0
              ? (targetAmount - currentAmount) / daysRemaining
              : 0;

      final goal = FinancialGoal(
        id: widget.goal?.id,
        name: _nameController.text.trim(),
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        targetDate: _targetDate,
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        priority: _selectedPriority,
        status: 'active',
        progress: progress.toDouble(),
        daysRemaining: daysRemaining,
        amountNeededPerDay: amountPerDay.toDouble(),
      );

      final success =
          widget.goal == null
              ? await provider.createFinancialGoal(goal)
              : await provider.updateFinancialGoal(widget.goal!.id!, goal);

      if (!mounted) return;
      if (success != null) {
        Navigator.pop(context, true);
      } else {
        _showError('Не удалось сохранить цель');
      }
    } catch (e) {
      if (mounted) _showError('Ошибка: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
