import 'package:flutter/material.dart';
import 'package:mobile/presentation/screens/home/profile_screen.dart';
import 'package:mobile/presentation/widgets/category_card.dart';

import 'package:mobile/presentation/screens/trackers/diet_screen.dart';
import 'package:mobile/presentation/screens/trackers/sleep_screen.dart';
import 'package:mobile/presentation/screens/trackers/finance_screen.dart';
import 'package:mobile/presentation/screens/trackers/sport_screen.dart';
import 'package:mobile/presentation/screens/trackers/tasks_screen.dart';
import 'package:mobile/presentation/screens/trackers/water_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Главная страница"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 22, color: Colors.blue),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()), // Открытие профиля
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.0,
          children: const [
            CategoryCard(icon: Icons.task_alt, label: "Задачи", color: Colors.purple, screen: TasksScreen()),
            CategoryCard(icon: Icons.attach_money, label: "Финансы", color: Colors.green, screen: FinanceScreen()),
            CategoryCard(icon: Icons.bedtime_rounded, label: "Сон", color: Colors.indigo, screen: SleepScreen()),
            CategoryCard(icon: Icons.opacity, label: "Вода", color: Colors.blue, screen: WaterScreen()),
            CategoryCard(icon: Icons.directions_run, label: "Спорт", color: Colors.orange, screen: SportScreen()),
            CategoryCard(icon: Icons.local_dining, label: "Диета", color: Colors.red, screen: DietScreen()),
          ],
        ),
      ),
    );
  }
}
