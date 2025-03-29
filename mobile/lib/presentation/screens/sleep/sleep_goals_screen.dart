import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/presentation/providers/sleep_provider.dart';

import '../../../data/models/sleep/sleep_goal.dart';

class SleepGoalsScreen extends StatefulWidget {
  const SleepGoalsScreen({super.key});

  @override
  State<SleepGoalsScreen> createState() => _SleepGoalsScreenState();
}

class _SleepGoalsScreenState extends State<SleepGoalsScreen> {
  bool _isEditing = false;

  final _formKey = GlobalKey<FormState>();

  int _targetHours = 8;
  TimeOfDay _targetBedtime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _targetWakeTime = const TimeOfDay(hour: 7, minute: 0);
  int _maxInterruptions = 0;

  @override
  void initState() {
    super.initState();

    // Загружаем цели при монтировании виджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SleepProvider>(context, listen: false);
      provider.loadGoal();
      provider.loadGoalProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepProvider>(
      builder: (context, provider, child) {
        final goal = provider.goal;
        final progress = provider.goalProgress;

        // Инициализируем значения, если есть цель
        if (goal != null && !_isEditing) {
          _targetHours = goal.targetHours;

          List<String> bedtimeParts = goal.targetBedtime.split(':');
          _targetBedtime = TimeOfDay(
            hour: int.parse(bedtimeParts[0]),
            minute: int.parse(bedtimeParts[1]),
          );

          List<String> wakeTimeParts = goal.targetWakeTime.split(':');
          _targetWakeTime = TimeOfDay(
            hour: int.parse(wakeTimeParts[0]),
            minute: int.parse(wakeTimeParts[1]),
          );

          _maxInterruptions = goal.maxInterruptions;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Текущие цели или форма редактирования
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ваши цели по сну',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          if (!_isEditing)
                            TextButton.icon(
                              icon: const Icon(Icons.edit),
                              label: const Text('Изменить'),
                              onPressed: () {
                                setState(() {
                                  _isEditing = true;
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_isEditing) ...[
                        _buildGoalEditingForm(),
                      ] else if (goal != null) ...[
                        _buildGoalDisplay(goal),
                      ] else ...[
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'У вас еще нет установленных целей по сну',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = true;
                              });
                            },
                            child: const Text('Установить цели'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Прогресс по целям
              if (progress != null) ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ваш прогресс',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 16),

                        // Общий прогресс
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Общий прогресс',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('${progress.overallProgress}%'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: progress.overallProgress / 100,
                              minHeight: 8,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Продолжительность сна
                        _buildProgressItem(
                          'Продолжительность сна',
                          progress.hoursProgress,
                          Icons.timelapse,
                        ),

                        const SizedBox(height: 12),

                        // Соблюдение времени отхода ко сну
                        _buildProgressItem(
                          'Время отхода ко сну',
                          progress.bedtimeAdherence,
                          Icons.nightlight,
                        ),

                        const SizedBox(height: 12),

                        // Соблюдение времени пробуждения
                        _buildProgressItem(
                          'Время пробуждения',
                          progress.wakeTimeAdherence,
                          Icons.wb_sunny,
                        ),

                        const SizedBox(height: 12),

                        // Прерывания сна
                        _buildProgressItem(
                          'Контроль прерываний',
                          progress.interruptionsSuccess,
                          Icons.block,
                        ),

                        const SizedBox(height: 16),

                        // Текущая серия
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Текущая серия: ${progress.streak} ${_getDaysString(progress.streak)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Форма редактирования целей
  Widget _buildGoalEditingForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Целевое количество часов сна
          Text(
            'Целевое количество часов сна: $_targetHours ч',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: _targetHours.toDouble(),
            min: 5,
            max: 12,
            divisions: 7,
            label: _targetHours.toString(),
            onChanged: (value) {
              setState(() {
                _targetHours = value.round();
              });
            },
          ),

          const SizedBox(height: 16),

          // Целевое время отхода ко сну
          ListTile(
            title: const Text('Целевое время отхода ко сну'),
            subtitle: Text(_formatTimeOfDay(_targetBedtime)),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: _targetBedtime,
              );
              if (picked != null && picked != _targetBedtime) {
                setState(() {
                  _targetBedtime = picked;
                });
              }
            },
          ),

          const SizedBox(height: 8),

          // Целевое время пробуждения
          ListTile(
            title: const Text('Целевое время пробуждения'),
            subtitle: Text(_formatTimeOfDay(_targetWakeTime)),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: _targetWakeTime,
              );
              if (picked != null && picked != _targetWakeTime) {
                setState(() {
                  _targetWakeTime = picked;
                });
              }
            },
          ),

          const SizedBox(height: 16),

          // Максимальное количество прерываний
          Text(
            'Допустимое количество прерываний: $_maxInterruptions',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Slider(
            value: _maxInterruptions.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            label: _maxInterruptions.toString(),
            onChanged: (value) {
              setState(() {
                _maxInterruptions = value.round();
              });
            },
          ),

          const SizedBox(height: 24),

          // Кнопки действий
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                  });
                },
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: _saveGoals,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Отображение текущих целей
  Widget _buildGoalDisplay(SleepGoal goal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.timelapse),
          title: const Text('Целевое количество часов сна'),
          trailing: Text(
            '${goal.targetHours} ч',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.nightlight),
          title: const Text('Целевое время отхода ко сну'),
          trailing: Text(
            goal.targetBedtime,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.wb_sunny),
          title: const Text('Целевое время пробуждения'),
          trailing: Text(
            goal.targetWakeTime,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.block),
          title: const Text('Максимальное количество прерываний'),
          trailing: Text(
            '${goal.maxInterruptions}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Элемент прогресса
  Widget _buildProgressItem(String title, int progress, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(title),
            const Spacer(),
            Text('$progress%'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress / 100,
          minHeight: 6,
        ),
      ],
    );
  }

  // Форматирование TimeOfDay
  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final String hour = timeOfDay.hour.toString().padLeft(2, '0');
    final String minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Получение правильного склонения слова "день"
  String _getDaysString(int days) {
    if (days % 10 == 1 && days % 100 != 11) {
      return 'день';
    } else if ([2, 3, 4].contains(days % 10) && ![12, 13, 14].contains(days % 100)) {
      return 'дня';
    } else {
      return 'дней';
    }
  }

  Future<void> _saveGoals() async {
    if (_formKey.currentState!.validate()) {
      final goal = SleepGoal(
        targetHours: _targetHours,
        targetBedtime: _formatTimeOfDay(_targetBedtime),
        targetWakeTime: _formatTimeOfDay(_targetWakeTime),
        maxInterruptions: _maxInterruptions,
      );

      final provider = Provider.of<SleepProvider>(context, listen: false);
      final success = await provider.setSleepGoal(goal);

      if (success) {
        if (!mounted) return;

        setState(() {
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Цели по сну успешно сохранены'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${provider.error ?? "Неизвестная ошибка"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}