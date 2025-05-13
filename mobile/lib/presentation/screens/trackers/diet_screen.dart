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

class _DietScreenState extends State<DietScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _selectedDate = DateTime.now();

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

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      Provider.of<DietProvider>(
        context,
        listen: false,
      ).setDate(DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  void _showAddFoodDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AddFoodDialog(
            onAdd: (Food food, double quantity, String mealType) {
              final entry = DietEntry(
                foodId: food.id,
                foodName: food.name,
                quantity: quantity,
                date: DateFormat('yyyy-MM-dd').format(_selectedDate),
                mealType: mealType,
                calories: 0,
                protein: 0,
                fat: 0,
                carbohydrates: 0,
              );
              Provider.of<DietProvider>(context, listen: false).addFood(entry);
              Navigator.of(context).pop();
            },
          ),
    );
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => SafeArea(
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
                      MaterialPageRoute(
                        builder: (_) => const DietGoalsScreen(),
                      ),
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
                      MaterialPageRoute(
                        builder: (_) => const DietStatisticsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Обновить данные'),
                  onTap: () {
                    Navigator.pop(context);
                    Provider.of<DietProvider>(
                      context,
                      listen: false,
                    ).loadInitialData();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: const Text('Закрыть'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }

  List<DietEntry> _getEntriesForMealType(String mealType) {
    final state = Provider.of<DietProvider>(context).state;
    return state.dailyDiet?.entries
            .where((entry) => entry.mealType == mealType)
            .toList() ??
        [];
  }

  Widget _buildMealSection(String type, String title) {
    final entries = _getEntriesForMealType(type);
    if (entries.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...entries.map(
          (entry) => DietEntryCard(
            entry: entry,
            onDelete:
                () => Provider.of<DietProvider>(
                  context,
                  listen: false,
                ).deleteFood(entry.id!),
            onEdit: (quantity) {
              Provider.of<DietProvider>(
                context,
                listen: false,
              ).updateFood(entry.id!, {'quantity': quantity});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMealTab(String type) {
    final entries = _getEntriesForMealType(type);
    return entries.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.no_food, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text('Нет данных', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        )
        : ListView.builder(
          itemCount: entries.length,
          padding: const EdgeInsets.all(16),
          itemBuilder:
              (_, i) => DietEntryCard(
                entry: entries[i],
                onDelete:
                    () => Provider.of<DietProvider>(
                      context,
                      listen: false,
                    ).deleteFood(entries[i].id!),
                onEdit: (quantity) {
                  Provider.of<DietProvider>(
                    context,
                    listen: false,
                  ).updateFood(entries[i].id!, {'quantity': quantity});
                },
              ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<DietProvider>(context).state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Рацион питания'),
        actions: [
          IconButton(
            onPressed: _selectDate,
            icon: const Icon(Icons.calendar_today),
          ),
          IconButton(onPressed: _openMenu, icon: const Icon(Icons.more_vert)),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Итоги'),
            Tab(text: 'Завтрак'),
            Tab(text: 'Обед'),
            Tab(text: 'Ужин'),
            Tab(text: 'Перекус'),
          ],
        ),
      ),
      body:
          state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DailySummaryCard(dailyDiet: state.dailyDiet),
                        const SizedBox(height: 16),
                        const Text(
                          'Прогресс по нутриентам',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        NutrientsProgress(dailyDiet: state.dailyDiet),
                        const SizedBox(height: 16),
                        _buildMealSection('breakfast', 'Завтрак'),
                        const SizedBox(height: 16),
                        _buildMealSection('lunch', 'Обед'),
                        const SizedBox(height: 16),
                        _buildMealSection('dinner', 'Ужин'),
                        const SizedBox(height: 16),
                        _buildMealSection('snack', 'Перекус'),
                      ],
                    ),
                  ),
                  _buildMealTab('breakfast'),
                  _buildMealTab('lunch'),
                  _buildMealTab('dinner'),
                  _buildMealTab('snack'),
                ],
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFoodDialog,
        icon: const Icon(Icons.add),
        label: const Text('Добавить еду'),
      ),
    );
  }
}
