// lib/presentation/screens/diet/diet_statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/presentation/providers/diet_provider.dart';

class DietStatisticsScreen extends StatefulWidget {
  const DietStatisticsScreen({super.key});

  @override
  State<DietStatisticsScreen> createState() => _DietStatisticsScreenState();
}

class _DietStatisticsScreenState extends State<DietStatisticsScreen> {
  String _selectedPeriod = 'month';
  final List<Map<String, String>> _periodOptions = [
    {'value': 'week', 'label': 'Неделя'},
    {'value': 'month', 'label': 'Месяц'},
    {'value': 'quarter', 'label': 'Квартал'},
    {'value': 'year', 'label': 'Год'},
  ];

  Map<String, dynamic>? _statistics;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dietProvider = Provider.of<DietProvider>(context, listen: false);
      final response = await dietProvider.loadStatisticsForPeriod(_selectedPeriod);

      setState(() {
        _statistics = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика питания'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorView()
          : _statistics == null
          ? _buildEmptyView()
          : _buildStatisticsView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки данных',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Неизвестная ошибка',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadStatistics,
            child: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bar_chart,
            color: Colors.grey,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Нет данных о питании',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Начните добавлять продукты в рацион, чтобы увидеть статистику',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsView() {
    final average = _statistics!['average'];
    final successRate = _statistics!['success_rate'];
    final mostFrequentFoods = _statistics!['most_frequent_foods'] as List?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 24),

          // Карточка достижения целей
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Достижение целей',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Успешных дней',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_statistics!['goal_achieved_days']} из ${_statistics!['total_days']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Процент успеха',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$successRate%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getSuccessColor(successRate),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress bar
                  LinearProgressIndicator(
                    value: successRate / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(_getSuccessColor(successRate)),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Карточка средних значений
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Средние значения',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNutrientRow(
                    'Калории',
                    average['calories'],
                    Icons.local_fire_department,
                    Colors.red,
                    'ккал',
                  ),
                  const Divider(),
                  _buildNutrientRow(
                    'Белки',
                    average['protein'],
                    Icons.fitness_center,
                    Colors.blue,
                    'г',
                  ),
                  const Divider(),
                  _buildNutrientRow(
                    'Жиры',
                    average['fat'],
                    Icons.opacity,
                    Colors.amber,
                    'г',
                  ),
                  const Divider(),
                  _buildNutrientRow(
                    'Углеводы',
                    average['carbohydrates'],
                    Icons.grain,
                    Colors.green,
                    'г',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Самые частые продукты
          if (mostFrequentFoods != null && mostFrequentFoods.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Самые частые продукты',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      mostFrequentFoods.length,
                          (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                mostFrequentFoods[index]['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              '${mostFrequentFoods[index]['count'] ?? 0} раз',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Выберите период',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPeriod,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              items: _periodOptions.map((period) {
                return DropdownMenuItem<String>(
                  value: period['value'],
                  child: Text(period['label'] ?? ''),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null && value != _selectedPeriod) {
                  setState(() {
                    _selectedPeriod = value;
                  });
                  _loadStatistics();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(
      String title,
      dynamic value,
      IconData icon,
      Color color,
      String unit,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            '$value $unit',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSuccessColor(double rate) {
    if (rate < 30) {
      return Colors.red;
    } else if (rate < 70) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}