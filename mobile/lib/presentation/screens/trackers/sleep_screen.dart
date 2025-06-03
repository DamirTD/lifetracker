import 'package:flutter/material.dart';
import 'package:mobile/presentation/screens/sleep/record_sleep_screen.dart';
import 'package:mobile/presentation/screens/sleep/sleep_correlations_screen.dart';
import 'package:mobile/presentation/screens/sleep/sleep_goals_screen.dart';
import 'package:mobile/presentation/screens/sleep/sleep_statistics_screen.dart';
import 'package:mobile/presentation/screens/sleep/sleep_trends_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobile/presentation/providers/sleep_provider.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    SleepStatisticsScreen(),
    SleepTrendsScreen(),
    SleepGoalsScreen(),
    SleepCorrelationsScreen(),
  ];

  final List<String> _titles = [
    'Статистика',
    'Тенденции',
    'Цели',
    'Взаимосвязи',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SleepProvider>(context, listen: false).loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        toolbarHeight: 50,
        elevation: 0,
        actions: [
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: Colors.grey[50],
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              margin: EdgeInsets.zero,
              accountName: Text('Трекер сна', style: TextStyle(fontSize: 18)),
              accountEmail: null,
              decoration: BoxDecoration(color: Colors.blueAccent),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem(Icons.insights, 'Статистика', 0),
                  _buildDrawerItem(Icons.trending_up, 'Тенденции', 1),
                  _buildDrawerItem(Icons.flag, 'Цели', 2),
                  _buildDrawerItem(Icons.link, 'Взаимосвязи', 3),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Consumer<SleepProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Загрузка сна...', style: TextStyle(fontSize: 14)),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 40,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ошибка при загрузке',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Повторить'),
                      onPressed: () => provider.loadData(),
                    ),
                  ],
                ),
              ),
            );
          }

          return IndexedStack(index: _selectedIndex, children: _screens);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RecordSleepScreen(),
              fullscreenDialog: true,
            ),
          );
          if (!mounted) return;
          // ignore: use_build_context_synchronously
          Provider.of<SleepProvider>(context, listen: false).loadData();
        },
        label: const Text('Сон'),
        icon: const Icon(Icons.nightlight_round),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      selected: _selectedIndex == index,
      selectedTileColor: Colors.blue.withAlpha((0.1 * 255).round()),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.of(context).pop(); // закрыть drawer
      },
    );
  }
}
