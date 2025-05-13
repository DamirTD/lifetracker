import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/data/repositories/user_repository.dart';
import 'package:mobile/presentation/screens/home/profile_screen.dart';
import 'package:mobile/presentation/screens/trackers/diet_screen.dart';
import 'package:mobile/presentation/screens/trackers/finance_screen.dart';
import 'package:mobile/presentation/screens/trackers/sleep_screen.dart';
import 'package:mobile/presentation/screens/trackers/sport_screen.dart';
import 'package:mobile/presentation/screens/trackers/tasks_screen.dart';
import 'package:mobile/presentation/screens/trackers/water_screen.dart';

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
  int notificationCount = 2;
  double _scrollOffset = 0;

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
    final width = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colors.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: colors.primary,
                  backgroundColor: colors.primary.withOpacity(0.2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Загружаем ваши данные...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: colors.surface,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 56, color: colors.error),
                const SizedBox(height: 24),
                Text(
                  'Ошибка загрузки',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.errorContainer,
                    foregroundColor: colors.onErrorContainer,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
        backgroundColor: colors.surface,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 56, color: colors.error),
                const SizedBox(height: 24),
                Text(
                  'Пользователь не найден',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
      floatingActionButton: _buildSpeedDial(context),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          setState(() {
            _scrollOffset = notification.metrics.pixels;
          });
          return false;
        },
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: colors.surface,
              surfaceTintColor: colors.surfaceTint,
              expandedHeight: 180,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors.primary.withOpacity(0.08),
                        colors.surface,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildWelcomeHeader(context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                minHeight: 60,
                maxHeight: 60,
                child: Container(
                  color: colors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Мои трекеры",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: width > 600 ? 3 : 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildTrackerCard(context, _categories[index]),
                  childCount: _categories.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final userName = _user?.name ?? 'Пользователь';
    final greetingOpacity = 1 - (_scrollOffset / 100).clamp(0.0, 1.0);

    return AnimatedOpacity(
      opacity: greetingOpacity,
      duration: const Duration(milliseconds: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Привет, ${userName.split(' ').first}",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Как твои дела сегодня?",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          _buildProfileAvatar(context),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const avatarUrl = '';

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
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primaryContainer,
            border: Border.all(
              color: colors.primary.withOpacity(0.2),
              width: 2,
            ),
          ),
          child:
              avatarUrl.isEmpty
                  ? Icon(Icons.person, size: 28, color: colors.primary)
                  : ClipOval(
                    child: Image.network(avatarUrl, fit: BoxFit.cover),
                  ),
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

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => category['screen']),
            ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: colors.surface,
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        category['color'].withOpacity(0.8),
                        category['color'].withOpacity(0.4),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category['icon'],
                    color: colors.onPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  category['label'],
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  _getTrackerSubtitle(category['label']),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTrackerSubtitle(String label) {
    switch (label) {
      case "Задачи":
        return "Управляй задачами";
      case "Финансы":
        return "Контроль бюджета";
      case "Сон":
        return "Анализ качества сна";
      case "Вода":
        return "Баланс жидкости";
      case "Спорт":
        return "Тренировки и спорт";
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
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      spaceBetweenChildren: 12,
      childrenButtonSize: const Size(
        56,
        56,
      ), // Исправлено: передаем Size вместо int
      childMargin: const EdgeInsets.symmetric(horizontal: 8),
      childPadding: const EdgeInsets.all(8),
      children: [
        SpeedDialChild(
          child: Icon(Icons.local_drink, color: colors.onPrimary),
          backgroundColor: Colors.blue,
          label: 'Добавить воду',
          labelStyle: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.w500,
          ),
          labelBackgroundColor: colors.surface,
          onTap: () => _navigateToTracker(context, 'Вода'),
        ),
        SpeedDialChild(
          child: Icon(Icons.task_alt, color: colors.onPrimary),
          backgroundColor: Colors.green,
          label: 'Новая задача',
          labelStyle: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.w500,
          ),
          labelBackgroundColor: colors.surface,
          onTap: () => _navigateToTracker(context, 'Задачи'),
        ),
        SpeedDialChild(
          child: Icon(Icons.attach_money, color: colors.onPrimary),
          backgroundColor: Colors.teal,
          label: 'Добавить расход',
          labelStyle: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.w500,
          ),
          labelBackgroundColor: colors.surface,
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

final List<Map<String, dynamic>> _categories = [
  {
    'icon': Icons.task_alt,
    'label': "Задачи",
    'color': Colors.purple,
    'screen': TasksScreen(),
  },
  {
    'icon': Icons.attach_money,
    'label': "Финансы",
    'color': Colors.green,
    'screen': FinanceScreen(),
  },
  {
    'icon': Icons.bedtime_rounded,
    'label': "Сон",
    'color': Colors.indigo,
    'screen': SleepScreen(),
  },
  {
    'icon': Icons.opacity,
    'label': "Вода",
    'color': Colors.blue,
    'screen': WaterScreen(),
  },
  {
    'icon': Icons.directions_run,
    'label': "Спорт",
    'color': Colors.orange,
    'screen': SportScreen(),
  },
  {
    'icon': Icons.local_dining,
    'label': "Диета",
    'color': Colors.red,
    'screen': DietScreen(),
  },
];
