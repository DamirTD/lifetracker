// lib/presentation/widgets/diet/nutrients_progress.dart
import 'package:flutter/material.dart';
import 'package:mobile/data/models/diet/daily_diet.dart';

class NutrientsProgress extends StatelessWidget {
  final DailyDiet? dailyDiet;

  const NutrientsProgress({super.key, required this.dailyDiet});

  @override
  Widget build(BuildContext context) {
    if (dailyDiet == null) {
      return const SizedBox();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.outline.withAlpha((255 * 0.2).round()),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProgressItem(
              context,
              icon: Icons.local_fire_department,
              title: 'Калории',
              value: dailyDiet!.total['calories'],
              maxValue: dailyDiet!.goal['calories'],
              color: Colors.red,
              unit: 'ккал',
            ),
            const SizedBox(height: 12),
            _buildProgressItem(
              context,
              icon: Icons.fitness_center,
              title: 'Белки',
              value: dailyDiet!.total['protein'],
              maxValue: dailyDiet!.goal['protein'],
              color: Colors.blue,
              unit: 'г',
            ),
            const SizedBox(height: 12),
            _buildProgressItem(
              context,
              icon: Icons.opacity,
              title: 'Жиры',
              value: dailyDiet!.total['fat'],
              maxValue: dailyDiet!.goal['fat'],
              color: Colors.amber,
              unit: 'г',
            ),
            const SizedBox(height: 12),
            _buildProgressItem(
              context,
              icon: Icons.grain,
              title: 'Углеводы',
              value: dailyDiet!.total['carbohydrates'],
              maxValue: dailyDiet!.goal['carbohydrates'],
              color: Colors.green,
              unit: 'г',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required dynamic value,
    required dynamic maxValue,
    required Color color,
    required String unit,
  }) {
    final progress = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();

    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '$value $unit / $maxValue $unit',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: color.withAlpha((255 * 0.2).round()),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
