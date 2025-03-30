import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/presentation/providers/sport_provider.dart';
import 'package:mobile/presentation/widgets/app_error.dart';
import 'package:mobile/presentation/widgets/app_loading.dart';
import 'package:mobile/presentation/screens/sport/sport_list_screen.dart';
import 'package:mobile/presentation/screens/sport/training_program_list_screen.dart';

class UserSportsScreen extends StatefulWidget {
  const UserSportsScreen({super.key});

  @override
  UserSportsScreenState createState() => UserSportsScreenState();
}

class UserSportsScreenState extends State<UserSportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SportProvider>(context, listen: false).loadUserSports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои виды спорта'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAllSports(context),
            tooltip: 'Добавить вид спорта',
          ),
        ],
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
              onRetry: () => provider.loadUserSports(),
            );
          }

          final sports = state.userSports;
          if (sports == null || sports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'У вас пока нет выбранных видов спорта',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _navigateToAllSports(context),
                    child: const Text('Выбрать виды спорта'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: sports.length,
            itemBuilder: (context, index) {
              final sport = sports[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.fitness_center),
                  ),
                  title: Text(sport.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _navigateToSportDetails(context, sport.id, sport.name),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAllSports(context),
        tooltip: 'Добавить вид спорта',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAllSports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SportListScreen(),
      ),
    );
  }

  void _navigateToSportDetails(BuildContext context, int sportId, String sportName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingProgramListScreen(sportId: sportId, sportName: sportName),
      ),
    );
  }
}