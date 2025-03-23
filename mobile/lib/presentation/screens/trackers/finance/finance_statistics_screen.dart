import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../providers/finance_provider.dart';


class FinanceStatisticsScreen extends StatefulWidget {
  const FinanceStatisticsScreen({super.key});

  @override
  State<FinanceStatisticsScreen> createState() => _FinanceStatisticsScreenState();
}

class _FinanceStatisticsScreenState extends State<FinanceStatisticsScreen> {
  String _selectedPeriod = 'month';
  String? _selectedType;
  String _selectedGroupBy = 'day';
  DateTime? _startDate;
  DateTime? _endDate;

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
      startDate: _startDate,
      endDate: _endDate,
      groupBy: _selectedGroupBy,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final statistics = provider.statistics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Statistics'),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : statistics == null
                ? const Center(child: Text('No statistics available'))
                : _buildStatisticsContent(statistics),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Period',
                    border: OutlineInputBorder(),
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
                        _startDate = null;
                        _endDate = null;
                      }
                    });
                    _loadStatistics();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedType,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(value: 'expense', child: Text('Expense')),
                    DropdownMenuItem(value: 'income', child: Text('Income')),
                    DropdownMenuItem(value: 'saving', child: Text('Saving')),
                    DropdownMenuItem(value: 'investment', child: Text('Investment')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                    _loadStatistics();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Group By',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedGroupBy,
                  items: const [
                    DropdownMenuItem(value: 'day', child: Text('Day')),
                    DropdownMenuItem(value: 'week', child: Text('Week')),
                    DropdownMenuItem(value: 'month', child: Text('Month')),
                    DropdownMenuItem(value: 'year', child: Text('Year')),
                    DropdownMenuItem(value: 'category', child: Text('Category')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGroupBy = value!;
                    });
                    _loadStatistics();
                  },
                ),
              ),
            ],
          ),
          if (_selectedPeriod == 'custom') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
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
                        _loadStatistics();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
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
                        _loadStatistics();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsContent(Map<String, dynamic> statistics) {
    final summary = statistics['summary'];
    final data = statistics['data'] as List;
    final trends = statistics['trends'];
    final categoryBreakdown = statistics['category_breakdown'] as List;

    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Card
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryRow('Total Income', summary['total_income'], currencyFormat, Colors.green),
                const SizedBox(height: 8),
                _buildSummaryRow('Total Expense', summary['total_expense'], currencyFormat, Colors.red),
                const SizedBox(height: 8),
                _buildSummaryRow('Total Saving', summary['total_saving'], currencyFormat, Colors.blue),
                const SizedBox(height: 8),
                _buildSummaryRow('Total Investment', summary['total_investment'], currencyFormat, Colors.purple),
                const Divider(height: 24),
                _buildSummaryRow('Balance', summary['balance'], currencyFormat, Colors.black, isBold: true),
                if (summary['saving_rate'] != null) ...[
                  const SizedBox(height: 8),
                  _buildSummaryRow('Saving Rate', summary['saving_rate'], NumberFormat('0.0%'), Colors.blue),
                ],
                if (summary['expense_rate'] != null) ...[
                  const SizedBox(height: 8),
                  _buildSummaryRow('Expense Rate', summary['expense_rate'], NumberFormat('0.0%'), Colors.red),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        if (trends != null)
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trends',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTrendRow('Income', trends['income_trend'], Colors.green),
                  const SizedBox(height: 8),
                  _buildTrendRow('Expense', trends['expense_trend'], Colors.red),
                  const SizedBox(height: 8),
                  _buildTrendRow('Saving', trends['saving_trend'], Colors.blue),
                  const SizedBox(height: 8),
                  _buildTrendRow('Investment', trends['investment_trend'], Colors.purple),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),

        if (data.isNotEmpty)
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedGroupBy == 'category'
                        ? 'Distribution by Category'
                        : 'Distribution over Time',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: _selectedGroupBy == 'category'
                        ? _buildCategoryBarChart(data)
                        : _buildTimeSeriesChart(data),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),

        if (categoryBreakdown.isNotEmpty && _selectedType != null)
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category Breakdown for ${_selectedType!.capitalize()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildCategoryPieChart(categoryBreakdown),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categoryBreakdown.length,
                    itemBuilder: (context, index) {
                      final category = categoryBreakdown[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                category['category_name'] ?? 'Unknown',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              currencyFormat.format(category['amount']),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${category['percentage'].toStringAsFixed(1)}%)',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, dynamic value, NumberFormat formatter, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          formatter.format(value),
          style: TextStyle(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendRow(String label, dynamic trend, Color color) {
    final isPositive = trend >= 0;
    final trendValue = trend.abs();
    final iconData = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    final trendColor = label == 'Expense' ? (isPositive ? Colors.red : Colors.green) : (isPositive ? color : Colors.red);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            Icon(iconData, color: trendColor, size: 16),
            const SizedBox(width: 4),
            Text(
              '${trendValue.toStringAsFixed(1)}%',
              style: TextStyle(
                color: trendColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSeriesChart(List data) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available for chart'));
    }

    data.sort((a, b) {
      if (_selectedGroupBy == 'day') {
        return DateTime.parse(a['period']).compareTo(DateTime.parse(b['period']));
      } else {
        return a['period'].compareTo(b['period']);
      }
    });

    final spots = <FlSpot>[];
    final titles = <String>[];

    for (var i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]['amount'].toDouble()));

      String title = data[i]['period'];
      if (_selectedGroupBy == 'day' && title.contains('-')) {
        final date = DateTime.parse(title);
        title = DateFormat('dd/MM').format(date);
      } else if (_selectedGroupBy == 'month' && title.contains('-')) {
        final date = DateTime.parse('$title-01');
        title = DateFormat('MMM').format(date);
      }

      titles.add(title);
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < titles.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      titles[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              interval: titles.length > 10 ? (titles.length / 5).ceilToDouble() : 1,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '\$${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              interval: _calculateInterval(spots),
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
        maxX: spots.length.toDouble() - 1,
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: _getChartColor(),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: _getChartColor().withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBarChart(List data) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available for chart'));
    }

    data.sort((a, b) => b['amount'].compareTo(a['amount']));

    if (data.length > 10) {
      data = data.sublist(0, 10);
    }

    final barGroups = <BarChartGroupData>[];
    final titles = <String>[];

    for (var i = 0; i < data.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: data[i]['amount'].toDouble(),
              color: _getChartColor(),
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );

      titles.add(data[i]['period'] ?? 'Unknown');
    }

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateInterval(
              barGroups.map((e) => FlSpot(0, e.barRods.first.toY)).toList()
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < titles.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      titles[value.toInt()],
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
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '\$${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              interval: _calculateInterval(
                  barGroups.map((e) => FlSpot(0, e.barRods.first.toY)).toList()
              ),
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
        alignment: BarChartAlignment.spaceAround,
      ),
    );
  }

  Widget _buildCategoryPieChart(List categoryBreakdown) {
    if (categoryBreakdown.isEmpty) {
      return const Center(child: Text('No category data available'));
    }

    categoryBreakdown.sort((a, b) => b['percentage'].compareTo(a['percentage']));

    List processedData = [];
    if (categoryBreakdown.length > 5) {
      double otherPercentage = 0;
      double otherAmount = 0;

      processedData = categoryBreakdown.sublist(0, 4);

      for (int i = 4; i < categoryBreakdown.length; i++) {
        otherPercentage += categoryBreakdown[i]['percentage'];
        otherAmount += categoryBreakdown[i]['amount'];
      }

      processedData.add({
        'category_name': 'Other',
        'amount': otherAmount,
        'percentage': otherPercentage,
      });
    } else {
      processedData = categoryBreakdown;
    }

    final sections = <PieChartSectionData>[];
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];

    for (var i = 0; i < processedData.length; i++) {
      final data = processedData[i];
      sections.add(
        PieChartSectionData(
          value: data['amount'].toDouble(),
          title: '${data['percentage'].toStringAsFixed(1)}%',
          color: colors[i % colors.length],
          radius: 80,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              pieTouchData: PieTouchData(enabled: true),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              processedData.length,
                  (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        processedData[index]['category_name'] ?? 'Unknown',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _calculateInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 1;

    double maxY = 0;
    for (var spot in spots) {
      if (spot.y > maxY) {
        maxY = spot.y;
      }
    }

    if (maxY <= 10) return 1;
    if (maxY <= 100) return 10;
    if (maxY <= 1000) return 100;
    if (maxY <= 10000) return 1000;

    return 10000;
  }

  Color _getChartColor() {
    switch (_selectedType) {
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
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}