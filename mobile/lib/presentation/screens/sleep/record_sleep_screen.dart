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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: colors.onSurface),
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildMainParametersCard(theme, colors),
                  const SizedBox(height: 20),
                  _buildInterruptionsCard(theme, colors),
                  const SizedBox(height: 20),
                  _buildSleepConditionsCard(theme, colors),
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

  Widget _buildMainParametersCard(ThemeData theme, ColorScheme colors) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.bedtime_rounded, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  'Основные параметры',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildTimePickerTile(
            context,
            title: 'Время отхода ко сну',
            value: _formatTimeOfDay(_bedtime),
            onTap: _selectBedtime,
            icon: Icons.nightlight_round,
          ),
          const Divider(height: 1, indent: 16),
          _buildTimePickerTile(
            context,
            title: 'Время пробуждения',
            value: _formatTimeOfDay(_wakeUpTime),
            onTap: _selectWakeUpTime,
            icon: Icons.wb_sunny,
          ),
          const Divider(height: 1, indent: 16),
          _buildMoodSelectorTile(context),
        ],
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.primary.withAlpha((0.1 * 255).round()),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: colors.primary),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurface.withAlpha((0.8 * 255).round()),
        ),
      ),
      subtitle: Text(
        value,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: colors.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colors.onSurface.withAlpha((0.6 * 255).round()),
      ),
      onTap: onTap,
      minVerticalPadding: 0,
    );
  }

  Widget _buildMoodSelectorTile(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.primary.withAlpha((0.1 * 255).round()),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.mood, size: 20, color: colors.primary),
      ),
      title: Text(
        'Настроение при пробуждении',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurface.withAlpha((0.8 * 255).round()),
        ),
      ),
      subtitle: Text(
        _moodOnWaking ?? 'Выберите настроение',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color:
              _moodOnWaking != null
                  ? colors.onSurface
                  : colors.onSurface.withAlpha((0.5 * 255).round()),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colors.onSurface.withAlpha((0.6 * 255).round()),
      ),
      onTap: _selectMood,
    );
  }

  Widget _buildInterruptionsCard(ThemeData theme, ColorScheme colors) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.pause_circle, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  'Прерывания сна',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: colors.primary),
                  onPressed: _addInterruption,
                  tooltip: 'Добавить прерывание',
                  splashRadius: 20,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _interruptions.isEmpty
              ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Центр по горизонтали
                    children: [
                      Icon(
                        Icons.hotel_rounded,
                        size: 48,
                        color: colors.onSurface.withAlpha((0.3 * 255).round()),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Нет прерываний',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface.withAlpha(
                            (0.5 * 255).round(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Нажмите + чтобы добавить',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withAlpha(
                            (0.4 * 255).round(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _interruptions.length,
                separatorBuilder:
                    (_, __) => const Divider(height: 1, indent: 16),
                itemBuilder: (context, index) {
                  final interruption = _interruptions[index];
                  return Dismissible(
                    key: Key('interruption-$index'),
                    background: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) async {
                      return await _confirmDeleteInterruption(index);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withAlpha(
                          (0.4 * 255).round(),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        leading: Icon(
                          Icons.access_time,
                          color: colors.onSurface.withAlpha(
                            (0.6 * 255).round(),
                          ),
                        ),
                        title: Text(
                          interruption.time,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          interruption.reason,
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: colors.onSurface.withAlpha(
                              (0.4 * 255).round(),
                            ),
                          ),
                          onPressed: () => _confirmDeleteInterruption(index),
                          splashRadius: 20,
                        ),
                        minVerticalPadding: 0,
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }

  Widget _buildSleepConditionsCard(ThemeData theme, ColorScheme colors) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.thermostat_auto_rounded, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  'Условия сна',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Температура в комнате (°C)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.outline),
                ),
                filled: true,
                fillColor: colors.surfaceContainerHighest.withAlpha(
                  (0.4 * 255).round(),
                ),
                prefixIcon: Icon(
                  Icons.thermostat,
                  color: colors.onSurface.withAlpha((0.6 * 255).round()),
                ),
                suffixText: '°C',
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
              ),
              style: theme.textTheme.bodyLarge,
              keyboardType: TextInputType.number,
              onChanged:
                  (value) =>
                      setState(() => _temperature = double.tryParse(value)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Уровень шума',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.outline),
                ),
                filled: true,
                fillColor: colors.surfaceContainerHighest.withAlpha(
                  (0.4 * 255).round(),
                ),
                prefixIcon: Icon(
                  Icons.volume_up,
                  color: colors.onSurface.withAlpha((0.6 * 255).round()),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 16,
                ),
              ),
              value: _noiseLevel,
              items:
                  _noiseLevelOptions.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Row(
                        children: [
                          Icon(
                            entry.value,
                            size: 20,
                            color: colors.onSurface.withAlpha(
                              (0.8 * 255).round(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(entry.key, style: theme.textTheme.bodyLarge),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (value) => setState(() => _noiseLevel = value),
              dropdownColor: colors.surface,
              borderRadius: BorderRadius.circular(12),
              icon: Icon(
                Icons.arrow_drop_down,
                color: colors.onSurface.withAlpha((0.6 * 255).round()),
              ),
              style: theme.textTheme.bodyLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Уровень освещения',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.outline),
                ),
                filled: true,
                fillColor: colors.surfaceContainerHighest.withAlpha(
                  (0.4 * 255).round(),
                ),
                prefixIcon: Icon(
                  Icons.lightbulb_outline,
                  color: colors.onSurface.withAlpha((0.6 * 255).round()),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 16,
                ),
              ),
              value: _lightLevel,
              items:
                  _lightLevelOptions.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Row(
                        children: [
                          Icon(
                            entry.value,
                            size: 20,
                            color: colors.onSurface.withAlpha(
                              (0.8 * 255).round(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(entry.key, style: theme.textTheme.bodyLarge),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (value) => setState(() => _lightLevel = value),
              dropdownColor: colors.surface,
              borderRadius: BorderRadius.circular(12),
              icon: Icon(
                Icons.arrow_drop_down,
                color: colors.onSurface.withAlpha((0.6 * 255).round()),
              ),
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ColorScheme colors) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        onPressed: _isSubmitting ? null : _submitForm,
        child:
            _isSubmitting
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: colors.onPrimary,
                  ),
                )
                : const Text(
                  'СОХРАНИТЬ ДАННЫЕ О СНЕ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
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
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Удалить',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
    );

    return confirmed ?? false;
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Как записывать сон?',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Для точного анализа вашего сна:\n\n'
                    '1. Укажите точное время отхода ко сну и пробуждения\n'
                    '2. Отметьте все ночные пробуждения\n'
                    '3. Опишите условия сна (температуру, шум, освещение)\n'
                    '4. Оцените свое состояние после пробуждения\n\n'
                    'Чем точнее данные, тем полезнее будут рекомендации!',
                    style: TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Понятно'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectBedtime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _bedtime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _bedtime = picked);
  }

  Future<void> _selectWakeUpTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _wakeUpTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _wakeUpTime = picked);
  }

  void _selectMood() {
    final colors = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Выберите настроение',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _moodOptions.length,
                itemBuilder: (context, index) {
                  final mood = _moodOptions[index];
                  return ListTile(
                    title: Text(mood),
                    onTap: () {
                      setState(() => _moodOnWaking = mood);
                      Navigator.pop(context);
                    },
                    trailing:
                        _moodOnWaking == mood
                            ? Icon(Icons.check, color: colors.primary)
                            : null,
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _addInterruption() {
    TimeOfDay interruptionTime = TimeOfDay.now();
    String interruptionReason = '';
    final colors = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Добавить прерывание',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Время прерывания'),
                  subtitle: Text(
                    _formatTimeOfDay(interruptionTime),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  trailing: Icon(Icons.access_time, color: colors.primary),
                  onTap: () async {
                    final picked = await showTimePicker(
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
                  decoration: InputDecoration(
                    labelText: 'Причина прерывания',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colors.surfaceContainerHighest.withAlpha(
                      (0.4 * 255).round(),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (value) => interruptionReason = value,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Отмена'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Добавить'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

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
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            isSuccess
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
