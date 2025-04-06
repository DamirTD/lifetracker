// lib/presentation/widgets/diet/add_food_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/data/models/diet/food.dart';
import 'package:mobile/presentation/providers/diet_provider.dart';

class AddFoodDialog extends StatefulWidget {
  final Function(Food, double, String) onAdd;

  const AddFoodDialog({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '100');
  String _selectedMealType = 'breakfast';
  Food? _selectedFood;
  bool _isSearching = false;

  // Явно типизируем как Map<String, String>
  final List<Map<String, String>> _mealTypes = [
    {'value': 'breakfast', 'label': 'Завтрак'},
    {'value': 'lunch', 'label': 'Обед'},
    {'value': 'dinner', 'label': 'Ужин'},
    {'value': 'snack', 'label': 'Перекус'},
  ];

  @override
  void initState() {
    super.initState();
    // Загрузка списка продуктов при открытии диалога
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Получаем доступ к провайдеру через context
      final provider = Provider.of<DietProvider>(context, listen: false);
      provider.loadFoods();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {
      _isSearching = true;
    });
    // Используем Provider.of вместо ref.read
    final dietProvider = Provider.of<DietProvider>(context, listen: false);
    dietProvider.loadFoods(search: query);
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Используем Provider вместо Riverpod
    final dietProvider = Provider.of<DietProvider>(context);
    final foodsList = dietProvider.foodsList;
    final isLoading = dietProvider.isLoading;

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Добавить продукт',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Поиск продукта',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _search('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                if (value.length > 2) {
                  _search(value);
                } else if (value.isEmpty) {
                  _search('');
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Результаты поиска',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (isLoading || _isSearching)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (foodsList == null || foodsList.isEmpty)
              const Center(
                child: Text('Ничего не найдено'),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: foodsList.length,
                  itemBuilder: (context, index) {
                    final food = foodsList[index];
                    return ListTile(
                      title: Text(food.name),
                      subtitle: Text(
                        '${food.calories} ккал | Б: ${food.protein}г | Ж: ${food.fat}г | У: ${food.carbohydrates}г',
                        style: const TextStyle(fontSize: 12),
                      ),
                      selected: _selectedFood?.id == food.id,
                      onTap: () {
                        setState(() {
                          _selectedFood = food;
                        });
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Количество (г)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixText: 'г',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMealType,
                    decoration: InputDecoration(
                      labelText: 'Прием пищи',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _mealTypes.map((mealType) {
                      return DropdownMenuItem<String>(
                        value: mealType['value'],
                        child: Text(mealType['label'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMealType = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Отмена'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _selectedFood == null
                      ? null
                      : () {
                    final quantity = double.tryParse(_quantityController.text) ?? 100;
                    widget.onAdd(_selectedFood!, quantity, _selectedMealType);
                  },
                  child: const Text('Добавить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}