import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/finance/finance_goal.dart';
import '../../../providers/finance_provider.dart';

class FinanceGoalFormScreen extends StatefulWidget {
  final FinancialGoal? goal;

  const FinanceGoalFormScreen({
    super.key,
    this.goal,
  });

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

    // Если редактируем существующую цель, заполняем поля данными
    if (widget.goal != null) {
      _nameController.text = widget.goal!.name;
      _descriptionController.text = widget.goal!.description ?? '';
      _targetAmountController.text = widget.goal!.targetAmount.toString();
      _initialAmountController.text = widget.goal!.currentAmount.toString();
      _selectedPriority = widget.goal!.priority;
      _targetDate = widget.goal!.targetDate;
    } else {
      // По умолчанию начальная сумма равна 0
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
        title: Text(widget.goal == null ? 'Add Financial Goal' : 'Edit Financial Goal'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Название цели
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Goal Name',
                hintText: 'e.g. New Car, Vacation, Emergency Fund',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter goal name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Other form fields remain the same...

            // Кнопка сохранения
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _submitForm,
              child: Text(
                widget.goal == null ? 'Create Goal' : 'Update Goal',
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
      // Get provider before async operations
      final provider = Provider.of<FinanceProvider>(context, listen: false);

      // Calculations
      final targetAmount = double.parse(_targetAmountController.text);
      final currentAmount = double.parse(_initialAmountController.text);
      final progress = (currentAmount / targetAmount * 100).clamp(0.0, 100.0);
      final daysRemaining = _targetDate.difference(DateTime.now()).inDays;

      // Create goal object
      final goal = FinancialGoal(
        id: widget.goal?.id ?? 0, // This should be nullable in the model
        name: _nameController.text,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        progress: progress,
        targetDate: _targetDate,
        daysRemaining: daysRemaining,
        priority: _selectedPriority,
        status: 'active',
        amountNeededPerDay: daysRemaining > 0 ? (targetAmount - currentAmount) / daysRemaining : 0,
      );

      // Save and handle result
      bool success = false;

      if (widget.goal == null) {
        // Create new goal
        final result = await provider.createFinancialGoal(goal);
        success = result != null;
      } else if (widget.goal?.id != null) {
        // Update existing goal with non-null ID
        final result = await provider.updateFinancialGoal(widget.goal!.id!, goal);
        success = result != null;
      }

      // Moved outside the async gap and checking mounted
      if (!mounted) return;

      // Show result
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save goal. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Ensure mounted before using context
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Final mounted check
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}