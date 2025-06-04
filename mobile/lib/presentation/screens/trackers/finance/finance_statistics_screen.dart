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
      type: null,
      groupBy: 'day',
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final stats = provider.statistics;
    final currency = NumberFormat.currency(locale: 'ru_RU', symbol: '₸');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Аналитика'),
        centerTitle: true,
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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child:
                _isFilterExpanded
                    ? _buildFilter(context)
                    : const SizedBox.shrink(),
          ),
          Expanded(
            child: _buildContent(provider, stats, currency, Theme.of(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          labelText: 'Период',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        value: _selectedPeriod,
        items: const [
          DropdownMenuItem(value: 'day', child: Text('Сегодня')),
          DropdownMenuItem(value: 'week', child: Text('Неделя')),
          DropdownMenuItem(value: 'month', child: Text('Месяц')),
          DropdownMenuItem(value: 'year', child: Text('Год')),
        ],
        onChanged: (val) {
          setState(() => _selectedPeriod = val!);
          _loadStatistics();
        },
      ),
    );
  }

  Widget _buildContent(
    FinanceProvider provider,
    dynamic stats,
    NumberFormat format,
    ThemeData theme,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text(provider.error!));
    }

    if (stats == null) {
      return const Center(child: Text('Нет данных'));
    }

    return RefreshIndicator(
      onRefresh: () async => _loadStatistics(),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildChart(stats['data'], theme),
          const SizedBox(height: 16),
          _buildMetrics(stats['summary'], format, theme),
        ],
      ),
    );
  }

  Widget _buildChart(List data, ThemeData theme) {
    if (data.isEmpty) return const Text('Нет данных');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots:
                      data
                          .asMap()
                          .entries
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              e.value['amount'].toDouble(),
                            ),
                          )
                          .toList(),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.2),
                  ),
                  dotData: FlDotData(show: false),
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < data.length) {
                        final label = DateFormat(
                          'dd.MM',
                        ).format(DateTime.parse(data[value.toInt()]['period']));
                        return Text(label, style: theme.textTheme.labelSmall);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetrics(dynamic summary, NumberFormat format, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Сводка', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            _buildMetric(
              'Доходы',
              format.format(summary['total_income']),
              Icons.arrow_downward,
              Colors.green,
            ),
            _buildMetric(
              'Расходы',
              format.format(summary['total_expense']),
              Icons.arrow_upward,
              Colors.red,
            ),
            _buildMetric(
              'Баланс',
              format.format(summary['balance']),
              summary['balance'] >= 0 ? Icons.trending_up : Icons.trending_down,
              summary['balance'] >= 0 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
