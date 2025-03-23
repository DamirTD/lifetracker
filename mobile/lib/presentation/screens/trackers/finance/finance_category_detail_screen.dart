import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/finance/finance_category.dart';
import '../../../../data/models/finance/finance_record.dart';
import '../../../providers/finance_provider.dart';
import 'package:provider/provider.dart';

class FinanceCategoryDetailScreen extends StatefulWidget {
  final FinanceCategory category;

  const FinanceCategoryDetailScreen({
    super.key,
    required this.category,
  });

  @override
  State<FinanceCategoryDetailScreen> createState() => _FinanceCategoryDetailScreenState();
}

class _FinanceCategoryDetailScreenState extends State<FinanceCategoryDetailScreen> {
  String _selectedPeriod = 'month';
  DateTime? _startDate;
  DateTime? _endDate;
  List<FinanceRecord> _filteredRecords = [];
  bool _isLoading = false;

  double _totalAmount = 0;
  double _avgAmount = 0;
  double _maxAmount = 0;
  double _currentMonthAmount = 0;
  double _previousMonthAmount = 0;
  double _monthlyGrowth = 0;

  @override
  void initState() {
    super.initState();
    _loadCategoryData();
  }

  Future<void> _loadCategoryData() async {
    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<FinanceProvider>(context);
    await provider.getFinanceRecords(
      period: _selectedPeriod,
      type: widget.category.type,
      categoryId: widget.category.id,
      startDate: _startDate,
      endDate: _endDate,
    );

    _processRecords(provider.records);

    setState(() {
      _isLoading = false;
    });
  }

  void _processRecords(List<FinanceRecord> records) {
    if (records.isEmpty) {
      _filteredRecords = [];
      _totalAmount = 0;
      _avgAmount = 0;
      _maxAmount = 0;
      _currentMonthAmount = 0;
      _previousMonthAmount = 0;
      _monthlyGrowth = 0;
      return;
    }

    _filteredRecords = List.from(records);

    // Рассчитаем базовую статистику
    _totalAmount = records.fold(0, (sum, record) => sum + record.amount);
    _avgAmount = _totalAmount / records.length;
    _maxAmount = records.map((e) => e.amount).reduce((max, amount) => amount > max ? amount : max);

    // Статистика текущего и предыдущего месяца
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final previousMonth = DateTime(currentMonth.year, currentMonth.month - 1);

    final currentMonthRecords = records.where(
            (record) => record.date.year == currentMonth.year && record.date.month == currentMonth.month
    ).toList();

    final previousMonthRecords = records.where(
            (record) => record.date.year == previousMonth.year && record.date.month == previousMonth.month
    ).toList();

    _currentMonthAmount = currentMonthRecords.isEmpty
        ? 0
        : currentMonthRecords.fold(0, (sum, record) => sum + record.amount);

    _previousMonthAmount = previousMonthRecords.isEmpty
        ? 0
        : previousMonthRecords.fold(0, (sum, record) => sum + record.amount);

    // Рассчитаем ежемесячный рост
    if (_previousMonthAmount > 0) {
      _monthlyGrowth = (_currentMonthAmount - _previousMonthAmount) / _previousMonthAmount * 100;
    } else {
      _monthlyGrowth = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadCategoryData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryHeader(),
                const SizedBox(height: 16),
                _buildPeriodSelector(),
                const SizedBox(height: 24),
                _buildAnalytics(),
                const SizedBox(height: 24),
                _buildMonthlyTrend(),
                const SizedBox(height: 24),
                if (_filteredRecords.isNotEmpty) _buildRecordsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getCategoryColor(),
              radius: 24,
              child: Icon(
                _getCategoryIcon(),
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.category.type.capitalize(),
                    style: TextStyle(
                      color: _getCategoryColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Period',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'week', label: Text('Week')),
                ButtonSegment(value: 'month', label: Text('Month')),
                ButtonSegment(value: 'year', label: Text('Year')),
                ButtonSegment(value: 'custom', label: Text('Custom')),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _selectedPeriod = selection.first;
                  if (_selectedPeriod != 'custom') {
                    _startDate = null;
                    _endDate = null;
                  }
                });
                _loadCategoryData();
              },
            ),
            if (_selectedPeriod == 'custom') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(_startDate == null
                          ? 'Start Date'
                          : DateFormat('dd/MM/yyyy').format(_startDate!)),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _startDate = date;
                          });
                          _loadCategoryData();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(_endDate == null
                          ? 'End Date'
                          : DateFormat('dd/MM/yyyy').format(_endDate!)),
                      onPressed: () async {
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
                          _loadCategoryData();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalytics() {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Analytics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    currencyFormat.format(_totalAmount),
                    Icons.monetization_on,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Average',
                    currencyFormat.format(_avgAmount),
                    Icons.calculate,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Max',
                    currencyFormat.format(_maxAmount),
                    Icons.arrow_upward,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Transactions',
                    _filteredRecords.length.toString(),
                    Icons.receipt_long,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData iconData, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrend() {
    if (_filteredRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    // Сгруппируем записи по месяцам для графика
    final monthlyData = <DateTime, double>{};
    for (final record in _filteredRecords) {
      final monthKey = DateTime(record.date.year, record.date.month);
      if (monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = monthlyData[monthKey]! + record.amount;
      } else {
        monthlyData[monthKey] = record.amount;
      }
    }

    // Сортируем по дате
    final sortedEntries = monthlyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Создаем точки для графика
    final spots = <FlSpot>[];
    final labels = <String>[];

    for (var i = 0; i < sortedEntries.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedEntries[i].value));
      labels.add(DateFormat('MMM').format(sortedEntries[i].key));
    }

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.timeline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Monthly Trend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Month:',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      currencyFormat.format(_currentMonthAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (_previousMonthAmount > 0) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'vs Previous:',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            _monthlyGrowth >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                            color: _getGrowthColor(),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_monthlyGrowth.abs().toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getGrowthColor(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
            if (spots.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 100,
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < labels.length) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  labels[index],
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 55,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                currencyFormat.format(value),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                          interval: _calculateYInterval(spots),
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    minX: 0,
                    maxX: (spots.length - 1).toDouble(),
                    minY: 0,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: _getCategoryColor(),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: _getCategoryColor().withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_filteredRecords.length} items',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredRecords.length > 10 ? 10 : _filteredRecords.length,
              itemBuilder: (context, index) {
                final record = _filteredRecords[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor().withOpacity(0.2),
                    child: Icon(
                      _getCategoryIcon(),
                      color: _getCategoryColor(),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    record.description ?? widget.category.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy').format(record.date),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  trailing: Text(
                    currencyFormat.format(record.amount),
                    style: TextStyle(
                      color: _getCategoryColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
            if (_filteredRecords.length > 10) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    _showAllTransactions();
                  },
                  child: const Text('View All Transactions'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAllTransactions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All ${widget.category.name} Transactions',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _filteredRecords.length,
                      itemBuilder: (context, index) {
                        final record = _filteredRecords[index];
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getCategoryColor().withOpacity(0.2),
                              child: Icon(
                                _getCategoryIcon(),
                                color: _getCategoryColor(),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              record.description ?? widget.category.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('dd MMM yyyy').format(record.date),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                if (record.isRecurring)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.repeat,
                                        size: 12,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Recurring ${record.recurringFrequency ?? ""}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            trailing: Text(
                              currencyFormat.format(record.amount),
                              style: TextStyle(
                                color: _getCategoryColor(),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            isThreeLine: record.isRecurring,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  double _calculateYInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 100;

    double maxY = spots.fold(0.0, (max, spot) => spot.y > max ? spot.y : max);

    if (maxY <= 100) return 20;
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    if (maxY <= 5000) return 1000;

    return 2000;
  }

  Color _getCategoryColor() {
    switch (widget.category.type) {
      case 'expense':
        return Colors.red;
      case 'income':
        return Colors.green;
      case 'saving':
        return Colors.blue;
      case 'investment':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon() {
    // Используем значок из категории, если он есть
    if (widget.category.icon != null) {
      return _mapIconString(widget.category.icon!);
    }

    // Иначе используем стандартный значок по типу
    switch (widget.category.type) {
      case 'expense':
        return Icons.arrow_upward;
      case 'income':
        return Icons.arrow_downward;
      case 'saving':
        return Icons.savings;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }

  IconData _mapIconString(String iconName) {
    switch (iconName) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_cart;
      case 'bills':
        return Icons.receipt;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.health_and_safety;
      case 'education':
        return Icons.school;
      case 'salary':
        return Icons.work;
      case 'investment':
        return Icons.trending_up;
      case 'savings':
        return Icons.savings;
      default:
        return Icons.category;
    }
  }

  Color _getGrowthColor() {
    if (widget.category.type == 'expense') {
      return _monthlyGrowth >= 0 ? Colors.red : Colors.green;
    } else {
      return _monthlyGrowth >= 0 ? Colors.green : Colors.red;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}