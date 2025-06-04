import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/finance/finance_record.dart';
import 'package:mobile/presentation/providers/finance_provider.dart';
import 'package:mobile/presentation/screens/trackers/finance/finance_record_form_screen.dart';
import 'package:provider/provider.dart';

class FinanceRecordsScreen extends StatefulWidget {
  const FinanceRecordsScreen({super.key});

  @override
  State<FinanceRecordsScreen> createState() => _FinanceRecordsScreenState();
}

class _FinanceRecordsScreenState extends State<FinanceRecordsScreen> {
  String? _selectedPeriod = 'month';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isFilterExpanded = false;

  late NumberFormat currencyFormat;

  @override
  void initState() {
    super.initState();
    currencyFormat = NumberFormat.currency(
      locale: 'kk_KZ',
      symbol: '₸',
      decimalDigits: 0,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecords());
  }

  Future<void> _loadRecords() async {
    final isCustom = _selectedPeriod == 'custom';

    await Provider.of<FinanceProvider>(
      context,
      listen: false,
    ).getFinanceRecords(
      period: isCustom ? null : _selectedPeriod,
      startDate: isCustom ? _startDate : null,
      endDate: isCustom ? _endDate : null,
    );
  }

  void _applyFilters() {
    setState(() => _isFilterExpanded = false);
    _loadRecords();
  }

  void _resetFilters() {
    setState(() {
      _selectedPeriod = 'month';
      _startDate = null;
      _endDate = null;
    });
    _loadRecords();
  }

  void _updatePeriod(String period) {
    setState(() {
      _selectedPeriod = period;
      if (period != 'custom') {
        _startDate = null;
        _endDate = null;
      }
    });
  }

  void _navigateToAddRecord(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FinanceRecordFormScreen()),
    ).then((_) => _loadRecords());
  }

  void _navigateToEditRecord(BuildContext context, FinanceRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FinanceRecordFormScreen(record: record),
      ),
    ).then((_) => _loadRecords());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Provider.of<FinanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('История операций'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed:
                () => setState(() => _isFilterExpanded = !_isFilterExpanded),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFF0F4F8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            if (_isFilterExpanded) _buildFilterPanel(theme),
            Expanded(child: _buildContent(theme)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddRecord(context),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }

  Widget _buildFilterPanel(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildDropdown(
            label: 'Период',
            value: _selectedPeriod,
            items: const [
              DropdownMenuItem(value: 'day', child: Text('Сегодня')),
              DropdownMenuItem(value: 'week', child: Text('Неделя')),
              DropdownMenuItem(value: 'month', child: Text('Месяц')),
              DropdownMenuItem(value: 'year', child: Text('Год')),
              DropdownMenuItem(value: 'custom', child: Text('Выбрать даты')),
            ],
            onChanged: (val) => _updatePeriod(val),
          ),
          if (_selectedPeriod == 'custom') ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    'Начало',
                    _startDate,
                    (d) => setState(() => _startDate = d),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDatePicker(
                    'Конец',
                    _endDate,
                    (d) => setState(() => _endDate = d),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilters,
                  child: const Text('Сбросить'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: _applyFilters,
                  child: const Text('Применить'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required dynamic value,
    required List<DropdownMenuItem<dynamic>> items,
    required ValueChanged<dynamic> onChanged,
  }) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? value,
    ValueChanged<DateTime> onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value != null
                  ? DateFormat('dd.MM.yyyy').format(value)
                  : 'Выбрать',
            ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final provider = Provider.of<FinanceProvider>(context);
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) return Center(child: Text(provider.error!));
    if (provider.records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Нет записей за выбранный период',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: provider.records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final record = provider.records[index];
        return _buildTransactionCard(record, theme);
      },
    );
  }

  Widget _buildTransactionCard(FinanceRecord record, ThemeData theme) {
    final isIncome = record.type == 'income';
    final color = isIncome ? Colors.green : Colors.red;
    final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;

    return InkWell(
      onTap: () => _navigateToEditRecord(context, record),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          title: Text(record.categoryName ?? 'Без категории'),
          subtitle: Text(
            record.description ?? DateFormat('dd.MM.yyyy').format(record.date),
          ),
          trailing: Text(
            currencyFormat.format(record.amount),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
