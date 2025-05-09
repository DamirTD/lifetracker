import 'package:flutter/material.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/presentation/screens/home/profile_screen.dart';
import 'package:mobile/presentation/screens/trackers/diet_screen.dart';
import 'package:mobile/presentation/screens/trackers/sleep_screen.dart';
import 'package:mobile/presentation/screens/trackers/finance_screen.dart';
import 'package:mobile/presentation/screens/trackers/sport_screen.dart';
import 'package:mobile/presentation/screens/trackers/tasks_screen.dart';
import 'package:mobile/presentation/screens/trackers/water_screen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mobile/data/repositories/user_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserRepository _userRepository = UserRepository();
  UserModel? _user;
  bool _isLoading = true;
  String? _error;
  bool _disposed = false;
  int notificationCount = 0; // Пример уведомлений

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!_disposed && mounted) {
      setState(fn);
    }
  }

  Future<void> _loadUser() async {
    _safeSetState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await _userRepository.getUser();
      if (!mounted) return;
      _safeSetState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      _safeSetState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
              const SizedBox(height: 16),
              Text(
                'Загружаем ваши данные...',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: colors.error),
                const SizedBox(height: 16),
                Text(
                  'Ошибка загрузки',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loadUser,
                  child: const Text('Попробовать снова'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 48, color: colors.error),
                const SizedBox(height: 16),
                Text(
                  'Пользователь не найден',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed:
                      () => Navigator.pushReplacementNamed(context, '/welcome'),
                  child: const Text('Вернуться на экран входа'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUser,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Аппбар с приветствием
              SliverAppBar(
                pinned: true,
                elevation: 0,
                backgroundColor: colors.surface,
                surfaceTintColor: colors.surfaceTint,
                expandedHeight: 140,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildWelcomeHeader(context),
                        const SizedBox(height: 16),
                        Divider(height: 1, color: colors.outlineVariant),
                      ],
                    ),
                  ),
                ),
              ),

              // Секция трекеров
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    "Мои трекеры",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Грид с трекерами
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildTrackerCard(context, _categories[index]),
                    childCount: _categories.length,
                  ),
                ),
              ),

              // Отступ для FAB
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildSpeedDial(context),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final userName = _user?.name ?? 'Пользователь';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Привет, ${userName.split(' ').first}",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Как твои дела сегодня?",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withAlpha((255 * 0.7).round()),
              ),
            ),
          ],
        ),
        _buildProfileAvatar(context),
      ],
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const avatarUrl = ''; // Здесь должна быть ссылка на аватар

    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          ),
      child: Badge(
        isLabelVisible: notificationCount > 0,
        label:
            notificationCount > 0 ? Text(notificationCount.toString()) : null,
        backgroundColor: colors.error,
        textColor: colors.onError,
        alignment: Alignment.topRight,
        child: CircleAvatar(
          radius: 24,
          backgroundColor: colors.primaryContainer,
          foregroundImage:
              avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          child:
              avatarUrl.isEmpty
                  ? Icon(Icons.person, color: colors.primary)
                  : null,
        ),
      ),
    );
  }

  Widget _buildTrackerCard(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => category['screen']),
            ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: category['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category['icon'],
                  color: category['color'],
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category['label'],
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                _getTrackerSubtitle(category['label']),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurface.withAlpha((255 * 0.6).round()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTrackerSubtitle(String label) {
    switch (label) {
      case "Задачи":
        return "Задачи на день";
      case "Финансы":
        return "Бюджет и расходы";
      case "Сон":
        return "Качество и длительность";
      case "Вода":
        return "Баланс жидкости";
      case "Спорт":
        return "Активность";
      case "Диета":
        return "Питание и калории";
      default:
        return "";
    }
  }

  Widget _buildSpeedDial(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      spaceBetweenChildren: 12,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.local_drink),
          backgroundColor: Colors.blue,
          label: 'Добавить воду',
          labelStyle: TextStyle(color: colors.onSurface),
          onTap: () => _navigateToTracker(context, 'Вода'),
        ),
        SpeedDialChild(
          child: const Icon(Icons.task_alt),
          backgroundColor: Colors.green,
          label: 'Новая задача',
          labelStyle: TextStyle(color: colors.onSurface),
          onTap: () => _navigateToTracker(context, 'Задачи'),
        ),
        SpeedDialChild(
          child: const Icon(Icons.attach_money),
          backgroundColor: Colors.teal,
          label: 'Добавить расход',
          labelStyle: TextStyle(color: colors.onSurface),
          onTap: () => _navigateToTracker(context, 'Финансы'),
        ),
      ],
    );
  }

  void _navigateToTracker(BuildContext context, String trackerName) {
    final tracker = _categories.firstWhere(
      (element) => element['label'] == trackerName,
      orElse: () => _categories[0],
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => tracker['screen']),
    );
  }
}

final List<Map<String, dynamic>> _categories = [
  {
    'icon': Icons.task_alt,
    'label': "Задачи",
    'color': Colors.purple,
    'screen': const TasksScreen(),
  },
  {
    'icon': Icons.attach_money,
    'label': "Финансы",
    'color': Colors.green,
    'screen': const FinanceScreen(),
  },
  {
    'icon': Icons.bedtime_rounded,
    'label': "Сон",
    'color': Colors.indigo,
    'screen': const SleepScreen(),
  },
  {
    'icon': Icons.opacity,
    'label': "Вода",
    'color': Colors.blue,
    'screen': const WaterScreen(),
  },
  {
    'icon': Icons.directions_run,
    'label': "Спорт",
    'color': Colors.orange,
    'screen': const SportScreen(),
  },
  {
    'icon': Icons.local_dining,
    'label': "Диета",
    'color': Colors.red,
    'screen': const DietScreen(),
  },
];
