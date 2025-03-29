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

class _SleepScreenState extends State<SleepScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SleepProvider>(context, listen: false).loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Трекер сна'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Статистика'),
            Tab(text: 'Тенденции'),
            Tab(text: 'Цели'),
            Tab(text: 'Взаимосвязи'),
          ],
        ),
      ),
      body: Consumer<SleepProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ошибка: ${provider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadData();
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: const [
              SleepStatisticsScreen(),
              SleepTrendsScreen(),
              SleepGoalsScreen(),
              SleepCorrelationsScreen(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RecordSleepScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Записать сон'),
      ),
    );
  }
}