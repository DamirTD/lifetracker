import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/presentation/providers/sleep_provider.dart';

import '../../../data/models/sleep/sleep.dart';

class RecordSleepScreen extends StatefulWidget {
  const RecordSleepScreen({super.key});

  @override
  State<RecordSleepScreen> createState() => _RecordSleepScreenState();
}

class _RecordSleepScreenState extends State<RecordSleepScreen> {
  final _formKey = GlobalKey<FormState>();

  TimeOfDay _bedtime = TimeOfDay.now();
  TimeOfDay _wakeUpTime = TimeOfDay.now();
  String? _moodOnWaking;
  final List<SleepInterruption> _interruptions = [];

  double? _temperature;
  String? _noiseLevel;
  String? _lightLevel;

  final List<String> _moodOptions = ['отлично', 'хорошо', 'нормально', 'плохо', 'ужасно'];
  final List<String> _noiseLevelOptions = ['тихо', 'умеренно', 'шумно'];
  final List<String> _lightLevelOptions = ['темно', 'полутемно', 'светло'];

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Запись данных о сне'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Основные параметры',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 16),

                      // Время отхода ко сну
                      ListTile(
                        title: const Text('Время отхода ко сну'),
                        subtitle: Text(_formatTimeOfDay(_bedtime)),
                        trailing: const Icon(Icons.access_time),
                        onTap: _selectBedtime,
                      ),

                      const Divider(),

                      // Время пробуждения
                      ListTile(
                        title: const Text('Время пробуждения'),
                        subtitle: Text(_formatTimeOfDay(_wakeUpTime)),
                        trailing: const Icon(Icons.access_time),
                        onTap: _selectWakeUpTime,
                      ),

                      const Divider(),

                      // Настроение при пробуждении
                      ListTile(
                        title: const Text('Настроение при пробуждении'),
                        subtitle: _moodOnWaking != null
                            ? Text(_moodOnWaking!)
                            : const Text('Выберите настроение'),
                        trailing: const Icon(Icons.mood),
                        onTap: _selectMood,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Прерывания сна
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
                            'Прерывания сна',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addInterruption,
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      _interruptions.isEmpty
                          ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Нет прерываний'),
                        ),
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _interruptions.length,
                        itemBuilder: (context, index) {
                          final interruption = _interruptions[index];
                          return ListTile(
                            title: Text('Время: ${interruption.time}'),
                            subtitle: Text('Причина: ${interruption.reason}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeInterruption(index),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Условия сна
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Условия сна',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 16),

                      // Температура
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Температура в комнате (°C)',
                          border: OutlineInputBorder(),
                          suffixText: '°C',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              _temperature = double.tryParse(value);
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Уровень шума
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Уровень шума',
                          border: OutlineInputBorder(),
                        ),
                        value: _noiseLevel,
                        items: _noiseLevelOptions.map((String level) {
                          return DropdownMenuItem<String>(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _noiseLevel = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Уровень освещения
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Уровень освещения',
                          border: OutlineInputBorder(),
                        ),
                        value: _lightLevel,
                        items: _lightLevelOptions.map((String level) {
                          return DropdownMenuItem<String>(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _lightLevel = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Сохранить', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Выбор времени отхода ко сну
  Future<void> _selectBedtime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _bedtime,
    );
    if (picked != null && picked != _bedtime) {
      setState(() {
        _bedtime = picked;
      });
    }
  }

  // Выбор времени пробуждения
  Future<void> _selectWakeUpTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _wakeUpTime,
    );
    if (picked != null && picked != _wakeUpTime) {
      setState(() {
        _wakeUpTime = picked;
      });
    }
  }

  // Выбор настроения
  void _selectMood() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: _moodOptions.length,
          itemBuilder: (context, index) {
            final mood = _moodOptions[index];
            return ListTile(
              title: Text(mood),
              onTap: () {
                setState(() {
                  _moodOnWaking = mood;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  // Добавление прерывания сна
  void _addInterruption() {
    showDialog(
      context: context,
      builder: (context) {
        TimeOfDay interruptionTime = TimeOfDay.now();
        String interruptionReason = '';

        return AlertDialog(
          title: const Text('Добавить прерывание'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Время прерывания'),
                  subtitle: Text(_formatTimeOfDay(interruptionTime)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: interruptionTime,
                    );
                    if (picked != null) {
                      interruptionTime = picked;
                      (context as Element).markNeedsBuild();
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Причина прерывания',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    interruptionReason = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                if (interruptionReason.isNotEmpty) {
                  setState(() {
                    _interruptions.add(SleepInterruption(
                      time: _formatTimeOfDay(interruptionTime),
                      reason: interruptionReason,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  // Удаление прерывания сна
  void _removeInterruption(int index) {
    setState(() {
      _interruptions.removeAt(index);
    });
  }

  // Форматирование времени
  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final String hour = timeOfDay.hour.toString().padLeft(2, '0');
    final String minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Отправка формы
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Создаем окружающую среду, если есть данные
        SleepEnvironment? environment;
        if (_temperature != null || _noiseLevel != null || _lightLevel != null) {
          environment = SleepEnvironment(
            temperature: _temperature,
            noiseLevel: _noiseLevel,
            lightLevel: _lightLevel,
          );
        }

        // Создаем объект сна для отправки
        final sleep = Sleep(
          bedtime: _formatTimeOfDay(_bedtime),
          wakeUpTime: _formatTimeOfDay(_wakeUpTime),
          interruptions: _interruptions.isNotEmpty ? _interruptions : null,
          moodOnWaking: _moodOnWaking,
          sleepEnvironment: environment,
          duration: 0, // Будет рассчитано на сервере
          quality: '', // Будет определено на сервере
        );

        // Отправляем данные
        final provider = Provider.of<SleepProvider>(context, listen: false);
        final success = await provider.recordSleep(sleep);

        if (success) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Данные о сне успешно сохранены'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context);
        } else {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка: ${provider.error ?? "Неизвестная ошибка"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
}