import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/water_providers.dart';

class WaterHistoryScreen extends StatefulWidget {
  const WaterHistoryScreen({super.key});

  @override
  WaterHistoryScreenState createState() => WaterHistoryScreenState();
}

class WaterHistoryScreenState extends State<WaterHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedWeekStart;
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Установка текущей недели и месяца
    final now = DateTime.now();
    _selectedWeekStart = DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: now.weekday - 1)));
    _selectedMonth = DateFormat('yyyy-MM').format(now);

    Future.microtask(() {
      if (!mounted) return;
      final provider = Provider.of<WaterProvider>(context, listen: false);
      provider.loadWeeklyConsumption(startDate: _selectedWeekStart);
      provider.loadMonthlyConsumption(yearMonth: _selectedMonth);
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
        title: const Text('История потребления воды'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Неделя'),
            Tab(text: 'Месяц'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWeeklyView(),
          _buildMonthlyView(),
        ],
      ),
    );
  }

  Widget _buildWeeklyView() {
    return Consumer<WaterProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Ошибка загрузки данных',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(provider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.loadWeeklyConsumption(startDate: _selectedWeekStart);
                  },
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        if (provider.weeklyData == null) {
          return const Center(child: Text('Нет данных'));
        }

        final weeklyData = provider.weeklyData!;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      final currentWeekStart = DateTime.parse(_selectedWeekStart!);
                      final previousWeekStart = currentWeekStart.subtract(const Duration(days: 7));
                      setState(() {
                        _selectedWeekStart = DateFormat('yyyy-MM-dd').format(previousWeekStart);
                      });
                      provider.loadWeeklyConsumption(startDate: _selectedWeekStart);
                    },
                  ),
                  Expanded(
                    child: Text(
                      _getWeekLabel(_selectedWeekStart!),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      final currentWeekStart = DateTime.parse(_selectedWeekStart!);
                      final nextWeekStart = currentWeekStart.add(const Duration(days: 7));

                      // Не позволяет выбрать будущие недели
                      if (nextWeekStart.isBefore(DateTime.now())) {
                        setState(() {
                          _selectedWeekStart = DateFormat('yyyy-MM-dd').format(nextWeekStart);
                        });
                        provider.loadWeeklyConsumption(startDate: _selectedWeekStart);
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildWeeklyChart(weeklyData),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthlyView() {
    return Consumer<WaterProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Ошибка загрузки данных',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(provider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.loadMonthlyConsumption(yearMonth: _selectedMonth);
                  },
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        if (provider.monthlyData == null) {
          return const Center(child: Text('Нет данных'));
        }

        final monthlyData = provider.monthlyData!;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      final parts = _selectedMonth!.split('-');
                      final year = int.parse(parts[0]);
                      final month = int.parse(parts[1]);

                      final previousMonth = month == 1
                          ? DateTime(year - 1, 12)
                          : DateTime(year, month - 1);

                      setState(() {
                        _selectedMonth = DateFormat('yyyy-MM').format(previousMonth);
                      });

                      provider.loadMonthlyConsumption(yearMonth: _selectedMonth);
                    },
                  ),
                  Expanded(
                    child: Text(
                      _getMonthLabel(_selectedMonth!),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      final parts = _selectedMonth!.split('-');
                      final year = int.parse(parts[0]);
                      final month = int.parse(parts[1]);

                      final nextMonth = month == 12
                          ? DateTime(year + 1, 1)
                          : DateTime(year, month + 1);

                      // Не позволяет выбрать будущие месяцы
                      if (nextMonth.isBefore(DateTime.now())) {
                        setState(() {
                          _selectedMonth = DateFormat('yyyy-MM').format(nextMonth);
                        });

                        provider.loadMonthlyConsumption(yearMonth: _selectedMonth);
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildMonthlyContent(monthlyData),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeeklyChart(Map<String, dynamic> weeklyData) {
    final dailyData = weeklyData['daily_data'] as List<dynamic>;

    if (dailyData.isEmpty) {
      return const Center(child: Text('Нет данных за выбранный период'));
    }

    // Расчет общих показателей
    final totalConsumed = weeklyData['consumed_ml'] ?? 0;
    final _ = weeklyData['goal_ml'] ?? 0;
    final percentComplete = weeklyData['percent_complete'] ?? 0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Сводка за неделю',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(
                        context,
                        'Всего выпито',
                        '$totalConsumed мл',
                        Icons.water_drop,
                        Colors.blue,
                      ),
                      _buildSummaryItem(
                        context,
                        'Прогресс',
                        '$percentComplete%',
                        Icons.insert_chart,
                        Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ежедневное потребление',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildBarChart(dailyData),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyContent(Map<String, dynamic> monthlyData) {
    final dailyData = monthlyData['daily_data'] as List<dynamic>;

    if (dailyData.isEmpty) {
      return const Center(child: Text('Нет данных за выбранный период'));
    }

    final totalConsumed = monthlyData['consumed_ml'] ?? 0;
    final daysWithData = monthlyData['days_with_data'] ?? 0;
    final daysReachedGoal = monthlyData['days_reached_goal'] ?? 0;
    final _ = monthlyData['success_rate'] ?? 0;
    final averageDailyMl = monthlyData['average_daily_ml'] ?? 0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Статистика за месяц',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(
                        context,
                        'Выпито всего',
                        '$totalConsumed мл',
                        Icons.water_drop,
                        Colors.blue,
                      ),
                      _buildSummaryItem(
                        context,
                        'В среднем в день',
                        '$averageDailyMl мл',
                        Icons.bar_chart,
                        Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(
                        context,
                        'Дней отслежено',
                        '$daysWithData',
                        Icons.calendar_today,
                        Colors.teal,
                      ),
                      _buildSummaryItem(
                        context,
                        'Успешных дней',
                        '$daysReachedGoal',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ежедневное потребление',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildCalendarChart(dailyData),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1 * 255),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<dynamic> dailyData) {
    // Find the max value to scale bars appropriately
    double maxValue = 0;
    for (var item in dailyData) {
      double value = (item['consumed_ml'] as int).toDouble();
      double goal = item['daily_goal_ml'] != null ? (item['daily_goal_ml'] as int).toDouble() : 0;
      maxValue = maxValue < value ? value : maxValue;
      maxValue = maxValue < goal ? goal : maxValue;
    }

    // Add a 10% margin to the top
    maxValue *= 1.1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = (constraints.maxWidth - 40) / dailyData.length - 8;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            width: barWidth * dailyData.length + 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dailyData.asMap().entries.map((entry) {
                final item = entry.value;
                final consumed = (item['consumed_ml'] as int).toDouble();
                final goal = item['daily_goal_ml'] != null ? (item['daily_goal_ml'] as int).toDouble() : 0;
                final date = DateTime.parse(item['date']);

                String dateLabel = DateFormat.E('ru').format(date);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Stack bars for consumption and goal
                      SizedBox(
                        height: constraints.maxHeight - 60,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // Goal bar (if applicable)
                            if (goal > 0)
                              Container(
                                width: barWidth,
                                height: (goal / maxValue) * (constraints.maxHeight - 60),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),

                            // Consumed bar
                            Container(
                              width: barWidth,
                              height: (consumed / maxValue) * (constraints.maxHeight - 60),
                              decoration: BoxDecoration(
                                color: consumed >= goal && goal > 0 ? Colors.green : Colors.blue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dateLabel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${consumed.toInt()} мл',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarChart(List<dynamic> dailyData) {
    // Создаем Map с данными по дням
    final Map<DateTime, int> dateMap = {};
    final Map<DateTime, int> goalMap = {};

    for (var item in dailyData) {
      final date = DateTime.parse(item['date']);
      final consumed = item['consumed_ml'] as int;
      final goal = item['daily_goal_ml'] as int? ?? 0;

      dateMap[date] = consumed;
      goalMap[date] = goal;
    }

    // Определяем максимальный и минимальный день месяца
    final dates = dateMap.keys.toList()..sort();
    if (dates.isEmpty) {
      return const Center(child: Text('Нет данных для отображения'));
    }

    final firstDate = dates.first;
    final lastDate = dates.last;

    // Создаем массив дней месяца
    final daysInMonth = DateTime(lastDate.year, lastDate.month + 1, 0).day;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final day = index + 1;
        final date = DateTime(firstDate.year, firstDate.month, day);
        final consumed = dateMap[date] ?? 0;
        final goal = goalMap[date] ?? 0;

        // Вычисляем цвет в зависимости от того, достигнута ли цель
        Color cellColor = Colors.grey[200]!;

        if (consumed > 0) {
          if (goal > 0) {
            final percentComplete = (consumed / goal * 100).clamp(0, 100);

            if (percentComplete >= 100) {
              cellColor = Colors.green[100]!;
            } else if (percentComplete >= 75) {
              cellColor = Colors.lightGreen[100]!;
            } else if (percentComplete >= 50) {
              cellColor = Colors.yellow[100]!;
            } else if (percentComplete >= 25) {
              cellColor = Colors.orange[100]!;
            } else {
              cellColor = Colors.red[100]!;
            }
          } else {
            cellColor = Colors.blue[100]!;
          }
        }

        return Card(
          margin: const EdgeInsets.all(2),
          color: cellColor,
          child: InkWell(
            onTap: () {
              _showDayDetails(context, date, consumed, goal);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (consumed > 0)
                  Text(
                    '$consumed мл',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDayDetails(BuildContext context, DateTime date, int consumed, int goal) {
    final dateFormatted = DateFormat.yMMMd('ru').format(date);
    final percentComplete = goal > 0 ? (consumed / goal * 100).clamp(0, 100).toInt() : 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Детали за $dateFormatted'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.water_drop, color: Colors.blue),
              title: const Text('Выпито'),
              trailing: Text('$consumed мл'),
            ),
            if (goal > 0) ...[
              ListTile(
                leading: const Icon(Icons.flag, color: Colors.green),
                title: const Text('Цель'),
                trailing: Text('$goal мл'),
              ),
              ListTile(
                leading: const Icon(Icons.percent, color: Colors.orange),
                title: const Text('Прогресс'),
                trailing: Text('$percentComplete%'),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  String _getWeekLabel(String weekStart) {
    final start = DateTime.parse(weekStart);
    final end = start.add(const Duration(days: 6));

    final startLabel = DateFormat.MMMd('ru').format(start);
    final endLabel = DateFormat.MMMd('ru').format(end);

    return '$startLabel - $endLabel';
  }

  String _getMonthLabel(String monthStr) {
    final parts = monthStr.split('-');
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    return DateFormat.yMMMM('ru').format(date);
  }
}