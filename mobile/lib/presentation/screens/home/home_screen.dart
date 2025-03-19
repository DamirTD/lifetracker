import 'package:flutter/material.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/presentation/screens/home/profile_screen.dart';
import 'package:mobile/presentation/widgets/category_card.dart';
import 'package:mobile/presentation/screens/trackers/diet_screen.dart';
import 'package:mobile/presentation/screens/trackers/sleep_screen.dart';
import 'package:mobile/presentation/screens/trackers/finance_screen.dart';
import 'package:mobile/presentation/screens/trackers/sport_screen.dart';
import 'package:mobile/presentation/screens/trackers/tasks_screen.dart';
import 'package:mobile/presentation/screens/trackers/water_screen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mobile/data/repositories/user_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserRepository _userRepository = UserRepository();
  UserModel? _user;
  bool _isLoading = true;
  String? _error;
  bool _disposed = false;
  
  int notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!_disposed && mounted) {
      setState(fn);
    }
  }

  Future<void> _loadUser() async {
    _safeSetState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await _userRepository.getUser();
      
      if (!mounted) return;
      
      _safeSetState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      _safeSetState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _quickAddWater() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Вода добавлена!")),
    );
  }

  void _quickAddTask() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Новая задача добавлена!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Ошибка: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUser,
                child: const Text('Попробовать снова'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Ошибка загрузки пользователя'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/welcome'),
                child: const Text('Вернуться на экран входа'),
              ),
            ],
          ),
        ),
      );
    }
    
    final userName = _user!.name;
    final avatarUrl = '';
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Добро пожаловать,", style: Theme.of(context).textTheme.bodySmall),
            Text(userName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    foregroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl.isEmpty ? const Icon(Icons.person, color: Colors.blue) : null,
                  ),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                ),
                if (notificationCount > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red,
                      child: Text(
                        notificationCount.toString(),
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return CategoryCard(
              icon: category['icon'],
              label: category['label'],
              color: category['color'],
              screen: category['screen'],
            );
          },
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 10,
        spaceBetweenChildren: 12,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.local_drink, color: Colors.white),
            backgroundColor: Colors.blue,
            label: "Добавить воду",
            labelBackgroundColor: Colors.blue.shade100,
            labelStyle: const TextStyle(color: Colors.black),
            onTap: _quickAddWater,
          ),
          SpeedDialChild(
            child: const Icon(Icons.task_alt, color: Colors.white),
            backgroundColor: Colors.green,
            label: "Новая задача",
            labelBackgroundColor: Colors.green.shade100,
            labelStyle: const TextStyle(color: Colors.black),
            onTap: _quickAddTask,
          ),
        ],
      ),
    );
  }
}

final List<Map<String, dynamic>> _categories = [
  {'icon': Icons.task_alt, 'label': "Задачи", 'color': Colors.purple, 'screen': const TasksScreen()},
  {'icon': Icons.attach_money, 'label': "Финансы", 'color': Colors.green, 'screen': const FinanceScreen()},
  {'icon': Icons.bedtime_rounded, 'label': "Сон", 'color': Colors.indigo, 'screen': const SleepScreen()},
  {'icon': Icons.opacity, 'label': "Вода", 'color': Colors.blue, 'screen': const WaterScreen()},
  {'icon': Icons.directions_run, 'label': "Спорт", 'color': Colors.orange, 'screen': const SportScreen()},
  {'icon': Icons.local_dining, 'label': "Диета", 'color': Colors.red, 'screen': const DietScreen()},
];