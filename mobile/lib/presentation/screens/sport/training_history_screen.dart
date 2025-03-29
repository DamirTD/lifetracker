import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/presentation/providers/sport_provider.dart';
import 'package:mobile/presentation/widgets/app_error.dart';
import 'package:mobile/presentation/widgets/app_loading.dart';
import 'package:mobile/presentation/screens/sport/training_program_detail_screen.dart';
import 'package:intl/intl.dart';

class TrainingHistoryScreen extends StatefulWidget {
  const TrainingHistoryScreen({super.key});

  @override
  TrainingHistoryScreenState createState() => TrainingHistoryScreenState();
}

class TrainingHistoryScreenState extends State<TrainingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SportProvider>(context, listen: false).loadTrainingHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История тренировок'),
      ),
      body: Consumer<SportProvider>(
        builder: (context, provider, child) {
          final state = provider.state;

          if (state.isLoading) {
            return const AppLoading();
          }

          if (state.error != null) {
            return AppError(
              message: state.error!,
              onRetry: () => provider.loadTrainingHistory(),
            );
          }

          final history = state.trainingHistory;
          if (history == null || history.isEmpty) {
            return const Center(
              child: Text('У вас пока нет завершенных тренировок'),
            );
          }

          // Сортировка по дате (новые вверху)
          final sortedHistory = List.from(history)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.builder(
            itemCount: sortedHistory.length,
            itemBuilder: (context, index) {
              final item = sortedHistory[index];
              final program = item.trainingProgram;
              final date = DateFormat('dd.MM.yyyy').format(item.createdAt);
              final time = DateFormat('HH:mm').format(item.createdAt);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.fitness_center),
                  ),
                  title: Text(program?.name ?? 'Тренировка'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Вид спорта: ${program?.sport?.name ?? 'Не указан'}'),
                      Text('Длительность: ${item.duration} мин, Калории: ${item.caloriesBurned}'),
                      Text('$date в $time'),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    if (program != null) {
                      _viewTrainingDetail(context, program.id!);
                    }
                  },
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _viewTrainingDetail(BuildContext context, int programId) async {
    final provider = Provider.of<SportProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    await provider.loadTrainingProgramById(programId);

    if (mounted && provider.currentProgram != null) {
      navigator.push(
        MaterialPageRoute(
          builder: (context) => TrainingProgramDetailScreen(
            program: provider.currentProgram!,
          ),
        ),
      );
    }
  }
}