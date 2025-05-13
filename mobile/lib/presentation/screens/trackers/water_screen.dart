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
  bool _showInitialSetup = false;

  @override
  void initState() {
    super.initState();
    _checkInitialSetup();
  }

  Future<void> _checkInitialSetup() async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final provider = Provider.of<WaterProvider>(context, listen: false);
    await provider.loadDailyStats();

    if (mounted && provider.dailyProgress == null) {
      setState(() {
        _currentIndex = 2;
        _showInitialSetup = true;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Пожалуйста, настройте дневную норму сначала'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const WaterDashboardScreen(),
          const WaterHistoryScreen(),
          WaterSettingsScreen(initialSetup: _showInitialSetup),
        ],
      ),
      bottomNavigationBar:
          _currentIndex == 2 && _showInitialSetup
              ? null
              : _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (_currentIndex == index) return;

        setState(() {
          _currentIndex = index;
          _showInitialSetup = false;
        });
      },
      selectedItemColor: Colors.blue[800],
      unselectedItemColor: Colors.grey[600],
      selectedFontSize: 12,
      unselectedFontSize: 12,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          activeIcon: Icon(Icons.dashboard_rounded, size: 28),
          label: 'Главная',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_rounded),
          activeIcon: Icon(Icons.history_rounded, size: 28),
          label: 'История',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_rounded),
          activeIcon: Icon(Icons.settings_rounded, size: 28),
          label: 'Настройки',
        ),
      ],
    );
  }
}
