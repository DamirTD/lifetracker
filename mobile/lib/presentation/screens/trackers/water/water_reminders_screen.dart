import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/water/water_reminder.dart';
import '../../../providers/water_providers.dart';


class WaterRemindersScreen extends StatefulWidget {
  const WaterRemindersScreen({super.key});

  @override
  WaterRemindersScreenState createState() => WaterRemindersScreenState();
}

class WaterRemindersScreenState extends State<WaterRemindersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<WaterProvider>(context, listen: false);
      provider.loadReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Напоминания о питье воды'),
      ),
      body: Consumer<WaterProvider>(
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
                      provider.loadReminders();
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          return _buildRemindersList(context, provider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddReminderDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRemindersList(BuildContext context, WaterProvider provider) {
    if (provider.reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'У вас еще нет напоминаний',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте напоминание, чтобы не забывать пить воду',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _showAddReminderDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Добавить напоминание'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: provider.reminders.length,
      itemBuilder: (context, index) {
        final reminder = provider.reminders[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('${reminder.startTime} - ${reminder.endTime}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Интервал: ${reminder.intervalMinutes} мин'),
                Text('Дни: ${_formatDaysOfWeek(reminder.daysOfWeek)}'),
              ],
            ),
            leading: Icon(
              Icons.alarm,
              color: reminder.isEnabled ? Colors.blue : Colors.grey,
            ),
            trailing: Switch(
              value: reminder.isEnabled,
              onChanged: (value) {
                provider.toggleReminder(reminder.id!, value);
              },
            ),
            onTap: () {
              _showEditReminderDialog(context, reminder);
            },
            onLongPress: () {
              _showDeleteReminderDialog(context, reminder.id!);
            },
          ),
        );
      },
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final provider = Provider.of<WaterProvider>(context, listen: false);

    // Установка дефолтных значений
    TimeOfDay startTime = TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = TimeOfDay(hour: 20, minute: 0);
    int intervalMinutes = 60;
    List<int> daysOfWeek = [1, 2, 3, 4, 5]; // Понедельник - Пятница

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Новое напоминание'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Время начала напоминаний:'),
                    ListTile(
                      title: Text('${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                        );
                        if (picked != null) {
                          setState(() {
                            startTime = picked;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 8),
                    Text('Время окончания напоминаний:'),
                    ListTile(
                      title: Text('${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: endTime,
                        );
                        if (picked != null) {
                          setState(() {
                            endTime = picked;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),
                    Text('Интервал между напоминаниями:'),
                    Slider(
                      value: intervalMinutes.toDouble(),
                      min: 15,
                      max: 240,
                      divisions: 15,
                      label: '${intervalMinutes} мин',
                      onChanged: (value) {
                        setState(() {
                          intervalMinutes = value.toInt();
                        });
                      },
                    ),
                    Center(
                      child: Text(
                        '${intervalMinutes} минут',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text('Дни недели:'),
                    const SizedBox(height: 8),
                    _buildDaySelector(context, daysOfWeek, (newDays) {
                      setState(() {
                        daysOfWeek = newDays;
                      });
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Проверка валидности времени
                    if (_isEndTimeBeforeStartTime(startTime, endTime)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Время окончания должно быть позже времени начала'),
                        ),
                      );
                      return;
                    }

                    // Создание нового напоминания
                    final reminder = WaterReminder(
                      startTime: '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                      endTime: '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                      intervalMinutes: intervalMinutes,
                      daysOfWeek: daysOfWeek,
                      isEnabled: true,
                    );

                    provider.saveReminder(reminder);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Добавить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditReminderDialog(BuildContext context, WaterReminder reminder) {
    final provider = Provider.of<WaterProvider>(context, listen: false);

    // Парсинг времени из строки
    final startParts = reminder.startTime.split(':');
    final endParts = reminder.endTime.split(':');

    TimeOfDay startTime = TimeOfDay(
      hour: int.parse(startParts[0]),
      minute: int.parse(startParts[1]),
    );

    TimeOfDay endTime = TimeOfDay(
      hour: int.parse(endParts[0]),
      minute: int.parse(endParts[1]),
    );

    int intervalMinutes = reminder.intervalMinutes;
    List<int> daysOfWeek = List.from(reminder.daysOfWeek);
    bool isEnabled = reminder.isEnabled;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Редактировать напоминание'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Активация/деактивация
                    SwitchListTile(
                      title: const Text('Активировать напоминания'),
                      value: isEnabled,
                      onChanged: (value) {
                        setState(() {
                          isEnabled = value;
                        });
                      },
                    ),

                    const Divider(),

                    Text('Время начала напоминаний:'),
                    ListTile(
                      title: Text('${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                        );
                        if (picked != null) {
                          setState(() {
                            startTime = picked;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 8),
                    Text('Время окончания напоминаний:'),
                    ListTile(
                      title: Text('${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: endTime,
                        );
                        if (picked != null) {
                          setState(() {
                            endTime = picked;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),
                    Text('Интервал между напоминаниями:'),
                    Slider(
                      value: intervalMinutes.toDouble(),
                      min: 15,
                      max: 240,
                      divisions: 15,
                      label: '${intervalMinutes} мин',
                      onChanged: (value) {
                        setState(() {
                          intervalMinutes = value.toInt();
                        });
                      },
                    ),
                    Center(
                      child: Text(
                        '${intervalMinutes} минут',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text('Дни недели:'),
                    const SizedBox(height: 8),
                    _buildDaySelector(context, daysOfWeek, (newDays) {
                      setState(() {
                        daysOfWeek = newDays;
                      });
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
                    _showDeleteReminderDialog(context, reminder.id!);
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Удалить'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Проверка валидности времени
                    if (_isEndTimeBeforeStartTime(startTime, endTime)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Время окончания должно быть позже времени начала'),
                        ),
                      );
                      return;
                    }

                    // Обновление напоминания
                    final updatedReminder = WaterReminder(
                      id: reminder.id,
                      startTime: '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                      endTime: '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                      intervalMinutes: intervalMinutes,
                      daysOfWeek: daysOfWeek,
                      isEnabled: isEnabled,
                      message: reminder.message,
                    );

                    provider.saveReminder(updatedReminder);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDaySelector(
      BuildContext context,
      List<int> selectedDays,
      Function(List<int>) onDaysChanged,
      ) {
    const dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    return Wrap(
      spacing: 8,
      children: List.generate(7, (index) {
        final day = index + 1; // 1-based день недели (1 = Понедельник)
        final isSelected = selectedDays.contains(day);

        return FilterChip(
          label: Text(dayNames[index]),
          selected: isSelected,
          onSelected: (selected) {
            final newDays = List<int>.from(selectedDays);
            if (selected) {
              if (!newDays.contains(day)) {
                newDays.add(day);
              }
            } else {
              newDays.remove(day);
            }
            onDaysChanged(newDays);
          },
          backgroundColor: Colors.grey[200],
          selectedColor: Colors.blue[100],
          checkmarkColor: Colors.blue,
        );
      }),
    );
  }

  void _showDeleteReminderDialog(BuildContext context, int reminderId) {
    final provider = Provider.of<WaterProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить напоминание?'),
          content: const Text('Вы уверены, что хотите удалить это напоминание?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                provider.deleteReminder(reminderId);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  bool _isEndTimeBeforeStartTime(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes <= startMinutes;
  }

  String _formatDaysOfWeek(List<int> days) {
    if (days.length == 7) {
      return 'Ежедневно';
    }

    if (days.length == 5 &&
        days.contains(1) && days.contains(2) && days.contains(3) &&
        days.contains(4) && days.contains(5)) {
      return 'Будни';
    }

    if (days.length == 2 && days.contains(6) && days.contains(7)) {
      return 'Выходные';
    }

    const dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days.map((day) => dayNames[day - 1]).join(', ');
  }
}