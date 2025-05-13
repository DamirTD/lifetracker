import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/presentation/providers/sport_provider.dart';
import 'package:mobile/presentation/screens/sport/create_training_program_screen.dart';
import 'package:mobile/presentation/screens/sport/training_program_detail_screen.dart';
import 'package:mobile/presentation/widgets/app_error.dart';
import 'package:mobile/presentation/widgets/app_loading.dart';

class TrainingProgramListScreen extends StatefulWidget {
  final int sportId;
  final String sportName;

  const TrainingProgramListScreen({
    super.key,
    required this.sportId,
    required this.sportName,
  });

  @override
  TrainingProgramListScreenState createState() =>
      TrainingProgramListScreenState();
}

class TrainingProgramListScreenState extends State<TrainingProgramListScreen> {
  final TextEditingController _goalController = TextEditingController();

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SportProvider>(context, listen: false).loadUserPrograms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Программы: ${widget.sportName}')),
      body: Consumer<SportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const AppLoading();
          }

          if (provider.error != null) {
            return AppError(message: provider.error!, onRetry: () {});
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Базовая программа тренировок
                _buildBasicProgramCard(),
                const SizedBox(height: 20),
                _buildProgramsHeader(context),
                const SizedBox(height: 16),
                Expanded(child: _buildTrainingProgramsList(context, provider)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBasicProgramCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Получить базовую программу',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _goalController,
              decoration: const InputDecoration(
                labelText: 'Ваша цель',
                hintText: 'Например: похудение, набор массы и т.д.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _getBasicProgram(),
                child: const Text('Получить рекомендацию'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Ваши программы тренировок',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton.icon(
          onPressed: () => _createPersonalTrainingProgram(initialGoal: null),
          icon: const Icon(Icons.add),
          label: const Text('Создать'),
        ),
      ],
    );
  }

  Widget _buildTrainingProgramsList(
    BuildContext context,
    SportProvider provider,
  ) {
    final userPrograms = provider.state.userPrograms;

    if (userPrograms == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final programs =
        userPrograms.where((p) => p.sportId == widget.sportId).toList();

    if (programs.isEmpty) {
      return _buildEmptyStateView(
        'У вас пока нет программ тренировок для этого вида спорта',
      );
    }

    return ListView.builder(
      itemCount: programs.length,
      itemBuilder: (context, index) {
        final program = programs[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(program.name),
            subtitle: Text('Цель: ${program.goal}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _viewTrainingProgram(program.id!),
          ),
        );
      },
    );
  }

  Widget _buildEmptyStateView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fitness_center_outlined,
            size: 56,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _createPersonalTrainingProgram(initialGoal: null),
            icon: const Icon(Icons.add),
            label: const Text('Создать программу'),
          ),
        ],
      ),
    );
  }

  Future<void> _getBasicProgram() async {
    if (_goalController.text.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Пожалуйста, укажите цель')));
      return;
    }

    final provider = Provider.of<SportProvider>(context, listen: false);
    final initialGoal = _goalController.text;

    final recommendation = await provider.getBasicTrainingProgram(
      widget.sportId,
      initialGoal,
    );

    if (!mounted || recommendation == null) return;

    _showRecommendationDialog(recommendation, initialGoal);
  }

  void _showRecommendationDialog(
    Map<String, String> recommendation,
    String initialGoal,
  ) {
    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: Text(recommendation['message'] ?? 'Рекомендация'),
            content: Text(recommendation['advice'] ?? 'Нет рекомендаций'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Закрыть'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  if (mounted) {
                    _createPersonalTrainingProgram(initialGoal: initialGoal);
                  }
                },
                child: const Text('Создать программу'),
              ),
            ],
          ),
    );
  }

  void _createPersonalTrainingProgram({String? initialGoal}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CreateTrainingProgramScreen(
              sportId: widget.sportId,
              sportName: widget.sportName,
              initialGoal: initialGoal,
            ),
      ),
    );

    // После возврата — обновить список программ
    if (result == true && mounted) {
      Provider.of<SportProvider>(context, listen: false).loadUserPrograms();
    }
  }

  Future<void> _viewTrainingProgram(int programId) async {
    final provider = Provider.of<SportProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    await provider.loadTrainingProgramById(programId);

    if (mounted && provider.currentProgram != null) {
      navigator.push(
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
