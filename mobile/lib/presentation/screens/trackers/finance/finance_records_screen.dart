import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/finance/finance_record.dart';
import '../../../providers/finance_provider.dart';
import 'finance_record_form_screen.dart';

class FinanceRecordsScreen extends StatefulWidget {
  const FinanceRecordsScreen({super.key});

  @override
  State<FinanceRecordsScreen> createState() => _FinanceRecordsScreenState();
}

class _FinanceRecordsScreenState extends State<FinanceRecordsScreen> {
  String _selectedPeriod = 'month';
  String? _selectedType;
  int? _selectedCategoryId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    await provider.getFinanceRecords(
      period: _selectedPeriod,
      type: _selectedType,
      categoryId: _selectedCategoryId,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedPeriod = 'month';
      _selectedType = null;
      _selectedCategoryId = null;
      _startDate = null;
      _endDate = null;
    });
    _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final records = provider.records;
    final summary = provider.summary;

    return Scaffold(
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadRecords,
        child: Column(
          children: [
            // Фильтры
            _buildFilterSection(),

            // Сводка
            if (summary != null) _buildSummaryCard(summary),

            // Список транзакций
            Expanded(
              child: records.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No transactions found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try changing filters or add a new transaction',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToAddRecord(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Transaction'),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];

                  // Группировка по дате (показываем заголовок с датой для новой группы)
                  final bool showDateHeader = index == 0 ||
                      !_isSameDay(records[index - 1].date, record.date);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showDateHeader) _buildDateHeader(record.date),

                      _buildRecordItem(record),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddRecord(context),
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterSection() {
    final provider = Provider.of<FinanceProvider>(context);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Заголовок с кнопкой раскрытия/скрытия
          ListTile(
            title: const Text('Filters'),
            trailing: IconButton(
              icon: Icon(_isFilterExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isFilterExpanded = !_isFilterExpanded;
                });
              },
            ),
          ),

          // Содержимое фильтров (показывается только если фильтры раскрыты)
          if (_isFilterExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Период
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Period',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedPeriod,
                    items: const [
                      DropdownMenuItem(value: 'day', child: Text('Today')),
                      DropdownMenuItem(value: 'week', child: Text('This Week')),
                      DropdownMenuItem(value: 'month', child: Text('This Month')),
                      DropdownMenuItem(value: 'year', child: Text('This Year')),
                      DropdownMenuItem(value: 'custom', child: Text('Custom Date Range')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPeriod = value!;
                        if (value != 'custom') {
                          _startDate = null;
                          _endDate = null;
                        }
                      });
                      _loadRecords();
                    },
                  ),

                  const SizedBox(height: 16),

                  // Пользовательский диапазон дат (если выбран период 'custom')
                  if (_selectedPeriod == 'custom')
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _startDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() {
                                  _startDate = date;
                                  if (_endDate != null && _endDate!.isBefore(_startDate!)) {
                                    _endDate = _startDate;
                                  }
                                });
                                _loadRecords();
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Start Date',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _startDate == null
                                    ? 'Select Date'
                                    : DateFormat('dd/MM/yyyy').format(_startDate!),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              if (_startDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select start date first'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              final date = await showDatePicker(
                                context: context,
                                initialDate: _endDate ?? DateTime.now(),
                                firstDate: _startDate!,
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() {
                                  _endDate = date;
                                });
                                _loadRecords();
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'End Date',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _endDate == null
                                    ? 'Select Date'
                                    : DateFormat('dd/MM/yyyy').format(_endDate!),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Тип транзакции
                  DropdownButtonFormField<String?>(
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedType,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Types')),
                      DropdownMenuItem(value: 'expense', child: Text('Expense')),
                      DropdownMenuItem(value: 'income', child: Text('Income')),
                      DropdownMenuItem(value: 'saving', child: Text('Saving')),
                      DropdownMenuItem(value: 'investment', child: Text('Investment')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                        // Сбрасываем выбранную категорию при изменении типа
                        _selectedCategoryId = null;
                      });
                      _loadRecords();
                    },
                  ),

                  const SizedBox(height: 16),

                  // Категория
                  DropdownButtonFormField<int?>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCategoryId,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Categories')),
                      ...provider.categories
                          .where((c) => _selectedType == null || c.type == _selectedType)
                          .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                      _loadRecords();
                    },
                  ),

                  const SizedBox(height: 16),

                  // Кнопка сброса фильтров
                  ElevatedButton.icon(
                    onPressed: _resetFilters,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Filters'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(dynamic summary) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Income',
                    currencyFormat.format(summary.totalIncome),
                    Icons.arrow_downward,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Expenses',
                    currencyFormat.format(summary.totalExpense),
                    Icons.arrow_upward,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Savings',
                    currencyFormat.format(summary.totalSaving),
                    Icons.savings,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Investments',
                    currencyFormat.format(summary.totalInvestment),
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Balance',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currencyFormat.format(summary.balance),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.2 * 255),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    String headerText;

    if (_isSameDay(date, now)) {
      headerText = 'Today';
    } else if (_isSameDay(date, yesterday)) {
      headerText = 'Yesterday';
    } else {
      headerText = DateFormat('EEEE, MMMM d, y').format(date);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        headerText,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRecordItem(FinanceRecord record) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(record.type).withValues(alpha: 0.2 * 255),
          child: Icon(
            _getTypeIcon(record.type),
            color: _getTypeColor(record.type),
            size: 20,
          ),
        ),
        title: Text(
          record.categoryName ?? 'Unknown Category',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          record.description ?? DateFormat('h:mm a').format(record.date),
        ),
        trailing: Text(
          currencyFormat.format(record.amount),
          style: TextStyle(
            color: _getTypeColor(record.type),
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => _navigateToEditRecord(context, record),
      ),
    );
  }

  // Вспомогательные функции
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'income':
        return Icons.arrow_downward;
      case 'expense':
        return Icons.arrow_upward;
      case 'saving':
        return Icons.savings;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.receipt;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'income':
        return Colors.green;
      case 'expense':
        return Colors.red;
      case 'saving':
        return Colors.blue;
      case 'investment':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _navigateToAddRecord(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FinanceRecordFormScreen(),
      ),
    ).then((value) {
      if (value == true) {
        _loadRecords();
      }
    });
  }

  void _navigateToEditRecord(BuildContext context, FinanceRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinanceRecordFormScreen(record: record),
      ),
    ).then((value) {
      if (value == true) {
        _loadRecords();
      }
    });
  }
}