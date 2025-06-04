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

class _WaterScreenState extends State<WaterScreen>
    with TickerProviderStateMixin {
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
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Пожалуйста, настройте дневную норму сначала',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: theme.colorScheme.primary,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'ОК',
              textColor: Colors.white,
              onPressed:
                  () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: IndexedStack(
          key: ValueKey<int>(_currentIndex),
          index: _currentIndex,
          children: const [
            WaterDashboardScreen(),
            WaterHistoryScreen(),
            WaterSettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar:
          _currentIndex == 2 && _showInitialSetup
              ? null
              : _buildBottomNavigationBar(theme),
    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightBlueAccent.shade100, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          currentIndex: _currentIndex,
          onTap: (index) {
            if (_currentIndex == index) return;

            setState(() {
              _currentIndex = index;
              _showInitialSetup = false;
            });
          },
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedFontSize: 13,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_customize_rounded),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart_rounded),
              label: 'История',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_rounded),
              label: 'Настройки',
            ),
          ],
        ),
      ),
    );
  }
}
