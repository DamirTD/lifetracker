import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Заглушки для экранов
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Задачи')),
      body: const Center(child: Text('Экран задач')),
    );
  }
}

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Финансы')),
      body: const Center(child: Text('Финансовый трекер')),
    );
  }
}

class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сон')),
      body: const Center(child: Text('Трекер сна')),
    );
  }
}

class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вода')),
      body: const Center(child: Text('Трекер воды')),
    );
  }
}

class SportScreen extends StatelessWidget {
  const SportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Спорт')),
      body: const Center(child: Text('Тренировки')),
    );
  }
}

class DietScreen extends StatelessWidget {
  const DietScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Диета')),
      body: const Center(child: Text('Рацион питания')),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');

  if (!context.mounted) return;

  Future.microtask(() {
    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, '/logout');
  });
}

  Widget _buildCategoryCard(BuildContext context, IconData icon, String label, Color color, Widget screen) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // ignore: deprecated_member_use
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

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
            onPressed: () => _showLogoutModal(context),
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
  children: [
    _buildCategoryCard(context, Icons.task_alt, "Задачи", Colors.purple, const TasksScreen()),
    _buildCategoryCard(context, Icons.attach_money, "Финансы", Colors.green, const FinanceScreen()),
    _buildCategoryCard(context, Icons.bedtime_rounded, "Сон", Colors.indigo, const SleepScreen()),
    _buildCategoryCard(context, Icons.opacity, "Вода", Colors.blue, const WaterScreen()),
    _buildCategoryCard(context, Icons.directions_run, "Спорт", Colors.orange, const SportScreen()),
    _buildCategoryCard(context, Icons.local_dining, "Диета", Colors.red, const DietScreen()),
  ],
),

      ),
    );
  }

  void _showLogoutModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Выйти из аккаунта'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}