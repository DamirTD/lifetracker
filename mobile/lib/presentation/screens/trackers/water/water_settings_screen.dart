import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/water/water_container.dart';
import '../../../../data/models/water/water_goal_settings.dart';
import '../../../providers/water_providers.dart';


class WaterSettingsScreen extends StatefulWidget {
  const WaterSettingsScreen({super.key});

  @override
  WaterSettingsScreenState createState() => WaterSettingsScreenState();
}

class WaterSettingsScreenState extends State<WaterSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController(text: '70'); // Default weight
  final _heightController = TextEditingController(text: '170'); // Default height
  final _glassVolumeController = TextEditingController(text: '250'); // Default glass volume

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();

    // Загружаем контейнеры при инициализации экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WaterProvider>(context, listen: false).loadContainers();
    });
  }

  Future<void> _loadCurrentSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final waterProvider = Provider.of<WaterProvider>(context, listen: false);
      await waterProvider.loadDailyStats();

      if (mounted) {
        setState(() {
          final stats = waterProvider.dailyProgress;
          if (stats != null) {
            _glassVolumeController.text = stats.glassVolumeMl.toString();
            // We don't have access to the original weight and height once set,
            // so we keep the defaults
          }
        });
      }
    } catch (e) {
      if (mounted) {
        // Just use defaults if there's an error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Используются настройки по умолчанию')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки трекера воды'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSettingsForm(context),
    );
  }

  Widget _buildSettingsForm(BuildContext context) {
    final waterProvider = Provider.of<WaterProvider>(context);
    final bool isInitialSetup = waterProvider.dailyProgress == null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isInitialSetup) ...[
              const Card(
                color: Colors.blue,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Для начала работы с трекером воды, пожалуйста, укажите ваши данные для расчета дневной нормы',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Расчет дневной нормы',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Вес (кг)',
                border: OutlineInputBorder(),
                suffixText: 'кг',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите ваш вес';
                }
                final weight = int.tryParse(value);
                if (weight == null || weight < 30 || weight > 250) {
                  return 'Вес должен быть от 30 до 250 кг';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(
                labelText: 'Рост (см)',
                border: OutlineInputBorder(),
                suffixText: 'см',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите ваш рост';
                }
                final height = int.tryParse(value);
                if (height == null || height < 100 || height > 250) {
                  return 'Рост должен быть от 100 до 250 см';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _glassVolumeController,
              decoration: const InputDecoration(
                labelText: 'Объём вашего стакана (мл)',
                border: OutlineInputBorder(),
                suffixText: 'мл',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите объём стакана';
                }
                final volume = int.tryParse(value);
                if (volume == null || volume < 100 || volume > 1000) {
                  return 'Объём должен быть от 100 до 1000 мл';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveSettings(context, isInitialSetup);
                  }
                },
                child: Text(
                  isInitialSetup ? 'Сохранить и начать' : 'Сохранить настройки',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Only show the Containers section if not initial setup
            if (!isInitialSetup) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Управление контейнерами',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildContainersList(context),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить контейнер'),
                  onPressed: () {
                    _showAddContainerDialog(context);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // existing methods for containers management

  void _saveSettings(BuildContext context, bool isInitialSetup) async {
    final weight = int.parse(_weightController.text);
    final height = int.parse(_heightController.text);
    final glassVolumeMl = int.parse(_glassVolumeController.text);

    final settings = WaterGoalSettings(
      weight: weight,
      height: height,
      glassVolumeMl: glassVolumeMl,
    );

    // Store the context before the async gap
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() {
      _isLoading = true;
    });

    try {
      final waterProvider = Provider.of<WaterProvider>(context, listen: false);
      await waterProvider.setDailyGoal(settings);

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Настройки сохранены')),
        );

        // If this was initial setup, navigate back
        if (isInitialSetup && mounted) {
          // Instead of relying on a non-existent type, we'll simply navigate back
          navigator.pop();

          // Note: If you need to navigate to a specific screen or tab, you should
          // implement a proper navigation solution or use a callback
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Existing methods for container management
  Widget _buildContainersList(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, waterProvider, child) {
        if (waterProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (waterProvider.containers.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('У вас еще нет сохраненных контейнеров'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: waterProvider.containers.length,
          itemBuilder: (context, index) {
            final container = waterProvider.containers[index];
            return ListTile(
              leading: const Icon(
                Icons.water_drop,
                color: Colors.blue,
              ),
              title: Text(container.name),
              subtitle: Text('${container.volumeMl} мл'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (container.isDefault)
                    Chip(
                      label: const Text('По умолчанию'),
                      backgroundColor: Colors.blue.withAlpha(100),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _showDeleteContainerDialog(context, container.id!);
                    },
                  ),
                ],
              ),
              onTap: () {
                _showEditContainerDialog(context, container);
              },
            );
          },
        );
      },
    );
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
                      decoration: const InputDecoration(
                        labelText: 'Название',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: volumeController,
                      decoration: const InputDecoration(
                        labelText: 'Объем (мл)',
                        border: OutlineInputBorder(),
                        suffixText: 'мл',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedIcon,
                      decoration: const InputDecoration(
                        labelText: 'Иконка',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'glass', child: Text('Стакан')),
                        DropdownMenuItem(value: 'bottle', child: Text('Бутылка')),
                        DropdownMenuItem(value: 'mug', child: Text('Кружка')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedIcon = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Использовать по умолчанию'),
                      value: isDefault,
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            isDefault = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && volumeController.text.isNotEmpty) {
                      final volume = int.tryParse(volumeController.text);
                      if (volume != null && volume > 0) {
                        final container = WaterContainer(
                          name: nameController.text,
                          volumeMl: volume,
                          icon: selectedIcon,
                          isDefault: isDefault,
                        );

                        Provider.of<WaterProvider>(context, listen: false)
                            .saveContainer(container);

                        Navigator.of(dialogContext).pop();
                      }
                    }
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

  void _showEditContainerDialog(BuildContext context, WaterContainer container) {
    final nameController = TextEditingController(text: container.name);
    final volumeController = TextEditingController(text: container.volumeMl.toString());
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
                      decoration: const InputDecoration(
                        labelText: 'Название',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: volumeController,
                      decoration: const InputDecoration(
                        labelText: 'Объем (мл)',
                        border: OutlineInputBorder(),
                        suffixText: 'мл',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedIcon,
                      decoration: const InputDecoration(
                        labelText: 'Иконка',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'glass', child: Text('Стакан')),
                        DropdownMenuItem(value: 'bottle', child: Text('Бутылка')),
                        DropdownMenuItem(value: 'mug', child: Text('Кружка')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedIcon = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Использовать по умолчанию'),
                      value: isDefault,
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            isDefault = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && volumeController.text.isNotEmpty) {
                      final volume = int.tryParse(volumeController.text);
                      if (volume != null && volume > 0) {
                        final updatedContainer = WaterContainer(
                          id: container.id,
                          name: nameController.text,
                          volumeMl: volume,
                          icon: selectedIcon,
                          isDefault: isDefault,
                        );

                        Provider.of<WaterProvider>(context, listen: false)
                            .saveContainer(updatedContainer);

                        Navigator.of(dialogContext).pop();
                      }
                    }
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

  void _showDeleteContainerDialog(BuildContext context, int containerId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Удалить контейнер?'),
          content: const Text('Вы уверены, что хотите удалить этот контейнер?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<WaterProvider>(context, listen: false)
                    .deleteContainer(containerId);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }
}