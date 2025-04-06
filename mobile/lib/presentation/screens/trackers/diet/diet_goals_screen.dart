import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/data/models/diet/diet_goals.dart';
import 'package:mobile/presentation/providers/diet_provider.dart';

class DietGoalsScreen extends StatefulWidget {
  const DietGoalsScreen({super.key});

  @override
  State<DietGoalsScreen> createState() => _DietGoalsScreenState();
}

class _DietGoalsScreenState extends State<DietGoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Загружаем текущие цели при открытии экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentGoals();
    });
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  void _loadCurrentGoals() {
    final dietProvider = Provider.of<DietProvider>(context, listen: false);
    final currentGoals = dietProvider.dietGoals;

    if (currentGoals != null) {
      setState(() {
        _caloriesController.text = currentGoals.calories.toString();
        _proteinController.text = currentGoals.protein.toString();
        _fatController.text = currentGoals.fat.toString();
        _carbsController.text = currentGoals.carbohydrates.toString();
      });
    }
  }

  Future<void> _saveGoals() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final dietGoals = DietGoals(
          calories: int.parse(_caloriesController.text),
          protein: double.parse(_proteinController.text),
          fat: double.parse(_fatController.text),
          carbohydrates: double.parse(_carbsController.text),
        );

        final dietProvider = Provider.of<DietProvider>(context, listen: false);
        final success = await dietProvider.updateDietGoals(dietGoals);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Цели питания успешно обновлены'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка: ${dietProvider.error ?? "Не удалось обновить цели"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройка целей питания'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Цели питания',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Установите ежедневные цели по калориям и макронутриентам',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildNutrientField(
                        controller: _caloriesController,
                        label: 'Калории',
                        icon: Icons.local_fire_department,
                        color: Colors.red,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите количество калорий';
                          }
                          final number = int.tryParse(value);
                          if (number == null) {
                            return 'Пожалуйста, введите целое число';
                          }
                          if (number < 500 || number > 10000) {
                            return 'Значение должно быть от 500 до 10000';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildNutrientField(
                        controller: _proteinController,
                        label: 'Белки (г)',
                        icon: Icons.fitness_center,
                        color: Colors.blue,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите количество белков';
                          }
                          final number = double.tryParse(value);
                          if (number == null) {
                            return 'Пожалуйста, введите число';
                          }
                          if (number < 0 || number > 500) {
                            return 'Значение должно быть от 0 до 500';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildNutrientField(
                        controller: _fatController,
                        label: 'Жиры (г)',
                        icon: Icons.opacity,
                        color: Colors.amber,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите количество жиров';
                          }
                          final number = double.tryParse(value);
                          if (number == null) {
                            return 'Пожалуйста, введите число';
                          }
                          if (number < 0 || number > 500) {
                            return 'Значение должно быть от 0 до 500';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildNutrientField(
                        controller: _carbsController,
                        label: 'Углеводы (г)',
                        icon: Icons.grain,
                        color: Colors.green,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите количество углеводов';
                          }
                          final number = double.tryParse(value);
                          if (number == null) {
                            return 'Пожалуйста, введите число';
                          }
                          if (number < 0 || number > 1000) {
                            return 'Значение должно быть от 0 до 1000';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Информация о макронутриентах',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        title: 'Белки',
                        description: 'Строительный материал для мышц, 4 ккал/г',
                        icon: Icons.fitness_center,
                        color: Colors.blue,
                      ),
                      const Divider(),
                      _buildInfoRow(
                        title: 'Жиры',
                        description: 'Необходимы для гормонов, 9 ккал/г',
                        icon: Icons.opacity,
                        color: Colors.amber,
                      ),
                      const Divider(),
                      _buildInfoRow(
                        title: 'Углеводы',
                        description: 'Основной источник энергии, 4 ккал/г',
                        icon: Icons.grain,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: _saveGoals,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: validator,
    );
  }

  Widget _buildInfoRow({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}