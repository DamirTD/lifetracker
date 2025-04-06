import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mobile/data/models/diet/diet_entry.dart';
import 'package:mobile/data/models/diet/food.dart';
import 'package:mobile/presentation/providers/diet_provider.dart';
import 'package:mobile/presentation/widgets/diet/add_food_dialog.dart';
import 'package:mobile/presentation/widgets/diet/daily_summary_card.dart';
import 'package:mobile/presentation/widgets/diet/diet_entry_card.dart';
import 'package:mobile/presentation/widgets/diet/nutrients_progress.dart';

import 'diet/diet_goals_screen.dart';
import 'diet/diet_statistics_screen.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedDate = DateTime.now();

    // Загружаем данные при инициализации экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DietProvider>(context, listen: false).loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      Provider.of<DietProvider>(context, listen: false)
          .setDate(DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  void _showAddFoodDialog() {
    final dietProvider = Provider.of<DietProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AddFoodDialog(
        onAdd: (Food food, double quantity, String mealType) {
          final entry = DietEntry(
            foodId: food.id,
            foodName: food.name,
            quantity: quantity,
            date: DateFormat('yyyy-MM-dd').format(_selectedDate),
            mealType: mealType,
            calories: 0, // Будут рассчитаны на сервере
            protein: 0,
            fat: 0,
            carbohydrates: 0,
          );
          dietProvider.addFood(entry);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Настройка целей питания'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DietGoalsScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Статистика питания'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DietStatisticsScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Обновить данные'),
                onTap: () {
                  Navigator.pop(context);
                  Provider.of<DietProvider>(context, listen: false).loadInitialData();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Закрыть'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<DietEntry> _getEntriesForMealType(String mealType) {
    final dietState = Provider.of<DietProvider>(context).state;
    if (dietState.dailyDiet == null) {
      return [];
    }
    return dietState.dailyDiet!.entries
        .where((entry) => entry.mealType == mealType)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final dietProvider = Provider.of<DietProvider>(context);
    final dietState = dietProvider.state;
    final isLoading = dietState.isLoading;
    final hasError = dietState.error != null;
    final dailyDiet = dietState.dailyDiet;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Рацион питания'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _openMenu,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Итоги'),
            Tab(text: 'Завтрак'),
            Tab(text: 'Обед'),
            Tab(text: 'Ужин'),
          ],
        ),
      ),
      body: hasError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ошибка: ${dietState.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Provider.of<DietProvider>(context, listen: false).loadDailyDiet(),
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      )
          : isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          // Вкладка с итогами
          SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DailySummaryCard(dailyDiet: dailyDiet),
                  const SizedBox(height: 16),
                  const Text(
                    'Прогресс по нутриентам',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  NutrientsProgress(dailyDiet: dailyDiet),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Приемы пищи',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: _showAddFoodDialog,
                        child: const Text('+ Добавить'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildMealSection('breakfast', 'Завтрак'),
                  _buildMealSection('lunch', 'Обед'),
                  _buildMealSection('dinner', 'Ужин'),
                  _buildMealSection('snack', 'Перекус'),
                ],
              ),
            ),
          ),
          // Вкладка с завтраком
          _buildMealTypeTab('breakfast'),
          // Вкладка с обедом
          _buildMealTypeTab('lunch'),
          // Вкладка с ужином
          _buildMealTypeTab('dinner'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFoodDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMealSection(String mealType, String mealTitle) {
    final entries = _getEntriesForMealType(mealType);
    if (entries.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            mealTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...entries.map((entry) => DietEntryCard(
          entry: entry,
          onDelete: () => Provider.of<DietProvider>(context, listen: false).deleteFood(entry.id!),
          onEdit: (quantity) {
            Provider.of<DietProvider>(context, listen: false).updateFood(
              entry.id!,
              {'quantity': quantity},
            );
          },
        )),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMealTypeTab(String mealType) {
    final entries = _getEntriesForMealType(mealType);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('d MMMM yyyy').format(_selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddFoodDialog,
                icon: const Icon(Icons.add),
                label: const Text('Добавить'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          entries.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.no_food,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Нет записей о питании',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
              : Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return DietEntryCard(
                  entry: entry,
                  onDelete: () => Provider.of<DietProvider>(context, listen: false).deleteFood(entry.id!),
                  onEdit: (quantity) {
                    Provider.of<DietProvider>(context, listen: false).updateFood(
                      entry.id!,
                      {'quantity': quantity},
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}