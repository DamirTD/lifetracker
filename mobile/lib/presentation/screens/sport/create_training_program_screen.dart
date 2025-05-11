import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/data/models/sport/training_program.dart';
import 'package:mobile/data/models/sport/training_section.dart';
import 'package:mobile/data/models/sport/training_exercise.dart';
import 'package:mobile/presentation/providers/sport_provider.dart';

class CreateTrainingProgramScreen extends StatefulWidget {
  final int sportId;
  final String sportName;
  final String? initialGoal;

  const CreateTrainingProgramScreen({
    super.key,
    required this.sportId,
    required this.sportName,
    this.initialGoal,
  });

  @override
  CreateTrainingProgramScreenState createState() =>
      CreateTrainingProgramScreenState();
}

class CreateTrainingProgramScreenState
    extends State<CreateTrainingProgramScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _recommendationController =
      TextEditingController();

  final List<TrainingSection> _sections = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialGoal != null) {
      _goalController.text = widget.initialGoal!;
    }

    // Добавляем первую секцию по умолчанию
    _addSection();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _recommendationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Новая программа: ${widget.sportName}')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Название программы',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите название программы';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _goalController,
                  decoration: const InputDecoration(
                    labelText: 'Цель программы',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите цель программы';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _recommendationController,
                  decoration: const InputDecoration(
                    labelText: 'Рекомендации (необязательно)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Секции тренировки',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._buildSectionsWidgets(),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _addSection,
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить секцию'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child:
                        _isSubmitting
                            ? const CircularProgressIndicator()
                            : const Text('Создать программу тренировок'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSectionsWidgets() {
    List<Widget> sectionWidgets = [];

    for (int i = 0; i < _sections.length; i++) {
      final section = _sections[i];
      sectionWidgets.add(
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Секция ${i + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeSection(i),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: section.name,
                  decoration: const InputDecoration(
                    labelText: 'Название секции',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _sections[i] = TrainingSection(
                        name: value,
                        exercises: section.exercises,
                      );
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите название секции';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Упражнения',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...section.exercises.asMap().entries.map((entry) {
                  final j = entry.key;
                  final exercise = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text('Упражнение ${j + 1}')),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeExercise(i, j),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: exercise.name,
                            decoration: const InputDecoration(
                              labelText: 'Название упражнения',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _sections[i].exercises[j] = TrainingExercise(
                                  name: value,
                                  reps: exercise.reps,
                                  videoUrl: exercise.videoUrl,
                                );
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Введите название упражнения';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: exercise.reps.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Количество повторений',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _sections[i].exercises[j] = TrainingExercise(
                                  name: exercise.name,
                                  reps: int.tryParse(value) ?? 0,
                                  videoUrl: exercise.videoUrl,
                                );
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Введите количество повторений';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Введите число';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: exercise.videoUrl,
                            decoration: const InputDecoration(
                              labelText: 'Ссылка на видео (необязательно)',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _sections[i].exercises[j] = TrainingExercise(
                                  name: exercise.name,
                                  reps: exercise.reps,
                                  videoUrl: value.isNotEmpty ? value : null,
                                );
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                ElevatedButton.icon(
                  onPressed: () => _addExercise(i),
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить упражнение'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return sectionWidgets;
  }

  void _addSection() {
    setState(() {
      _sections.add(
        TrainingSection(
          name: '',
          exercises: [TrainingExercise(name: '', reps: 0)],
        ),
      );
    });
  }

  void _removeSection(int index) {
    if (_sections.length > 1) {
      setState(() {
        _sections.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Должна быть хотя бы одна секция')),
      );
    }
  }

  void _addExercise(int sectionIndex) {
    if (_sections[sectionIndex].exercises.length < 5) {
      setState(() {
        _sections[sectionIndex].exercises.add(
          TrainingExercise(name: '', reps: 0),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Максимум 5 упражнений в секции')),
      );
    }
  }

  void _removeExercise(int sectionIndex, int exerciseIndex) {
    if (_sections[sectionIndex].exercises.length > 1) {
      setState(() {
        _sections[sectionIndex].exercises.removeAt(exerciseIndex);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Должно быть хотя бы одно упражнение')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final program = TrainingProgram(
        sportId: widget.sportId,
        goal: _goalController.text,
        name: _nameController.text,
        recommendation:
            _recommendationController.text.isNotEmpty
                ? _recommendationController.text
                : null,
        sections: _sections,
      );

      final provider = Provider.of<SportProvider>(context, listen: false);
      final success = await provider.createPersonalTrainingProgram(program);

      setState(() {
        _isSubmitting = false;
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Программа тренировок успешно создана')),
        );
        Navigator.pop(context, true); // ← ВОТ ЭТО
      }
    }
  }
}
