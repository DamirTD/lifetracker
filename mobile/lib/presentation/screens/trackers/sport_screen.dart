import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/presentation/providers/sport_provider.dart';
import 'package:mobile/data/models/sport/sport.dart';
import 'package:mobile/data/models/sport/training_history.dart';
import 'package:mobile/presentation/widgets/app_loading.dart';
import 'package:mobile/presentation/widgets/app_error.dart';
import 'package:mobile/presentation/screens/sport/user_sports_screen.dart';
import 'package:mobile/presentation/screens/sport/sport_list_screen.dart';
import 'package:mobile/presentation/screens/sport/training_history_screen.dart';
import 'package:mobile/presentation/screens/sport/training_program_list_screen.dart';
import 'package:mobile/presentation/screens/sport/training_program_detail_screen.dart';

class SportScreen extends StatefulWidget {
  const SportScreen({super.key});

  @override
  SportScreenState createState() => SportScreenState();
}

class SportScreenState extends State<SportScreen> {
  final Color primaryColor = const Color(0xFF4A90E2);
  final Color backgroundCard = const Color(0xFFF9FAFB);
  final Color accentColor = const Color(0xFF1D3557);
  final Color textColor = const Color(0xFF333333);
  final Color fadedTextColor = Colors.grey.shade600;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SportProvider>(context, listen: false);
      provider.loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Мой спорт',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: primaryColor,
      ),
      body: Consumer<SportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const AppLoading();
          if (provider.error != null) {
            return AppError(
              message: provider.error!,
              onRetry: () => provider.loadInitialData(),
            );
          }
          return _buildMainContent(context, provider);
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, SportProvider provider) {
    final userSports = provider.userSports;
    final trainingHistory = provider.trainingHistory;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Мои виды спорта',
            onSeeAll: () => _navigateToUserSports(context),
            child:
                userSports == null || userSports.isEmpty
                    ? _buildEmptyStateCard(
                      message: 'У вас пока нет выбранных видов спорта',
                      actionText: 'Выбрать спорт',
                      onAction: () => _navigateToSportList(context),
                    )
                    : _buildSportsGrid(context, userSports),
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Недавние тренировки',
            onSeeAll: () => _navigateToTrainingHistory(context),
            child:
                trainingHistory == null || trainingHistory.isEmpty
                    ? _buildEmptyStateCard(
                      message: 'У вас пока нет завершенных тренировок',
                      actionText:
                          trainingHistory == null ? null : 'Начать тренировку',
                      onAction:
                          userSports != null && userSports.isNotEmpty
                              ? () => _navigateToUserSports(context)
                              : null,
                    )
                    : _buildRecentTrainings(
                      context,
                      trainingHistory.take(3).toList(),
                    ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Статистика',
            onSeeAll: null,
            child: _buildStatistics(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    VoidCallback? onSeeAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                child: const Text('Смотреть все'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildEmptyStateCard({
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: backgroundCard,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.fitness_center, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: textColor),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onAction,
                child: Text(actionText),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSportsGrid(BuildContext context, List<Sport> sports) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: sports.length > 4 ? 4 : sports.length,
      itemBuilder: (context, index) {
        final sport = sports[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          color: backgroundCard,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _navigateToSportDetails(context, sport),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.sports_martial_arts,
                    size: 32,
                    color: Color(0xFF1D3557),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sport.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentTrainings(
    BuildContext context,
    List<TrainingHistory> trainings,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trainings.length,
      itemBuilder: (context, index) {
        final training = trainings[index];
        final program = training.trainingProgram;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
          color: backgroundCard,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: primaryColor.withOpacity(0.1),
              child: Icon(Icons.access_time, color: primaryColor),
            ),
            title: Text(
              program?.name ?? 'Тренировка',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Длительность: ${training.duration} мин',
              style: TextStyle(color: fadedTextColor),
            ),
            trailing: Text(
              '${training.createdAt.day}.${training.createdAt.month}.${training.createdAt.year}',
              style: TextStyle(color: fadedTextColor),
            ),
            onTap: () {
              if (program != null) {
                _navigateToProgramDetails(context, program.id!);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildStatistics(BuildContext context, SportProvider provider) {
    final history = provider.trainingHistory;

    if (history == null || history.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        color: backgroundCard,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Завершите тренировку, чтобы увидеть статистику',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    int totalWorkouts = history.length;
    int totalMinutes = history.fold(0, (sum, item) => sum + item.duration);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      color: backgroundCard,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Тренировок', totalWorkouts.toString()),
            _buildStatItem('Минут', totalMinutes.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: fadedTextColor)),
      ],
    );
  }

  void _navigateToUserSports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserSportsScreen()),
    );
  }

  void _navigateToSportList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SportListScreen()),
    );
  }

  void _navigateToTrainingHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TrainingHistoryScreen()),
    );
  }

  void _navigateToSportDetails(BuildContext context, Sport sport) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => TrainingProgramListScreen(
              sportId: sport.id,
              sportName: sport.name,
            ),
      ),
    );
  }

  void _navigateToProgramDetails(BuildContext context, int programId) async {
    final provider = Provider.of<SportProvider>(context, listen: false);
    await provider.loadTrainingProgramById(programId);

    if (!context.mounted) return;

    if (provider.currentProgram != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => TrainingProgramDetailScreen(
                program: provider.currentProgram!,
              ),
        ),
      );
    }
  }
}
