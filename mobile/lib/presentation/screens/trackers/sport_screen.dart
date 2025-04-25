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
      appBar: AppBar(title: const Text('Спорт')),
      body: Consumer<SportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const AppLoading();
          }

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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onAction, child: Text(actionText)),
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
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _navigateToSportDetails(context, sport),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fitness_center, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    sport.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.fitness_center)),
            title: Text(program?.name ?? 'Тренировка'),
            subtitle: Text(
              'Длительность: ${training.duration} мин, Калории: ${training.caloriesBurned}',
            ),
            trailing: Text(
              '${training.createdAt.day}.${training.createdAt.month}.${training.createdAt.year}',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Завершите тренировку, чтобы увидеть статистику',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    int totalWorkouts = history.length;
    int totalMinutes = history.fold(0, (sum, item) => sum + item.duration);
    int totalCalories = history.fold(
      0,
      (sum, item) => sum + item.caloriesBurned,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Тренировок', totalWorkouts.toString()),
                _buildStatItem('Минут', totalMinutes.toString()),
                _buildStatItem('Калорий', totalCalories.toString()),
              ],
            ),
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
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  void _navigateToUserSports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserSportsScreen()),
    );
  }

  void _navigateToSportList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SportListScreen()),
    );
  }

  void _navigateToTrainingHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrainingHistoryScreen()),
    );
  }

  void _navigateToSportDetails(BuildContext context, Sport sport) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TrainingProgramListScreen(
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
              (context) => TrainingProgramDetailScreen(
                program: provider.currentProgram!,
              ),
        ),
      );
    }
  }
}
