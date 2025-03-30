import 'package:flutter/material.dart';

class WaterProgressCircle extends StatelessWidget {
  final double radius;
  final double progress;
  final int consumedMl;
  final int goalMl;

  const WaterProgressCircle({
    super.key,
    required this.radius,
    required this.progress,
    required this.consumedMl,
    required this.goalMl,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background circle
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue[50],
          ),
        ),

        // Progress circle
        SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 15,
            backgroundColor: Colors.blue[100],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Colors.green : Colors.blue,
            ),
          ),
        ),

        // Inner content
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$consumedMl',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            Text(
              'мл',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.blue[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'из $goalMl мл',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: progress >= 1.0 ? Colors.green : Colors.blue[700],
              ),
            ),
          ],
        ),
      ],
    );
  }
}