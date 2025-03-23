import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/finance/finance_budget.dart';
import '../../../providers/finance_provider.dart';

class FinanceBudgetFormScreen extends StatefulWidget {
  final Budget? budget;

  const FinanceBudgetFormScreen({
    super.key,
    this.budget,
  });

  @override
  State<FinanceBudgetFormScreen> createState() => _FinanceBudgetFormScreenState();
}

class _FinanceBudgetFormScreenState extends State<FinanceBudgetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedPeriod = 'month';
  int? _selectedCategoryId;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.budget != null) {
      _amountController.text = widget.budget!.amount.toString();
      _selectedPeriod = widget.budget!.period;
      _selectedCategoryId = widget.budget!.categoryId;
      _startDate = widget.budget!.startDate ?? _startDate;
      _endDate = widget.budget!.endDate ?? _endDate;
      _notesController.text = widget.budget!.notes ?? '';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<FinanceProvider>(context, listen: false);
      provider.getCategories();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateDatesBasedOnPeriod(String period) {
    final now = DateTime.now();

    switch (period) {
      case 'day':
        _startDate = now;
        _endDate = now;
        break;
      case 'week':
        final weekday = now.weekday;
        _startDate = now.subtract(Duration(days: weekday - 1));
        _endDate = _startDate.add(const Duration(days: 6));
        break;
      case 'month':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'year':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = DateTime(now.year, 12, 31);
        break;
      case 'custom':
        break;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final expenseCategories = provider.categories
        .where((c) => c.type == 'expense')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budget == null ? 'Add Budget' : 'Edit Budget'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              value: _selectedCategoryId,
              items: expenseCategories.map((category) =>
                  DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(category.name),
                  )
              ).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Budget Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (double.parse(value) <= 0) {
                  return 'Amount must be greater than zero';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Period',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              value: _selectedPeriod,
              items: const [
                DropdownMenuItem(value: 'day', child: Text('Day')),
                DropdownMenuItem(value: 'week', child: Text('Week')),
                DropdownMenuItem(value: 'month', child: Text('Month')),
                DropdownMenuItem(value: 'year', child: Text('Year')),
                DropdownMenuItem(value: 'custom', child: Text('Custom')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                  if (value != 'custom') {
                    _updateDatesBasedOnPeriod(value);
                  }
                });
              },
            ),

            const SizedBox(height: 16),

            if (_selectedPeriod == 'custom')
              Column(
                children: [
                  ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                          if (_endDate.isBefore(_startDate)) {
                            _endDate = _startDate;
                          }
                        });
                      }
                    },
                  ),

                  ListTile(
                    title: const Text('End Date'),
                    subtitle: Text('${_endDate.day}/${_endDate.month}/${_endDate.year}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: _startDate,
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
                  ),
                ],
              ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _submitForm,
              child: Text(
                widget.budget == null ? 'Create Budget' : 'Update Budget',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<FinanceProvider>(context, listen: false);

      final budget = Budget(
        id: widget.budget?.id ?? 0,
        categoryId: _selectedCategoryId!,
        amount: double.parse(_amountController.text),
        spent: widget.budget?.spent ?? 0.0,
        remaining: 0,
        percentageUsed: 0,
        period: _selectedPeriod,
        startDate: _startDate,
        endDate: _endDate,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      bool success;
      if (widget.budget == null) {
        final result = await provider.createBudget(budget);
        success = result != null;
      } else {
        final result = await provider.updateBudget(widget.budget!.id, budget);
        success = result != null;
      }

      if (!mounted) return;

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось сохранить бюджет. Пожалуйста, попробуйте снова.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}