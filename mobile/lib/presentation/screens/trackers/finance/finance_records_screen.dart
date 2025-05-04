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
  String _selectedPeriod = 'month';
  String? _selectedType;
  int? _selectedCategoryId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isFilterExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽');

    return Scaffold(
      appBar: AppBar(
        title: const Text('История операций'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed:
                () => setState(() => _isFilterExpanded = !_isFilterExpanded),
            tooltip: 'Фильтры',
          ),
        ],
      ),
      body: Column(
        children: [
          // Анимированная панель фильтров
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child:
                _isFilterExpanded ? _buildFilterPanel(theme) : const SizedBox(),
          ),

          // Основной контент
          Expanded(child: _buildContent(theme, currencyFormat)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddRecord(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildFilterPanel(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Период
            _buildFilterDropdown(
              label: 'Период',
              value: _selectedPeriod,
              items: const [
                DropdownMenuItem(value: 'day', child: Text('Сегодня')),
                DropdownMenuItem(value: 'week', child: Text('Неделя')),
                DropdownMenuItem(value: 'month', child: Text('Месяц')),
                DropdownMenuItem(value: 'year', child: Text('Год')),
                DropdownMenuItem(value: 'custom', child: Text('Выбрать даты')),
              ],
              onChanged: (value) => _updatePeriod(value as String),
            ),

            // Диапазон дат (если выбран "Выбрать даты")
            if (_selectedPeriod == 'custom') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      'Начало',
                      _startDate,
                      (date) => _startDate = date,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDatePicker(
                      'Конец',
                      _endDate,
                      (date) => _endDate = date,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // Тип операции
            _buildFilterDropdown(
              label: 'Тип операции',
              value: _selectedType,
              items: const [
                DropdownMenuItem(value: null, child: Text('Все операции')),
                DropdownMenuItem(value: 'income', child: Text('Доходы')),
                DropdownMenuItem(value: 'expense', child: Text('Расходы')),
              ],
              onChanged: (value) => _updateType(value as String?),
            ),

            const SizedBox(height: 16),

            // Кнопки управления фильтрами
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    child: const Text('Сбросить'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => setState(() => _isFilterExpanded = false),
                    child: const Text('Применить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, NumberFormat currencyFormat) {
    final provider = Provider.of<FinanceProvider>(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Ошибка загрузки', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loadRecords,
              child: const Text('Повторить попытку'),
            ),
          ],
        ),
      );
    }

    if (provider.records.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: _loadRecords,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: provider.records.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final record = provider.records[index];
          final showDate =
              index == 0 ||
              !_isSameDay(provider.records[index - 1].date, record.date);

          return Column(
            children: [
              if (showDate) _buildDateHeader(record.date, theme),
              _buildTransactionCard(record, currencyFormat, theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(
    FinanceRecord record,
    NumberFormat currencyFormat,
    ThemeData theme,
  ) {
    final isIncome = record.type == 'income';
    final icon =
        isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final color = isIncome ? Colors.green : Colors.red;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          record.categoryName ?? 'Без категории',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          record.description?.isNotEmpty == true
              ? record.description!
              : DateFormat('HH:mm').format(record.date),
          style: theme.textTheme.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(record.amount),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (record.categoryName != null)
              Text(record.categoryName!, style: theme.textTheme.bodySmall),
          ],
        ),
        onTap: () => _navigateToEditRecord(context, record),
      ),
    );
  }

  Widget _buildDateHeader(DateTime date, ThemeData theme) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    String title;

    if (_isSameDay(date, now)) {
      title = 'Сегодня';
    } else if (_isSameDay(date, yesterday)) {
      title = 'Вчера';
    } else {
      title = DateFormat('EEEE, d MMMM', 'ru_RU').format(date);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Нет операций',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Измените фильтры или добавьте новую операцию',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.add_rounded),
            label: const Text('Добавить операцию'),
            onPressed: () => _navigateToAddRecord(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required dynamic value,
    required List<DropdownMenuItem<dynamic>> items,
    required ValueChanged<dynamic> onChanged,
  }) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      value: value,
      items: items,
      onChanged: onChanged,
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? date,
    ValueChanged<DateTime> onDateSelected,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (selected != null) onDateSelected(selected);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null ? DateFormat('dd.MM.yyyy').format(date) : 'Выбрать',
            ),
            const Icon(Icons.calendar_today_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  // Методы для работы с данными
  Future<void> _loadRecords() async {
    await Provider.of<FinanceProvider>(
      context,
      listen: false,
    ).getFinanceRecords(
      period: _selectedPeriod,
      type: _selectedType,
      categoryId: _selectedCategoryId,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  void _updatePeriod(String period) {
    setState(() {
      _selectedPeriod = period;
      if (period != 'custom') {
        _startDate = null;
        _endDate = null;
      }
    });
    _loadRecords();
  }

  void _updateType(String? type) {
    setState(() {
      _selectedType = type;
      _selectedCategoryId = null;
    });
    _loadRecords();
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _navigateToAddRecord(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FinanceRecordFormScreen()),
    ).then((_) => _loadRecords());
  }

  void _navigateToEditRecord(BuildContext context, FinanceRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinanceRecordFormScreen(record: record),
      ),
    ).then((_) => _loadRecords());
  }
}
