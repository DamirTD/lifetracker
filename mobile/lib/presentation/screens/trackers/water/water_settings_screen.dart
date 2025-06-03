import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/data/models/water/water_container.dart';
import 'package:mobile/data/models/water/water_goal_settings.dart';
import 'package:mobile/presentation/providers/water_providers.dart';

class WaterSettingsScreen extends StatefulWidget {
  final bool initialSetup;

  const WaterSettingsScreen({super.key, this.initialSetup = false});

  @override
  WaterSettingsScreenState createState() => WaterSettingsScreenState();
}

class WaterSettingsScreenState extends State<WaterSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController(text: '70');
  final _heightController = TextEditingController(text: '170');
  final _glassVolumeController = TextEditingController(text: '250');

  bool _isLoading = false;
  bool _showBackButton = false;

  @override
  void initState() {
    super.initState();
    _showBackButton = !widget.initialSetup;
    _loadCurrentSettings();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WaterProvider>(context, listen: false).loadContainers();
    });
  }

  Future<void> _loadCurrentSettings() async {
    setState(() => _isLoading = true);

    try {
      final waterProvider = Provider.of<WaterProvider>(context, listen: false);
      await waterProvider.loadDailyStats();

      if (mounted) {
        setState(() {
          final stats = waterProvider.dailyProgress;
          if (stats != null) {
            _glassVolumeController.text = stats.glassVolumeMl.toString();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Используются настройки по умолчанию'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _glassVolumeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (widget.initialSetup) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Пожалуйста, завершите настройку перед выходом'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar:
            _showBackButton
                ? AppBar(
                  title: const Text('Настройки трекера воды'),
                  centerTitle: true,
                  elevation: 0,
                )
                : null,
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildSettingsForm(context, theme),
      ),
    );
  }

  Widget _buildSettingsForm(BuildContext context, ThemeData theme) {
    final waterProvider = Provider.of<WaterProvider>(context);
    final isInitialSetup =
        widget.initialSetup || waterProvider.dailyProgress == null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isInitialSetup) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[800]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Для начала работы с трекером воды укажите ваши данные для расчета дневной нормы',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            Text(
              'Расчет дневной нормы',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildInputField(
              controller: _weightController,
              label: 'Ваш вес',
              hintText: 'Введите ваш вес',
              suffixText: 'кг',
              validator: (value) {
                if (value == null || value.isEmpty) return 'Введите ваш вес';
                final weight = int.tryParse(value);
                if (weight == null || weight < 30 || weight > 250) {
                  return 'Вес должен быть от 30 до 250 кг';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildInputField(
              controller: _heightController,
              label: 'Ваш рост',
              hintText: 'Введите ваш рост',
              suffixText: 'см',
              validator: (value) {
                if (value == null || value.isEmpty) return 'Введите ваш рост';
                final height = int.tryParse(value);
                if (height == null || height < 100 || height > 250) {
                  return 'Рост должен быть от 100 до 250 см';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildInputField(
              controller: _glassVolumeController,
              label: 'Объем стакана',
              hintText: 'Объем вашего стакана',
              suffixText: 'мл',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Введите объем стакана';
                }
                final volume = int.tryParse(value);
                if (volume == null || volume < 100 || volume > 1000) {
                  return 'Объем должен быть от 100 до 1000 мл';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () => _saveSettings(context, isInitialSetup),
                child: Text(
                  isInitialSetup ? 'СОХРАНИТЬ И НАЧАТЬ' : 'СОХРАНИТЬ НАСТРОЙКИ',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            if (!isInitialSetup) ...[
              const SizedBox(height: 32),
              const Divider(height: 1),
              const SizedBox(height: 24),

              Text(
                'Мои контейнеры',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Добавьте часто используемые емкости для быстрого выбора',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),

              _buildContainersList(context),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Добавить контейнер'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: theme.primaryColor),
                  ),
                  onPressed: () => _showAddContainerDialog(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String suffixText,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            suffixText: suffixText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          keyboardType: TextInputType.number,
          validator: validator,
        ),
      ],
    );
  }

  void _saveSettings(BuildContext context, bool isInitialSetup) async {
    if (!_formKey.currentState!.validate()) return;

    final settings = WaterGoalSettings(
      weight: int.parse(_weightController.text),
      height: int.parse(_heightController.text),
      glassVolumeMl: int.parse(_glassVolumeController.text),
    );

    setState(() => _isLoading = true);

    try {
      final waterProvider = Provider.of<WaterProvider>(context, listen: false);
      await waterProvider.setDailyGoal(settings);

      if (!mounted) return; // Проверка перед использованием context
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Настройки сохранены'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        if (isInitialSetup) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildContainersList(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, waterProvider, child) {
        if (waterProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (waterProvider.containers.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.water_drop_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'Нет сохраненных контейнеров',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: waterProvider.containers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final container = waterProvider.containers[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.05 * 255).round()),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getContainerIcon(container.icon),
                    color: Colors.blue[800],
                  ),
                ),
                title: Text(
                  container.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${container.volumeMl} мл'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (container.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'По умолчанию',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.blue[800]),
                        ),
                      ),
                    IconButton(
                      icon: Icon(Icons.edit_rounded, color: Colors.grey[600]),
                      onPressed:
                          () => _showEditContainerDialog(context, container),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_rounded, color: Colors.red[400]),
                      onPressed:
                          () => _showDeleteContainerDialog(
                            context,
                            container.id!,
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getContainerIcon(String iconName) {
    switch (iconName) {
      case 'bottle':
        return Icons.local_drink_rounded;
      case 'mug':
        return Icons.coffee_rounded;
      default:
        return Icons.water_drop_rounded;
    }
  }

  void _showAddContainerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final volumeController = TextEditingController();
    String selectedIcon = 'glass';
    bool isDefault = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Добавить контейнер'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Название',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: volumeController,
                      decoration: InputDecoration(
                        labelText: 'Объем',
                        suffixText: 'мл',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedIcon,
                      decoration: InputDecoration(
                        labelText: 'Тип контейнера',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'glass', child: Text('Стакан')),
                        DropdownMenuItem(
                          value: 'bottle',
                          child: Text('Бутылка'),
                        ),
                        DropdownMenuItem(value: 'mug', child: Text('Кружка')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedIcon = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Использовать по умолчанию'),
                      value: isDefault,
                      onChanged: (value) {
                        setDialogState(() => isDefault = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        volumeController.text.isNotEmpty) {
                      final volume = int.tryParse(volumeController.text);
                      if (volume != null && volume > 0) {
                        final container = WaterContainer(
                          name: nameController.text,
                          volumeMl: volume,
                          icon: selectedIcon,
                          isDefault: isDefault,
                        );

                        Provider.of<WaterProvider>(
                          context,
                          listen: false,
                        ).saveContainer(container);

                        Navigator.of(dialogContext).pop();
                      }
                    }
                  },
                  child: const Text(
                    'Добавить',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditContainerDialog(
    BuildContext context,
    WaterContainer container,
  ) {
    final nameController = TextEditingController(text: container.name);
    final volumeController = TextEditingController(
      text: container.volumeMl.toString(),
    );
    String selectedIcon = container.icon;
    bool isDefault = container.isDefault;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Редактировать контейнер'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Название',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: volumeController,
                      decoration: InputDecoration(
                        labelText: 'Объем',
                        suffixText: 'мл',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedIcon,
                      decoration: InputDecoration(
                        labelText: 'Тип контейнера',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'glass', child: Text('Стакан')),
                        DropdownMenuItem(
                          value: 'bottle',
                          child: Text('Бутылка'),
                        ),
                        DropdownMenuItem(value: 'mug', child: Text('Кружка')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedIcon = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Использовать по умолчанию'),
                      value: isDefault,
                      onChanged: (value) {
                        setDialogState(() => isDefault = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        volumeController.text.isNotEmpty) {
                      final volume = int.tryParse(volumeController.text);
                      if (volume != null && volume > 0) {
                        final updatedContainer = WaterContainer(
                          id: container.id,
                          name: nameController.text,
                          volumeMl: volume,
                          icon: selectedIcon,
                          isDefault: isDefault,
                        );

                        Provider.of<WaterProvider>(
                          context,
                          listen: false,
                        ).saveContainer(updatedContainer);

                        Navigator.of(dialogContext).pop();
                      }
                    }
                  },
                  child: const Text(
                    'Сохранить',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteContainerDialog(BuildContext context, int containerId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Удалить контейнер?'),
          content: const Text(
            'Вы уверены, что хотите удалить этот контейнер? Это действие нельзя отменить.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<WaterProvider>(
                  context,
                  listen: false,
                ).deleteContainer(containerId);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Удалить', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
