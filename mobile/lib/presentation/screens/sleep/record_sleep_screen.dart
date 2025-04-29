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
  final _scrollController = ScrollController();

  TimeOfDay _bedtime = TimeOfDay.now();
  TimeOfDay _wakeUpTime = TimeOfDay.now();
  String? _moodOnWaking;
  final List<SleepInterruption> _interruptions = [];
  double? _temperature;
  String? _noiseLevel;
  String? _lightLevel;

  final List<String> _moodOptions = [
    'Отлично 😊',
    'Хорошо 🙂',
    'Нормально 😐',
    'Плохо 🙁',
    'Ужасно 😣',
  ];

  final Map<String, IconData> _noiseLevelOptions = {
    'Тихо': Icons.volume_mute,
    'Умеренно': Icons.volume_down,
    'Шумно': Icons.volume_up,
  };

  final Map<String, IconData> _lightLevelOptions = {
    'Темно': Icons.dark_mode,
    'Полутемно': Icons.nights_stay,
    'Светло': Icons.light_mode,
  };

  bool _isSubmitting = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Запись сна',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
            tooltip: 'Справка',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildMainParametersCard(theme),
                  const SizedBox(height: 16),
                  _buildInterruptionsCard(theme),
                  const SizedBox(height: 16),
                  _buildSleepConditionsCard(theme),
                  const SizedBox(height: 24),
                  _buildSubmitButton(colors),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainParametersCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Основные параметры', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildTimePickerTile(
              context,
              title: 'Время отхода ко сну',
              value: _formatTimeOfDay(_bedtime),
              onTap: _selectBedtime,
              icon: Icons.nightlight_round,
            ),
            const Divider(height: 24),
            _buildTimePickerTile(
              context,
              title: 'Время пробуждения',
              value: _formatTimeOfDay(_wakeUpTime),
              onTap: _selectWakeUpTime,
              icon: Icons.wb_sunny,
            ),
            const Divider(height: 24),
            _buildMoodSelectorTile(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerTile(
    BuildContext context, {
    required String title,
    required String value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primary.withAlpha((255 * 0.1).round()),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(value, style: Theme.of(context).textTheme.titleMedium),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildMoodSelectorTile(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primary.withAlpha((255 * 0.1).round()),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.mood, color: Theme.of(context).colorScheme.primary),
      ),
      title: const Text('Настроение при пробуждении'),
      subtitle: Text(
        _moodOnWaking ?? 'Не выбрано',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color:
              _moodOnWaking != null
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).hintColor,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: _selectMood,
    );
  }

  Widget _buildInterruptionsCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Прерывания сна', style: theme.textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _addInterruption,
                  tooltip: 'Добавить прерывание',
                ),
              ],
            ),
            const SizedBox(height: 8),
            _interruptions.isEmpty
                ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.hotel, size: 48, color: theme.hintColor),
                        const SizedBox(height: 8),
                        Text(
                          'Нет прерываний',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _interruptions.length,
                  separatorBuilder: (_, __) => const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final interruption = _interruptions[index];
                    return Dismissible(
                      key: Key('interruption-$index'),
                      background: Container(
                        color: Theme.of(context).colorScheme.error,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        return await _confirmDeleteInterruption(index);
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.access_time),
                        title: Text(interruption.time),
                        subtitle: Text(interruption.reason),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDeleteInterruption(index),
                        ),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepConditionsCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Условия сна', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Температура в комнате (°C)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.thermostat),
                suffixText: '°C',
              ),
              keyboardType: TextInputType.number,
              onChanged:
                  (value) =>
                      setState(() => _temperature = double.tryParse(value)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Уровень шума',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.volume_up),
              ),
              value: _noiseLevel,
              items:
                  _noiseLevelOptions.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Row(
                        children: [
                          Icon(entry.value, size: 20),
                          const SizedBox(width: 12),
                          Text(entry.key),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (value) => setState(() => _noiseLevel = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Уровень освещения',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.lightbulb_outline),
              ),
              value: _lightLevel,
              items:
                  _lightLevelOptions.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Row(
                        children: [
                          Icon(entry.value, size: 20),
                          const SizedBox(width: 12),
                          Text(entry.key),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (value) => setState(() => _lightLevel = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ColorScheme colors) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      onPressed: _isSubmitting ? null : _submitForm,
      child:
          _isSubmitting
              ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : const Text(
                'СОХРАНИТЬ ДАННЫЕ О СНЕ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
    );
  }

  Future<bool> _confirmDeleteInterruption(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Удалить прерывание?'),
            content: const Text(
              'Вы уверены, что хотите удалить это прерывание сна?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('ОТМЕНА'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'УДАЛИТЬ',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() => _interruptions.removeAt(index));
      return true;
    }
    return false;
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Как записывать сон?'),
            content: const SingleChildScrollView(
              child: Text(
                'Для точного анализа вашего сна:\n\n'
                '1. Укажите точное время отхода ко сну и пробуждения\n'
                '2. Отметьте все ночные пробуждения\n'
                '3. Опишите условия сна (температуру, шум, освещение)\n'
                '4. Оцените свое состояние после пробуждения\n\n'
                'Чем точнее данные, тем полезнее будут рекомендации!',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ПОНЯТНО'),
              ),
            ],
          ),
    );
  }

  // Остальные методы (_formatTimeOfDay, _selectBedtime, _selectWakeUpTime,
  // _selectMood, _addInterruption, _removeInterruption, _submitForm, _showSnackBar) остаются без изменений.

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final String hour = timeOfDay.hour.toString().padLeft(2, '0');
    final String minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectBedtime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _bedtime,
    );
    if (picked != null) {
      setState(() {
        _bedtime = picked;
      });
    }
  }

  Future<void> _selectWakeUpTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _wakeUpTime,
    );
    if (picked != null) {
      setState(() {
        _wakeUpTime = picked;
      });
    }
  }

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

  void _addInterruption() {
    TimeOfDay interruptionTime = TimeOfDay.now();
    String interruptionReason = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить прерывание'),
          content: Column(
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                if (interruptionReason.isNotEmpty) {
                  setState(() {
                    _interruptions.add(
                      SleepInterruption(
                        time: _formatTimeOfDay(interruptionTime),
                        reason: interruptionReason,
                      ),
                    );
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        SleepEnvironment? environment;
        if (_temperature != null ||
            _noiseLevel != null ||
            _lightLevel != null) {
          environment = SleepEnvironment(
            temperature: _temperature,
            noiseLevel: _noiseLevel,
            lightLevel: _lightLevel,
          );
        }

        final sleep = Sleep(
          bedtime: _formatTimeOfDay(_bedtime),
          wakeUpTime: _formatTimeOfDay(_wakeUpTime),
          interruptions: _interruptions.isNotEmpty ? _interruptions : null,
          moodOnWaking: _moodOnWaking,
          sleepEnvironment: environment,
          duration: 0,
          quality: '',
        );

        final provider = Provider.of<SleepProvider>(context, listen: false);
        final success = await provider.recordSleep(sleep);

        if (success) {
          if (!mounted) return;
          _showSnackBar('Данные о сне успешно сохранены', isSuccess: true);
          Navigator.pop(context);
        } else {
          if (!mounted) return;
          _showSnackBar(
            'Ошибка: ${provider.error ?? "Неизвестная ошибка"}',
            isSuccess: false,
          );
        }
      } catch (e) {
        _showSnackBar('Ошибка: $e', isSuccess: false);
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
