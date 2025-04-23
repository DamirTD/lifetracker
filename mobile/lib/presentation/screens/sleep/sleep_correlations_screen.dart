import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/presentation/providers/sleep_provider.dart';

import '../../../data/models/sleep/sleep_statistics.dart';

class SleepCorrelationsScreen extends StatefulWidget {
  const SleepCorrelationsScreen({super.key});

  @override
  State<SleepCorrelationsScreen> createState() =>
      _SleepCorrelationsScreenState();
}

class _SleepCorrelationsScreenState extends State<SleepCorrelationsScreen> {
  @override
  void initState() {
    super.initState();

    // Загружаем корреляции при монтировании виджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SleepProvider>(context, listen: false).loadCorrelations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepProvider>(
      builder: (context, provider, child) {
        final correlations = provider.correlations;

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
                    children: const [
                      Text(
                        'Что влияет на ваш сон?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Здесь вы можете увидеть факторы, которые влияют на качество вашего сна, '
                        'основанные на анализе ваших данных.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (correlations != null && correlations.isNotEmpty) ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: correlations.length,
                  itemBuilder: (context, index) {
                    final correlation = correlations[index];
                    return _buildCorrelationCard(correlation);
                  },
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
                        'Ошибка загрузки корреляций: ${provider.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          provider.loadCorrelations();
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
                      'Для анализа корреляций необходимо больше данных о сне',
                      textAlign: TextAlign.center,
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

  // Построение карточки корреляции
  Widget _buildCorrelationCard(SleepCorrelation correlation) {
    final color = _getCorrelationColor(correlation.impact);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getCorrelationIcon(correlation.factor, correlation.impact),
                  color: color,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    correlation.factor,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Индикатор силы корреляции
            Row(
              children: [
                const Text(
                  'Сила связи:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: correlation.correlationPercentage / 100,
                    backgroundColor: Colors.grey.withAlpha((255 * 0.2).round()),
                    color: color,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${correlation.correlationPercentage}%',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Описание корреляции
            Text(correlation.description, style: const TextStyle(fontSize: 14)),

            const SizedBox(height: 8),

            // Метка влияния
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withAlpha((255 * 0.2).round()),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getImpactLabel(correlation.impact),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCorrelationIcon(String factor, String impact) {
    if (factor.contains('Температура')) {
      return Icons.thermostat;
    } else if (factor.contains('Физическая активность')) {
      return Icons.directions_run;
    } else if (factor.contains('Время')) {
      return Icons.access_time;
    } else if (factor.contains('Шум')) {
      return Icons.volume_up;
    } else if (factor.contains('Регулярность')) {
      return Icons.calendar_today;
    } else if (factor.contains('Недостаточно данных')) {
      return Icons.info_outline;
    } else {
      switch (impact) {
        case 'positive':
          return Icons.thumb_up;
        case 'negative':
          return Icons.thumb_down;
        default:
          return Icons.remove;
      }
    }
  }

  Color _getCorrelationColor(String impact) {
    switch (impact) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getImpactLabel(String impact) {
    switch (impact) {
      case 'positive':
        return 'Положительное влияние';
      case 'negative':
        return 'Отрицательное влияние';
      default:
        return 'Нейтральное влияние';
    }
  }
}
