import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/water_providers.dart';

class WaterHistoryScreen extends StatefulWidget {
  const WaterHistoryScreen({super.key});

  @override
  State<WaterHistoryScreen> createState() => _WaterHistoryScreenState();
}

class _WaterHistoryScreenState extends State<WaterHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedWeekStart;
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final now = DateTime.now();
    _selectedWeekStart = DateFormat(
      'yyyy-MM-dd',
    ).format(now.subtract(Duration(days: now.weekday - 1)));
    _selectedMonth = DateFormat('yyyy-MM').format(now);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<WaterProvider>(context, listen: false);
      provider.loadWeeklyConsumption(startDate: _selectedWeekStart);
      provider.loadMonthlyConsumption(yearMonth: _selectedMonth);
    });
  }

  List<String> _generateWeeks() {
    final now = DateTime.now();
    return List.generate(12, (i) {
      final date = now.subtract(Duration(days: now.weekday - 1 + i * 7));
      return DateFormat('yyyy-MM-dd').format(date);
    });
  }

  List<String> _generateMonths() {
    final now = DateTime.now();
    return List.generate(12, (i) {
      final date = DateTime(now.year, now.month - i);
      return DateFormat('yyyy-MM').format(date);
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
        title: const Text('История воды'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Неделя'), Tab(text: 'Месяц')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildWeeklyView(), _buildMonthlyView()],
      ),
    );
  }

  Widget _buildWeeklyView() {
    return Consumer<WaterProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButton<String>(
                value: _selectedWeekStart,
                isExpanded: true,
                items:
                    _generateWeeks()
                        .map(
                          (week) => DropdownMenuItem(
                            value: week,
                            child: Text(_getWeekLabel(week)),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedWeekStart = value);
                    provider.loadWeeklyConsumption(startDate: value);
                  }
                },
              ),
            ),
            Expanded(
              child:
                  provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.weeklyData == null
                      ? const Center(child: Text('Нет данных'))
                      : _buildBarChart(
                        provider.weeklyData!['daily_data'] ?? [],
                      ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthlyView() {
    return Consumer<WaterProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButton<String>(
                value: _selectedMonth,
                isExpanded: true,
                items:
                    _generateMonths()
                        .map(
                          (month) => DropdownMenuItem(
                            value: month,
                            child: Text(_getMonthLabel(month)),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMonth = value);
                    provider.loadMonthlyConsumption(yearMonth: value);
                  }
                },
              ),
            ),
            Expanded(
              child:
                  provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.monthlyData == null
                      ? const Center(child: Text('Нет данных'))
                      : _buildCalendarView(
                        provider.monthlyData!['daily_data'] ?? [],
                      ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBarChart(List<dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.7,
        ),
        itemCount: data.length,
        itemBuilder: (_, index) {
          final item = data[index];
          final date = DateFormat.E('ru').format(DateTime.parse(item['date']));
          final consumed = item['consumed_ml'] ?? 0;

          return Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('$consumed мл'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarView(List<dynamic> data) {
    final map = {
      for (var item in data)
        DateTime.parse(item['date']): item['consumed_ml'] as int,
    };
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
        ),
        itemCount: daysInMonth,
        itemBuilder: (_, index) {
          final day = index + 1;
          final date = DateTime(now.year, now.month, day);
          final value = map[date] ?? 0;

          return Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
              color: value > 0 ? Colors.blue.shade100 : Colors.grey.shade100,
            ),
            child: Center(
              child: Text(
                value > 0 ? '$day\n$value' : '$day',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getWeekLabel(String weekStart) {
    final start = DateTime.parse(weekStart);
    final end = start.add(const Duration(days: 6));
    return '${DateFormat.MMMd('ru').format(start)} - ${DateFormat.MMMd('ru').format(end)}';
  }

  String _getMonthLabel(String month) {
    final date = DateTime.parse('$month-01');
    return DateFormat.yMMMM('ru').format(date);
  }
}
