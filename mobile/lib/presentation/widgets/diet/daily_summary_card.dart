import 'package:flutter/material.dart';
import 'package:mobile/data/models/diet/daily_diet.dart';

class DailySummaryCard extends StatelessWidget {
  final DailyDiet? dailyDiet;

  const DailySummaryCard({super.key, required this.dailyDiet});

  @override
  Widget build(BuildContext context) {
    if (dailyDiet == null) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .colorScheme
            .surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Итоги дня',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNutrientSummary(
                  context,
                  'Калории',
                  dailyDiet!.total['calories'],
                  dailyDiet!.goal['calories'],
                  dailyDiet!.remaining['calories'],
                  dailyDiet!.progress['calories'],
                  Colors.red,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildNutrientSummary(
                  context,
                  'Белки',
                  dailyDiet!.total['protein'],
                  dailyDiet!.goal['protein'],
                  dailyDiet!.remaining['protein'],
                  dailyDiet!.progress['protein'],
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNutrientSummary(
                  context,
                  'Жиры',
                  dailyDiet!.total['fat'],
                  dailyDiet!.goal['fat'],
                  dailyDiet!.remaining['fat'],
                  dailyDiet!.progress['fat'],
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildNutrientSummary(
                  context,
                  'Углеводы',
                  dailyDiet!.total['carbohydrates'],
                  dailyDiet!.goal['carbohydrates'],
                  dailyDiet!.remaining['carbohydrates'],
                  dailyDiet!.progress['carbohydrates'],
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientSummary(BuildContext context,
      String title,
      dynamic consumed,
      dynamic goal,
      dynamic remaining,
      dynamic progress,
      Color color,) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (progress / 100).clamp(0.0, 1.0),
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(8),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '$consumed/$goal',
              style: TextStyle(
                fontSize: 14,
                color: Theme
                    .of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.7),
              ),
            ),
            const Spacer(),
            Text(
              'Ост: $remaining',
              style: TextStyle(
                fontSize: 14,
                color: Theme
                    .of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}