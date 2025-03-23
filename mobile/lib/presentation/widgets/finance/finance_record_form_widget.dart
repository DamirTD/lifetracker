import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/finance/finance_record.dart';
import '../../providers/finance_provider.dart';

class FinanceRecordFormWidget extends StatefulWidget {
  final FinanceRecord? record;
  final Function(bool success)? onComplete;

  const FinanceRecordFormWidget({
    super.key,
    this.record,
    this.onComplete,
  });

  @override
  State<FinanceRecordFormWidget> createState() => FinanceRecordFormWidgetState();
}

class FinanceRecordFormWidgetState extends State<FinanceRecordFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  String _selectedType = 'expense';
  String _selectedPeriod = 'month';
  int? _selectedCategoryId;
  late DateTime _selectedDate;
  late TextEditingController _descriptionController;
  bool _isRecurring = false;
  String? _recurringFrequency;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController(
      text: widget.record?.amount.toString() ?? '',
    );

    _selectedType = widget.record?.type ?? 'expense';
    _selectedPeriod = widget.record?.period ?? 'month';
    _selectedCategoryId = widget.record?.categoryId;
    _selectedDate = widget.record?.date ?? DateTime.now();

    _descriptionController = TextEditingController(
      text: widget.record?.description ?? '',
    );

    _isRecurring = widget.record?.isRecurring ?? false;
    _recurringFrequency = widget.record?.recurringFrequency;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<FinanceProvider>(context, listen: false);
      provider.getCategories(type: _selectedType);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadCategories() {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    provider.getCategories(type: _selectedType);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Field
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(value: 'expense', child: Text('Expense')),
                DropdownMenuItem(value: 'income', child: Text('Income')),
                DropdownMenuItem(value: 'saving', child: Text('Saving')),
                DropdownMenuItem(
                    value: 'investment', child: Text('Investment')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                  _selectedCategoryId =
                  null;
                });
                _loadCategories();
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedPeriod,
              decoration: const InputDecoration(
                labelText: 'Period',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              items: const [
                DropdownMenuItem(value: 'day', child: Text('Day')),
                DropdownMenuItem(value: 'week', child: Text('Week')),
                DropdownMenuItem(value: 'month', child: Text('Month')),
                DropdownMenuItem(value: 'year', child: Text('Year')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.folder),
              ),
              items: provider.categories
                  .where((category) => category.type == _selectedType)
                  .map((category) =>
                  DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  ))
                  .toList(),
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

            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Date'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate
                    .year}',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            CheckboxListTile(
              title: const Text('Recurring'),
              value: _isRecurring,
              onChanged: (value) {
                setState(() {
                  _isRecurring = value ?? false;
                  if (!_isRecurring) {
                    _recurringFrequency = null;
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),

            if (_isRecurring)
              DropdownButtonFormField<String>(
                value: _recurringFrequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                ],
                onChanged: (value) {
                  setState(() {
                    _recurringFrequency = value;
                  });
                },
                validator: (value) {
                  if (_isRecurring && (value == null || value.isEmpty)) {
                    return 'Please select a frequency';
                  }
                  return null;
                },
              ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.isLoading
                    ? null
                    : () => _submitForm(),
                child: provider.isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                    widget.record == null ? 'Create Record' : 'Update Record'),
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
    });

    try {
      final provider = Provider.of<FinanceProvider>(context, listen: false);

      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text;

      final record = FinanceRecord(
        id: widget.record?.id ?? 0,
        amount: amount,
        type: _selectedType,
        period: _selectedPeriod,
        categoryId: _selectedCategoryId ?? 0,
        date: _selectedDate,
        description: description.isNotEmpty ? description : null,
        isRecurring: _isRecurring,
        recurringFrequency: _isRecurring ? _recurringFrequency : null,
      );

      bool success = false;

      if (widget.record == null) {
        final createdRecord = await provider.createFinanceRecord(record);
        success = createdRecord != null;
      } else {
        final updatedRecord = await provider.updateFinanceRecord(
            widget.record!.id, record);
        success = updatedRecord != null;
      }

      if (!mounted) return;

      if (widget.onComplete != null) {
        widget.onComplete!(success);
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
        });
      }
    }
  }
}