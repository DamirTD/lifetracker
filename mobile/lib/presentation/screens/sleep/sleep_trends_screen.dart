import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile/presentation/providers/sleep_provider.dart';
import '../../../data/models/sleep/sleep_statistics.dart';

class SleepTrendsScreen extends StatefulWidget {
  const SleepTrendsScreen({super.key});

  @override
  State<SleepTrendsScreen> createState() => _SleepTrendsScreenState();
}

class _SleepTrendsScreenState extends State<SleepTrendsScreen> {
  int _selectedMonths = 3;
  final List<int> _monthOptions = [1, 3, 6, 12];
  String _currentChartType = 'duration';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SleepProvider>(
        context,
        listen: false,
      ).loadTrends(_selectedMonths);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SleepProvider>(
        builder: (context, provider, child) {
          final trend = provider.trend;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Период анализа
                  _buildCard(
                    title: 'Период анализа',
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Выберите период',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                      value: _selectedMonths,
                      items:
                          _monthOptions
                              .map(
                                (months) => DropdownMenuItem<int>(
                                  value: months,
                                  child: Text(
                                    '$months ${_getMonthsString(months)}',
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null && value != _selectedMonths) {
                          setState(() => _selectedMonths = value);
                          provider.loadTrends(value);
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (trend != null) ...[
                    _buildCard(
                      title: 'Общие тенденции',
                      child: Column(
                        children: [
                          _buildTrendTile(
                            'Продолжительность сна',
                            trend.durationTrend,
                            trend.durationIcon,
                            false,
                          ),
                          const Divider(height: 1, thickness: 1),
                          _buildTrendTile(
                            'Качество сна',
                            trend.qualityTrend,
                            trend.qualityIcon,
                            false,
                          ),
                          const Divider(height: 1, thickness: 1),
                          _buildTrendTile(
                            'Прерывания сна',
                            trend.interruptionsTrend,
                            trend.interruptionsIcon,
                            true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Динамика сна с графиком
                    _buildCard(
                      title: 'Динамика сна',
                      child: Column(
                        children: [
                          SizedBox(
                            height: 50,
                            child: ToggleButtons(
                              borderRadius: BorderRadius.circular(12),
                              constraints: const BoxConstraints(
                                minWidth: 100,
                                minHeight: 40,
                              ),
                              isSelected: [
                                _currentChartType == 'duration',
                                _currentChartType == 'quality',
                                _currentChartType == 'interruptions',
                              ],
                              onPressed: (index) {
                                setState(() {
                                  _currentChartType =
                                      [
                                        'duration',
                                        'quality',
                                        'interruptions',
                                      ][index];
                                });
                              },
                              selectedColor: Colors.white,
                              fillColor: Theme.of(context).primaryColor,
                              color: Theme.of(context).primaryColor,
                              children: const [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('Длительность'),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('Качество'),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('Прерывания'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 250,
                            child: _buildChart(trend.trendData),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (trend.insights.isNotEmpty)
                      _buildCard(
                        title: 'Инсайты',
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: trend.insights.length,
                          separatorBuilder:
                              (_, __) => const Divider(height: 16),
                          itemBuilder:
                              (context, index) => Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.lightbulb_outline,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      trend.insights[index],
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                        ),
                      ),
                  ] else if (provider.error != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Ошибка загрузки данных',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.error!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              onPressed:
                                  () => provider.loadTrends(_selectedMonths),
                              child: const Text('Попробовать снова'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.hourglass_empty,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text('Нет данных для отображения'),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTrendTile(
    String title,
    String trend,
    String icon,
    bool isInterruption,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  _getTrendDescription(trend, isInterruption: isInterruption),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getTrendColor(
                trend,
                isInterruption: isInterruption,
              ).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  icon,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getTrendColor(
                      trend,
                      isInterruption: isInterruption,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _getTrendIcon(trend),
                  size: 16,
                  color: _getTrendColor(trend, isInterruption: isInterruption),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(SleepTrendData data) {
    try {
      List<double> values;
      Color lineColor;

      switch (_currentChartType) {
        case 'quality':
          values = data.qualityScore;
          lineColor = Colors.green;
          break;
        case 'interruptions':
          values = data.interruptions;
          lineColor = Colors.red;
          break;
        default:
          values = data.duration.map((e) => e.toDouble()).toList();
          lineColor = Theme.of(context).primaryColor;
      }

      if (values.isEmpty || values.length != data.labels.length) {
        return Center(
          child: Text(
            'Недостаточно данных',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        );
      }

      final spots = List.generate(
        values.length,
        (i) => FlSpot(i.toDouble(), values[i]),
      );

      return Padding(
        padding: const EdgeInsets.only(right: 16),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: values.length.toDouble() - 1,
            minY: 0,
            maxY: _getMaxValue(values) * 1.2,
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: Colors.white,
                tooltipBorder: BorderSide(color: Colors.grey.shade300),
                getTooltipItems:
                    (spots) =>
                        spots.map((spot) {
                          return LineTooltipItem(
                            '${spot.y.toStringAsFixed(1)}',
                            TextStyle(
                              color: lineColor,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList(),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: _getMaxValue(values) / 4,
              getDrawingHorizontalLine:
                  (value) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < data.labels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          data.labels[index],
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
                  reservedSize: 40,
                  interval: _getMaxValue(values) / 4,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.3,
                barWidth: 3,
                color: lineColor,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      lineColor.withOpacity(0.3),
                      lineColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                dotData: FlDotData(
                  show: true,
                  getDotPainter:
                      (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: lineColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error building chart: $e');
      return Center(
        child: Text(
          'Ошибка построения графика',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.red),
        ),
      );
    }
  }

  double _getMaxValue(List<double> values) {
    if (values.isEmpty) return 1.0;
    final max = values.reduce((a, b) => a > b ? a : b);
    return max == 0 ? 1.0 : max;
  }

  String _getMonthsString(int months) {
    if (months == 1) return 'месяц';
    if ([2, 3, 4].contains(months)) return 'месяца';
    return 'месяцев';
  }

  String _getTrendDescription(String trend, {bool isInterruption = false}) {
    if (trend == 'no_data') return 'Недостаточно данных';
    if (isInterruption) {
      return {
            'increasing': 'Прерывания увеличиваются',
            'decreasing': 'Прерывания уменьшаются',
            'stable': 'Стабильные прерывания',
          }[trend] ??
          'Неизвестно';
    }
    return {
          'increasing': 'Положительная динамика',
          'decreasing': 'Отрицательная динамика',
          'stable': 'Стабильный показатель',
        }[trend] ??
        'Неизвестно';
  }

  Color _getTrendColor(String trend, {bool isInterruption = false}) {
    if (trend == 'no_data') return Colors.grey;
    if (isInterruption) {
      return {
        'increasing': Colors.red,
        'decreasing': Colors.green,
        'stable': Colors.amber,
      }[trend]!;
    }
    return {
      'increasing': Colors.green,
      'decreasing': Colors.red,
      'stable': Colors.amber,
    }[trend]!;
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'increasing':
        return Icons.trending_up;
      case 'decreasing':
        return Icons.trending_down;
      case 'stable':
        return Icons.trending_flat;
      default:
        return Icons.help_outline;
    }
  }
}
