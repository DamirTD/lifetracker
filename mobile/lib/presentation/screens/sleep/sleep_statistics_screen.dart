import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/presentation/providers/sleep_provider.dart';

class SleepStatisticsScreen extends StatefulWidget {
  const SleepStatisticsScreen({super.key});

  @override
  State<SleepStatisticsScreen> createState() => _SleepStatisticsScreenState();
}

class _SleepStatisticsScreenState extends State<SleepStatisticsScreen> {
  String _selectedPeriod = 'week';
  final List<String> _periodOptions = ['week', 'month', 'year'];
  final Map<String, String> _periodLabels = {
    'week': 'Неделя',
    'month': 'Месяц',
    'year': 'Год',
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepProvider>(
      builder: (context, provider, child) {
        final statistics = provider.statistics;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Выбор периода
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Период статистики',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Выберите период',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedPeriod,
                        items: _periodOptions.map((String period) {
                          return DropdownMenuItem<String>(
                            value: period,
                            child: Text(_periodLabels[period] ?? period),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null && value != _selectedPeriod) {
                            setState(() {
                              _selectedPeriod = value;
                            });
                            provider.loadStatistics(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (statistics != null) ...[
                // Основные метрики
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Основные метрики',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 16),

                        _buildStatisticTile(
                          'Средняя продолжительность',
                          statistics.averageDurationFormatted,
                          Icons.timelapse,
                        ),

                        const Divider(),

                        _buildStatisticTile(
                          'Среднее качество',
                          statistics.averageQuality,
                          Icons.star,
                        ),

                        const Divider(),

                        _buildStatisticTile(
                          'Эффективность сна',
                          '${statistics.sleepEfficiency}%',
                          Icons.trending_up,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Дополнительная статистика
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Дополнительная статистика',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 16),

                        _buildStatisticTile(
                          'Самый длинный сон',
                          statistics.longestSleepFormatted,
                          Icons.arrow_upward,
                        ),

                        const Divider(),

                        _buildStatisticTile(
                          'Самый короткий сон',
                          statistics.shortestSleepFormatted,
                          Icons.arrow_downward,
                        ),

                        const Divider(),

                        _buildStatisticTile(
                          'Всего прерываний',
                          statistics.totalInterruptions.toString(),
                          Icons.report_problem,
                        ),

                        const Divider(),

                        _buildStatisticTile(
                          'Частое время отхода ко сну',
                          statistics.mostCommonBedtime,
                          Icons.nightlight,
                        ),

                        const Divider(),

                        _buildStatisticTile(
                          'Лучший день для сна',
                          statistics.bestSleepDay,
                          Icons.calendar_today,
                        ),
                      ],
                    ),
                  ),
                ),
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
                        'Ошибка загрузки статистики: ${provider.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          provider.loadStatistics(_selectedPeriod);
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

              const SizedBox(height: 16),

              // Рекомендации на основе статистики
              if (provider.recommendations != null && provider.recommendations!.isNotEmpty) ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Рекомендации',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 16),

                        ...provider.recommendations!.map((recommendation) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.tips_and_updates, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(recommendation),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
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

  Widget _buildStatisticTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}