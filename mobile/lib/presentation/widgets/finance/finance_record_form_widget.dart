import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/finance/finance_record.dart';
import '../../providers/finance_provider.dart';

class FinanceRecordFormWidget extends StatefulWidget {
  final FinanceRecord? record;
  final Function(bool success)? onComplete;

  const FinanceRecordFormWidget({super.key, this.record, this.onComplete});

  @override
  State<FinanceRecordFormWidget> createState() =>
      FinanceRecordFormWidgetState();
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
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок формы
            Text(
              widget.record == null ? 'Новая запись' : 'Редактирование записи',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // Сумма
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Сумма',
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    '₸',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите сумму';
                }
                if (double.tryParse(value) == null) {
                  return 'Пожалуйста, введите корректное число';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Тип операции
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Тип операции',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: const [
                DropdownMenuItem(value: 'expense', child: Text('Расход')),
                DropdownMenuItem(value: 'income', child: Text('Доход')),
                DropdownMenuItem(value: 'saving', child: Text('Накопление')),
                DropdownMenuItem(
                  value: 'investment',
                  child: Text('Инвестиция'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                  _selectedCategoryId = null;
                });
                _loadCategories();
              },
            ),
            const SizedBox(height: 16),

            // Период
            DropdownButtonFormField<String>(
              value: _selectedPeriod,
              decoration: InputDecoration(
                labelText: 'Период',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: const [
                DropdownMenuItem(value: 'day', child: Text('День')),
                DropdownMenuItem(value: 'week', child: Text('Неделя')),
                DropdownMenuItem(value: 'month', child: Text('Месяц')),
                DropdownMenuItem(value: 'year', child: Text('Год')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Категория
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: InputDecoration(
                labelText: 'Категория',
                prefixIcon: const Icon(Icons.folder),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items:
                  provider.categories
                      .where((category) => category.type == _selectedType)
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
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

            // Дата
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: theme.copyWith(
                        colorScheme: theme.colorScheme.copyWith(
                          primary: theme.primaryColor,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Дата',
                  prefixIcon: const Icon(Icons.calendar_month),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDate.day.toString().padLeft(2, '0')}/'
                      '${_selectedDate.month.toString().padLeft(2, '0')}/'
                      '${_selectedDate.year}',
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Описание
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Описание',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Повторяющаяся операция
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Повторяющаяся операция'),
                      value: _isRecurring,
                      onChanged: (value) {
                        setState(() {
                          _isRecurring = value;
                          if (!_isRecurring) {
                            _recurringFrequency = null;
                          }
                        });
                      },
                      activeColor: theme.primaryColor,
                    ),
                    if (_isRecurring)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonFormField<String>(
                          value: _recurringFrequency ?? 'daily',
                          decoration: InputDecoration(
                            labelText: 'Периодичность',
                            prefixIcon: const Icon(Icons.repeat),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'daily',
                              child: Text('Ежедневно'),
                            ),
                            DropdownMenuItem(
                              value: 'weekly',
                              child: Text('Еженедельно'),
                            ),
                            DropdownMenuItem(
                              value: 'monthly',
                              child: Text('Ежемесячно'),
                            ),
                            DropdownMenuItem(
                              value: 'yearly',
                              child: Text('Ежегодно'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _recurringFrequency = value;
                            });
                          },
                          validator: (value) {
                            if (_isRecurring &&
                                (value == null || value.isEmpty)) {
                              return 'Пожалуйста, выберите периодичность';
                            }
                            return null;
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Кнопка сохранения
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                onPressed: provider.isLoading ? null : () => _submitForm(),
                child:
                    provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                          widget.record == null ? 'СОХРАНИТЬ' : 'ОБНОВИТЬ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final provider = Provider.of<FinanceProvider>(context, listen: false);

      final data = {
        'amount': double.parse(_amountController.text),
        'type': _selectedType,
        'period': _selectedPeriod,
        'category_id': _selectedCategoryId,
        'date': _selectedDate.toIso8601String(), // полностью, с временем
        'description':
            _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null,
        'is_recurring': _isRecurring,
        'recurring_frequency':
            (_isRecurring &&
                    _recurringFrequency != null &&
                    _recurringFrequency!.isNotEmpty)
                ? _recurringFrequency
                : null,
      };

      bool success = false;

      if (widget.record == null) {
        final createdRecord = await provider.createFinanceRecord(data);
        success = createdRecord != null;
      } else {
        final updatedRecord = await provider.updateFinanceRecord(
          widget.record!.id,
          data,
        );
        success = updatedRecord != null;
      }

      if (!mounted) return;
      widget.onComplete?.call(success);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
