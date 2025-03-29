import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/data/models/sport/training_program.dart';
import 'package:mobile/presentation/providers/sport_provider.dart';

class CompleteTrainingScreen extends StatefulWidget {
  final TrainingProgram program;

  const CompleteTrainingScreen({
    super.key,
    required this.program,
  });

  @override
  CompleteTrainingScreenState createState() => CompleteTrainingScreenState();
}

class CompleteTrainingScreenState extends State<CompleteTrainingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  bool _isSubmitting = false;
  int _currentSection = 0;
  final List<bool> _completedExercises = [];

  @override
  void initState() {
    super.initState();
    // Инициализируем список отслеживания завершенных упражнений
    if (widget.program.sections != null && widget.program.sections!.isNotEmpty) {
      for (var section in widget.program.sections!) {
        for (var _ in section.exercises) {
          _completedExercises.add(false);
        }
      }
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тренировка'),
      ),
      body: widget.program.sections == null || widget.program.sections!.isEmpty
          ? _buildNoSectionsView()
          : _buildTrainingView(),
    );
  }

  Widget _buildNoSectionsView() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.fitness_center_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.program.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Цель: ${widget.program.goal}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'В этой программе нет секций с упражнениями. '
                        'Вы можете выполнять свою тренировку и ввести данные по её завершении.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildCompleteForm(),
      ],
    );
  }

  Widget _buildTrainingView() {
    final sections = widget.program.sections!;
    final currentSection = sections[_currentSection];

    return Column(
      children: [
        // Прогресс секций
        Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.grey[200],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.program.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Секции: '),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          sections.length,
                              (index) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: Chip(
                              label: Text('${index + 1}'),
                              backgroundColor: index == _currentSection
                                  ? Theme.of(context).primaryColor
                                  : index < _currentSection
                                  ? Colors.green
                                  : Colors.grey[300],
                              labelStyle: TextStyle(
                                color: index == _currentSection || index < _currentSection
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Текущая секция
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentSection.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...currentSection.exercises.asMap().entries.map((entry) {
                  final index = entry.key;
                  final exercise = entry.value;

                  // Вычисляем глобальный индекс для списка отслеживания
                  int globalIndex = 0;
                  for (int i = 0; i < _currentSection; i++) {
                    globalIndex += sections[i].exercises.length;
                  }
                  globalIndex += index;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: CheckboxListTile(
                      title: Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Повторений: ${exercise.reps}'),
                          if (exercise.videoUrl != null)
                            GestureDetector(
                              onTap: () {
                                // TODO: Открытие видео
                              },
                              child: Text(
                                'Смотреть видео',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                        ],
                      ),
                      value: _completedExercises[globalIndex],
                      onChanged: (bool? value) {
                        setState(() {
                          _completedExercises[globalIndex] = value!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),

                // Кнопки навигации
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentSection > 0)
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentSection--;
                          });
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Предыдущая'),
                      )
                    else
                      const SizedBox(),

                    if (_currentSection < sections.length - 1)
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentSection++;
                          });
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Следующая'),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () {
                          // Проверка, все ли упражнения завершены
                          if (_completedExercises.contains(false)) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Не все упражнения выполнены'),
                                content: const Text(
                                    'Вы не отметили некоторые упражнения как выполненные. '
                                        'Хотите продолжить?'
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Отмена'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _showCompleteTrainingForm();
                                    },
                                    child: const Text('Завершить'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            _showCompleteTrainingForm();
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Завершить'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCompleteTrainingForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: _buildCompleteForm(),
      ),
    );
  }

  Widget _buildCompleteForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Завершение тренировки',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _durationController,
            decoration: const InputDecoration(
              labelText: 'Длительность (минуты)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите длительность';
              }
              if (int.tryParse(value) == null) {
                return 'Введите число';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _caloriesController,
            decoration: const InputDecoration(
              labelText: 'Сожжено калорий',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите количество калорий';
              }
              if (int.tryParse(value) == null) {
                return 'Введите число';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Записать тренировку'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final duration = int.parse(_durationController.text);
      final calories = int.parse(_caloriesController.text);

      final provider = Provider.of<SportProvider>(context, listen: false);
      final success = await provider.completeTraining(
        widget.program.id!,
        duration,
        calories,
      );

      setState(() {
        _isSubmitting = false;
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Тренировка успешно записана')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }
  }
}