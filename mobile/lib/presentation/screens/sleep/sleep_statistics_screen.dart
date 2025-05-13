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
  bool _showRecommendations = false;
  final List<String> _periodOptions = ['week', 'month', 'year'];
  final Map<String, String> _periodLabels = {
    'week': 'Неделя',
    'month': 'Месяц',
    'year': 'Год',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Consumer<SleepProvider>(
      builder: (context, provider, child) {
        final statistics = provider.statistics;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и селектор периода
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Статистика сна',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedPeriod,
                    style: textTheme.bodyMedium,
                    dropdownColor: colors.surface,
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(10),
                    items:
                        _periodOptions.map((period) {
                          return DropdownMenuItem(
                            value: period,
                            child: Text(_periodLabels[period]!),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null && value != _selectedPeriod) {
                        setState(() => _selectedPeriod = value);
                        provider.loadStatistics(value);
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              if (statistics != null) ...[
                // Основные метрики
                _sectionTitle('Основные метрики'),
                const SizedBox(height: 12),
                _statGrid([
                  _tile(
                    'Продолжительность',
                    statistics.averageDurationFormatted,
                    Icons.timelapse,
                  ),
                  _tile(
                    'Качество сна',
                    statistics.averageQuality,
                    Icons.star_rate,
                  ),
                  _tile(
                    'Эффективность',
                    '${statistics.sleepEfficiency}%',
                    Icons.trending_up,
                  ),
                ]),

                const SizedBox(height: 32),

                // Доп. статистика
                _sectionTitle('Дополнительные данные'),
                const SizedBox(height: 12),
                _statGrid([
                  _tile(
                    'Длинный сон',
                    statistics.longestSleepFormatted,
                    Icons.arrow_upward,
                  ),
                  _tile(
                    'Короткий сон',
                    statistics.shortestSleepFormatted,
                    Icons.arrow_downward,
                  ),
                  _tile(
                    'Прерывания',
                    statistics.totalInterruptions.toString(),
                    Icons.bug_report,
                  ),
                  _tile(
                    'Обычно засыпает',
                    statistics.mostCommonBedtime,
                    Icons.nightlight_round,
                  ),
                  _tile(
                    'Лучший день',
                    statistics.bestSleepDay,
                    Icons.calendar_month,
                  ),
                ]),
              ] else if (provider.error != null) ...[
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ошибка: ${provider.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.error, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed:
                            () => provider.loadStatistics(_selectedPeriod),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'Нет данных для отображения',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Рекомендации
              if (provider.recommendations != null &&
                  provider.recommendations!.isNotEmpty) ...[
                TextButton.icon(
                  onPressed: () {
                    setState(
                      () => _showRecommendations = !_showRecommendations,
                    );
                  },
                  icon: Icon(
                    _showRecommendations
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                  label: Text(
                    _showRecommendations
                        ? 'Скрыть рекомендации'
                        : 'Рекомендации',
                  ),
                ),

                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Рекомендации'),
                      const SizedBox(height: 12),
                      ...provider.recommendations!.map(
                        (text) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.tips_and_updates,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(text)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  crossFadeState:
                      _showRecommendations
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _tile(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Colors.blue),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _statGrid(List<Widget> tiles) {
    return Wrap(spacing: 16, runSpacing: 16, children: tiles);
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
