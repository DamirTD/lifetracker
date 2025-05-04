import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../providers/finance_provider.dart';

class FinanceStatisticsScreen extends StatefulWidget {
  const FinanceStatisticsScreen({super.key});

  @override
  State<FinanceStatisticsScreen> createState() =>
      _FinanceStatisticsScreenState();
}

class _FinanceStatisticsScreenState extends State<FinanceStatisticsScreen> {
  String _selectedPeriod = 'month';
  String? _selectedType;
  String _selectedGroupBy = 'day';
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  void _loadStatistics() {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    provider.getFinanceStatistics(
      period: _selectedPeriod,
      type: _selectedType,
      groupBy: _selectedGroupBy,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<FinanceProvider>(context);
    final statistics = provider.statistics;
    final currencyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Аналитика'),
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
          Expanded(
            child: _buildContent(provider, statistics, currencyFormat, theme),
          ),
        ],
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
                DropdownMenuItem(value: 'day', child: Text('День')),
                DropdownMenuItem(value: 'week', child: Text('Неделя')),
                DropdownMenuItem(value: 'month', child: Text('Месяц')),
                DropdownMenuItem(value: 'year', child: Text('Год')),
              ],
              onChanged: (value) {
                setState(() => _selectedPeriod = value as String);
                _loadStatistics();
              },
            ),

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
              onChanged: (value) {
                setState(() => _selectedType = value as String?);
                _loadStatistics();
              },
            ),

            const SizedBox(height: 12),

            // Группировка
            _buildFilterDropdown(
              label: 'Группировка',
              value: _selectedGroupBy,
              items: const [
                DropdownMenuItem(value: 'day', child: Text('По дням')),
                DropdownMenuItem(value: 'week', child: Text('По неделям')),
                DropdownMenuItem(value: 'month', child: Text('По месяцам')),
                DropdownMenuItem(
                  value: 'category',
                  child: Text('По категориям'),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedGroupBy = value as String);
                _loadStatistics();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    FinanceProvider provider,
    dynamic statistics,
    NumberFormat currencyFormat,
    ThemeData theme,
  ) {
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
              onPressed: _loadStatistics,
              child: const Text('Повторить попытку'),
            ),
          ],
        ),
      );
    }

    if (statistics == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Нет данных для отображения',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Измените параметры фильтрации',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadStatistics(),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // График распределения
          _buildChartSection(statistics, theme),

          const SizedBox(height: 16),

          // Ключевые показатели
          _buildKeyMetrics(statistics['summary'], currencyFormat, theme),

          if (_selectedType != null &&
              statistics['category_breakdown'] != null) ...[
            const SizedBox(height: 16),
            _buildCategoryBreakdown(
              statistics['category_breakdown'],
              currencyFormat,
              theme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChartSection(dynamic statistics, ThemeData theme) {
    final data = statistics['data'] as List;
    final isCategoryGrouping = _selectedGroupBy == 'category';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCategoryGrouping ? 'Распределение по категориям' : 'Динамика',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child:
                  isCategoryGrouping
                      ? _buildCategoryChart(data, theme)
                      : _buildTimeChart(data, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(List data, ThemeData theme) {
    if (data.isEmpty) {
      return Center(
        child: Text('Нет данных', style: theme.textTheme.bodyMedium),
      );
    }

    // Сортируем по убыванию и берем топ-5
    data.sort((a, b) => b['amount'].compareTo(a['amount']));
    final displayData = data.length > 5 ? data.sublist(0, 5) : data;

    return BarChart(
      BarChartData(
        barGroups:
            displayData.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: item['amount'].toDouble(),
                    color: _getChartColor(index),
                    width: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < displayData.length) {
                  final name = displayData[value.toInt()]['period'] ?? 'Другое';
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        name,
                        style: theme.textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 40,
            ),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: theme.colorScheme.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} ₽',
                theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChart(List data, ThemeData theme) {
    if (data.isEmpty) {
      return Center(
        child: Text('Нет данных', style: theme.textTheme.bodyMedium),
      );
    }

    // Сортируем по дате
    data.sort((a, b) => a['period'].compareTo(b['period']));

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots:
                data.asMap().entries.map((entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    entry.value['amount'].toDouble(),
                  );
                }).toList(),
            isCurved: true,
            color: _getTypeColor(_selectedType ?? ''),
            barWidth: 3,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  final period = data[value.toInt()]['period'];
                  String label;

                  if (_selectedGroupBy == 'day') {
                    label = DateFormat('dd.MM').format(DateTime.parse(period));
                  } else if (_selectedGroupBy == 'week') {
                    label = 'Неделя ${value.toInt() + 1}';
                  } else {
                    label = DateFormat(
                      'MMM',
                      'ru_RU',
                    ).format(DateTime.parse('$period-01'));
                  }

                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(label, style: theme.textTheme.labelSmall),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 30,
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateInterval(data),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: theme.colorScheme.surface,
            getTooltipItems: (spots) {
              return spots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toInt()} ₽',
                  theme.textTheme.bodyMedium!.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(
    dynamic summary,
    NumberFormat currencyFormat,
    ThemeData theme,
  ) {
    final isExpense = _selectedType == 'expense';
    final isIncome = _selectedType == 'income';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ключевые показатели',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (_selectedType == null || isIncome) ...[
              _buildMetricItem(
                'Общий доход',
                currencyFormat.format(summary['total_income']),
                Icons.arrow_downward_rounded,
                Colors.green,
                theme,
              ),
              const SizedBox(height: 12),
            ],

            if (_selectedType == null || isExpense) ...[
              _buildMetricItem(
                'Общий расход',
                currencyFormat.format(summary['total_expense']),
                Icons.arrow_upward_rounded,
                Colors.red,
                theme,
              ),
              const SizedBox(height: 12),
            ],

            if (_selectedType == null) ...[
              _buildMetricItem(
                'Разница',
                currencyFormat.format(summary['balance']),
                summary['balance'] >= 0
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                summary['balance'] >= 0 ? Colors.green : Colors.red,
                theme,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(
    List breakdown,
    NumberFormat currencyFormat,
    ThemeData theme,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Распределение по категориям',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(flex: 2, child: _buildPieChart(breakdown, theme)),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: _buildCategoryList(breakdown, currencyFormat, theme),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(List breakdown, ThemeData theme) {
    // Группируем мелкие категории в "Другие"
    List processedData = [];
    if (breakdown.length > 5) {
      double otherPercentage = 0;
      double otherAmount = 0;

      processedData = breakdown.sublist(0, 4);

      for (int i = 4; i < breakdown.length; i++) {
        otherPercentage += breakdown[i]['percentage'];
        otherAmount += breakdown[i]['amount'];
      }

      processedData.add({
        'category_name': 'Другие',
        'amount': otherAmount,
        'percentage': otherPercentage,
      });
    } else {
      processedData = breakdown;
    }

    return PieChart(
      PieChartData(
        sections:
            processedData.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return PieChartSectionData(
                value: item['amount'].toDouble(),
                title: '${item['percentage'].toStringAsFixed(0)}%',
                color: _getChartColor(index),
                radius: 24,
                titleStyle: theme.textTheme.labelSmall!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {},
        ),
      ),
    );
  }

  Widget _buildCategoryList(
    List breakdown,
    NumberFormat currencyFormat,
    ThemeData theme,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: breakdown.length,
      itemBuilder: (context, index) {
        final item = breakdown[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getChartColor(index),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['category_name'] ?? 'Без категории',
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                currencyFormat.format(item['amount']),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
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

  Color _getChartColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];
    return colors[index % colors.length];
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
        return Colors.blueGrey;
    }
  }

  double _calculateInterval(List data) {
    if (data.isEmpty) return 1000;

    double maxAmount = 0;
    for (var item in data) {
      if (item['amount'] > maxAmount) {
        maxAmount = item['amount'].toDouble();
      }
    }

    if (maxAmount <= 1000) return 100;
    if (maxAmount <= 10000) return 1000;
    if (maxAmount <= 100000) return 10000;
    return 100000;
  }
}
