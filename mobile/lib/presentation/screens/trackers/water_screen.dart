import 'package:flutter/material.dart';
import 'package:mobile/presentation/screens/trackers/water/water_dashboard_screen.dart';
import 'package:mobile/presentation/screens/trackers/water/water_history_screen.dart';
import 'package:mobile/presentation/screens/trackers/water/water_settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobile/presentation/providers/water_providers.dart';

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Check if daily goal is set and navigate to settings if not
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<WaterProvider>(context, listen: false);
      provider.loadDailyStats().then((_) {
        if (provider.dailyProgress == null && _currentIndex != 2) {
          setState(() {
            _currentIndex = 2; // Navigate to settings tab
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Пожалуйста, настройте дневную норму сначала'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const WaterDashboardScreen(),
          const WaterHistoryScreen(),
          const WaterSettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'История',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}