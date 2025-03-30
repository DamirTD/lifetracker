import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/presentation/providers/sleep_provider.dart';
import 'package:fl_chart/fl_chart.dart';

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
      Provider.of<SleepProvider>(context, listen: false).loadTrends(_selectedMonths);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepProvider>(
      builder: (context, provider, child) {
        final trend = provider.trend;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Период анализа',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Выберите период (месяцы)',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedMonths,
                        items: _monthOptions.map((int months) {
                          return DropdownMenuItem<int>(
                            value: months,
                            child: Text('$months ${_getMonthsString(months)}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null && value != _selectedMonths) {
                            setState(() {
                              _selectedMonths = value;
                            });
                            provider.loadTrends(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (trend != null) ...[
                // Общие тенденции
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Общие тенденции',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 16),

                        _buildTrendTile(
                          'Продолжительность сна',
                          _getTrendDescription(trend.durationTrend),
                          trend.durationIcon,
                          _getTrendColor(trend.durationTrend),
                        ),

                        const Divider(),

                        _buildTrendTile(
                          'Качество сна',
                          _getTrendDescription(trend.qualityTrend),
                          trend.qualityIcon,
                          _getTrendColor(trend.qualityTrend),
                        ),

                        const Divider(),

                        _buildTrendTile(
                          'Прерывания сна',
                          _getTrendDescription(trend.interruptionsTrend, isInterruption: true),
                          trend.interruptionsIcon,
                          _getTrendColor(trend.interruptionsTrend, isInterruption: true),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // График динамики сна
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Динамика сна',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 16),

                        // Переключатели типов графика
                        ToggleButtons(
                          isSelected: [
                            _currentChartType == 'duration',
                            _currentChartType == 'quality',
                            _currentChartType == 'interruptions',
                          ],
                          onPressed: (index) {
                            setState(() {
                              if (index == 0) {
                                _currentChartType = 'duration';
                              } else if (index == 1) {
                                _currentChartType = 'quality';
                              } else {
                                _currentChartType = 'interruptions';
                              }
                            });
                          },
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Продолжительность'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Качество'),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Прерывания'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // График
                        SizedBox(
                          height: 250,
                          child: _buildChart(trend.trendData),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Инсайты
                if (trend.insights.isNotEmpty) ...[
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Инсайты',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 16),

                          ...trend.insights.map((insight) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.lightbulb, color: Colors.amber),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(insight),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ] else if (provider.error != null) ...[
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ошибка загрузки тенденций: ${provider.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          provider.loadTrends(_selectedMonths);
                        },
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'Нет данных для отображения',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Плитка с информацией о тенденции
  Widget _buildTrendTile(String title, String description, String icon, Color color) {
    return ListTile(
      title: Row(
        children: [
          Text(title),
          const SizedBox(width: 8),
          Text(
            icon,
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      subtitle: Text(description),
    );
  }

  Widget _buildChart(SleepTrendData data) {
    final labels = data.labels;

    List<double> values;
    String yAxisLabel;
    Color lineColor;

    switch (_currentChartType) {
      case 'duration':
        values = data.duration.map((e) => e.toDouble()).toList();
        yAxisLabel = 'Минуты';
        lineColor = Colors.blue;
        break;
      case 'quality':
        values = data.qualityScore;
        yAxisLabel = 'Балл';
        lineColor = Colors.green;
        break;
      case 'interruptions':
        values = data.interruptions;
        yAxisLabel = 'Кол-во';
        lineColor = Colors.red;
        break;
      default:
        values = data.duration.map((e) => e.toDouble()).toList();
        yAxisLabel = 'Минуты';
        lineColor = Colors.blue;
    }

    if (values.isEmpty || values.length != labels.length) {
      return const Center(child: Text('Недостаточно данных для построения графика'));
    }

    final spots = List.generate(
      values.length,
          (index) => FlSpot(index.toDouble(), values[index]),
    );

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < labels.length && index % 2 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      labels[index],
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 32,
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: Text(
              yAxisLabel,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == meta.max || value == meta.min || value == (meta.max + meta.min) / 2) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        minX: 0,
        maxX: (values.length - 1).toDouble(),
        minY: 0,
        maxY: _getMaxValue(values) * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: lineColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: lineColor,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  // Получение максимального значения для настройки оси Y
  double _getMaxValue(List<double> values) {
    if (values.isEmpty) {
      return 1.0; // Дефолтное значение, если список пуст
    }
    return values.reduce((curr, next) => curr > next ? curr : next);
  }

  // Получение правильного склонения слова "месяц"
  String _getMonthsString(int months) {
    if (months % 10 == 1 && months % 100 != 11) {
      return 'месяц';
    } else if ([2, 3, 4].contains(months % 10) && ![12, 13, 14].contains(months % 100)) {
      return 'месяца';
    } else {
      return 'месяцев';
    }
  }

  // Получение описания тренда
  String _getTrendDescription(String trend, {bool isInterruption = false}) {
    if (trend == 'no_data') {
      return 'Недостаточно данных';
    }

    if (isInterruption) {
      // Для прерываний тренды имеют обратное значение (увеличение - плохо, уменьшение - хорошо)
      switch (trend) {
        case 'increasing':
          return 'Количество прерываний увеличивается';
        case 'decreasing':
          return 'Количество прерываний уменьшается';
        case 'stable':
          return 'Количество прерываний стабильно';
        default:
          return 'Неизвестный тренд';
      }
    } else {
      switch (trend) {
        case 'increasing':
          return 'Положительная динамика';
        case 'decreasing':
          return 'Отрицательная динамика';
        case 'stable':
          return 'Стабильный показатель';
        default:
          return 'Неизвестный тренд';
      }
    }
  }

  Color _getTrendColor(String trend, {bool isInterruption = false}) {
    if (trend == 'no_data') {
      return Colors.grey;
    }

    if (isInterruption) {
      switch (trend) {
        case 'increasing':
          return Colors.red;
        case 'decreasing':
          return Colors.green;
        case 'stable':
          return Colors.amber;
        default:
          return Colors.grey;
      }
    } else {
      switch (trend) {
        case 'increasing':
          return Colors.green;
        case 'decreasing':
          return Colors.red;
        case 'stable':
          return Colors.amber;
        default:
          return Colors.grey;
      }
    }
  }
}