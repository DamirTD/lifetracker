import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/data/models/sport/sport.dart';
import 'package:mobile/presentation/providers/sport_provider.dart';
import 'package:mobile/presentation/widgets/app_error.dart';
import 'package:mobile/presentation/widgets/app_loading.dart';
import 'package:mobile/presentation/screens/sport/training_program_list_screen.dart';

class SportListScreen extends StatefulWidget {
  const SportListScreen({super.key});

  @override
  SportListScreenState createState() => SportListScreenState();
}

class SportListScreenState extends State<SportListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SportProvider>(context, listen: false).loadSports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Виды спорта'),
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
              onRetry: () => provider.loadSports(),
            );
          }

          final sports = state.allSports;
          if (sports == null || sports.isEmpty) {
            return const Center(
              child: Text('Виды спорта не найдены'),
            );
          }

          return ListView.builder(
            itemCount: sports.length,
            itemBuilder: (context, index) {
              final sport = sports[index];
              final isSelected = provider.userSports?.any(
                      (s) => s.id == sport.id
              ) ?? false;

              return ListTile(
                title: Text(sport.name),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () => _handleSportSelection(context, sport),
              );
            },
          );
        },
      ),
    );
  }

  void _handleSportSelection(BuildContext context, Sport sport) async {
    final sportProvider = Provider.of<SportProvider>(context, listen: false);
    final _ = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final userSports = sportProvider.userSports;
    final isAlreadySelected = userSports?.any((s) => s.id == sport.id) ?? false;

    if (isAlreadySelected) {
      _showSportActionDialog(context, sport, true);
    } else {
      final success = await sportProvider.selectUserSport(sport.id);

      if (success && mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Спорт "${sport.name}" успешно выбран')),
        );
      }
    }
  }

  void _showSportActionDialog(BuildContext context, Sport sport, bool isSelected) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isSelected
            ? 'Управление видом спорта'
            : 'Выбрать вид спорта'),
        content: Text(isSelected
            ? 'Что вы хотите сделать с видом спорта "${sport.name}"?'
            : 'Хотите выбрать вид спорта "${sport.name}"?'),
        actions: [
          if (isSelected)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showTrainingProgramScreen(context, sport);
              },
              child: const Text('Тренировочные программы'),
            ),
          if (isSelected)
            TextButton(
              onPressed: () async {
                final sportProvider = Provider.of<SportProvider>(context, listen: false);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);

                final userSport = sportProvider.userSports?.firstWhere(
                      (s) => s.id == sport.id,
                );

                if (userSport != null) {
                  navigator.pop();
                  final success = await sportProvider.deleteUserSport(userSport.id);

                  if (success && mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Спорт "${sport.name}" успешно удален')),
                    );
                  }
                }
              },
              child: const Text('Отменить выбор'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Отмена'),
          ),
          if (!isSelected)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final sportProvider = Provider.of<SportProvider>(context, listen: false);
                final success = await sportProvider.selectUserSport(sport.id);

                if (success && mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Спорт "${sport.name}" успешно выбран')),
                  );
                }
              },
              child: const Text('Выбрать'),
            ),
        ],
      ),
    );
  }

  void _showTrainingProgramScreen(BuildContext context, Sport sport) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingProgramListScreen(sportId: sport.id, sportName: sport.name),
      ),
    );
  }
}