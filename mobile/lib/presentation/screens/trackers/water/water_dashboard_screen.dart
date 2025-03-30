import 'package:flutter/material.dart';
import 'package:mobile/presentation/screens/trackers/water/water_analytics_screen.dart';
import 'package:mobile/presentation/screens/trackers/water/water_eco_screen.dart';
import 'package:mobile/presentation/screens/trackers/water/water_reminders_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/water/water_progress.dart';
import '../../../providers/water_providers.dart';
import '../../../widgets/water/water_glass_button.dart';
import '../../../widgets/water/water_progress_circle.dart';
import '../../../widgets/water/water_stats_cart.dart';

class WaterDashboardScreen extends StatefulWidget {
  const WaterDashboardScreen({super.key});

  @override
  WaterDashboardScreenState createState() => WaterDashboardScreenState();
}

class WaterDashboardScreenState extends State<WaterDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<WaterProvider>(context, listen: false);
      provider.loadDailyStats();
      provider.loadOverallStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Трекер воды'),
      ),
      body: Consumer<WaterProvider>(
        builder: (context, waterProvider, child) {
          if (waterProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (waterProvider.dailyProgress == null) {
            return _buildNoProgressView(context);
          }

          return _buildDashboard(context, waterProvider);
        },
      ),
    );
  }

  Widget _buildNoProgressView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.water_drop_outlined,
            size: 64,
            color: Colors.blue.withAlpha(128),
          ),
          const SizedBox(height: 16),
          const Text(
            'Начните отслеживать потребление воды',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Сначала настройте дневную норму',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/water/settings');
            },
            child: const Text('Настроить дневную норму'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WaterProvider provider) {
    final progress = provider.dailyProgress!;
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadDailyStats();
        await provider.loadOverallStats();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, progress),
              const SizedBox(height: 24),
              Center(
                child: WaterProgressCircle(
                  radius: 120,
                  progress: progress.percentComplete / 100,
                  consumedMl: progress.consumedMl,
                  goalMl: progress.dailyGoalMl,
                ),
              ),
              const SizedBox(height: 24),
              _buildGlassControls(context, provider, progress),
              const SizedBox(height: 16),
              Text(
                'Статистика',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _buildStatsCards(context, provider, progress),
              const SizedBox(height: 16),
              _buildNavigationButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WaterProgress progress) {
    final theme = Theme.of(context);
    final today = DateFormat.yMMMMd('ru').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          today,
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          'Ваш прогресс на сегодня',
          style: theme.textTheme.headlineSmall,
        ),
      ],
    );
  }

  Widget _buildGlassControls(
      BuildContext context,
      WaterProvider provider,
      WaterProgress progress
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Добавить стакан воды',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                WaterGlassButton(
                  label: 'Стандартный\n${progress.glassVolumeMl} мл',
                  icon: Icons.local_drink,
                  onPressed: () {
                    provider.addGlass();
                  },
                ),
                WaterGlassButton(
                  label: 'Бутылка\n500 мл',
                  icon: Icons.water_drop,
                  onPressed: () {
                    provider.addGlass(volumeMl: 500);
                  },
                ),
                WaterGlassButton(
                  label: 'Другой\nобъем',
                  icon: Icons.add,
                  onPressed: () {
                    _showCustomVolumeDialog(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.remove),
              label: const Text('Удалить последний стакан'),
              onPressed: () {
                provider.removeGlass();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(
      BuildContext context,
      WaterProvider provider,
      WaterProgress progress
      ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: WaterStatsCard(
                title: 'Стаканов',
                value: progress.glassesToday.toString(),
                icon: Icons.local_drink,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: WaterStatsCard(
                title: 'Осталось',
                value: '${progress.remainingMl} мл',
                icon: Icons.water_drop_outlined,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer<WaterProvider>(
          builder: (context, waterProvider, child) {
            if (waterProvider.overallStats == null) {
              return const SizedBox.shrink();
            }

            final stats = waterProvider.overallStats!;

            return Row(
              children: [
                Expanded(
                  child: WaterStatsCard(
                    title: 'Серия дней',
                    value: stats.currentStreak.toString(),
                    icon: Icons.whatshot,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: WaterStatsCard(
                    title: 'Эффективность',
                    value: '${stats.successRate}%',
                    icon: Icons.analytics,
                    color: Colors.purple,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.eco),
                label: const Text('Экология'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const WaterEcoScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.alarm),
                label: const Text('Напоминания'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const WaterRemindersScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.insights),
                label: const Text('Аналитика'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const WaterAnalyticsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCustomVolumeDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Укажите объем'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Объем (мл)',
              suffixText: 'мл',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                final volumeText = controller.text.trim();
                if (volumeText.isNotEmpty) {
                  final volume = int.tryParse(volumeText);
                  if (volume != null && volume > 0) {
                    Provider.of<WaterProvider>(context, listen: false)
                        .addGlass(volumeMl: volume);
                  }
                }
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }
}