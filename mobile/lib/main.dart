import 'package:flutter/material.dart';
import 'package:mobile/presentation/providers/theme_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/data/repositories/water/water_repository.dart';
import 'package:mobile/presentation/providers/water_providers.dart';
import 'package:mobile/presentation/screens/trackers/water_screen.dart';
import 'package:mobile/data/repositories/sport/sport_repository.dart';
import 'package:mobile/presentation/providers/sport_provider.dart';
import 'package:mobile/presentation/screens/sport/training_history_screen.dart';
import 'package:mobile/presentation/screens/sport/user_sports_screen.dart';
import 'package:mobile/presentation/screens/trackers/sleep_screen.dart';
import 'package:mobile/presentation/screens/trackers/sport_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/data/repositories/tasks/category/category_repository.dart';
import 'package:mobile/data/repositories/tasks/task_repository.dart';
import 'package:mobile/presentation/providers/finance_provider.dart';
import 'package:mobile/presentation/providers/sleep_provider.dart';
import 'package:mobile/presentation/providers/tasks.dart';
import 'package:mobile/presentation/screens/auth/auth_screen.dart';
import 'package:mobile/presentation/screens/home/home_screen.dart';
import 'package:mobile/presentation/screens/auth/logout_screen.dart';
import 'package:mobile/presentation/screens/home/profile_screen.dart';
import 'package:mobile/presentation/screens/auth/welcome_screen.dart';
import 'package:mobile/presentation/screens/trackers/tasks_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/api/api_client.dart';
import 'data/repositories/finance/finance_repository.dart';
import 'data/repositories/sleep/sleep_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ru_RU');
  await dotenv.load(fileName: ".env");

  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'auth_token') ?? '';
  final initialRoute = token.isNotEmpty ? '/home' : '/welcome';

  final apiClient = ApiClient(baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:80/api');
  final financeRepository = FinanceRepository(apiClient);
  final taskRepository = TaskRepository();
  final waterRepository = WaterRepository();
  final categoryRepository = TaskCategoryRepository();
  final sleepRepository = SleepRepository(apiClient);
  final sportRepository = SportRepository(apiClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<FinanceProvider>(
          create: (_) => FinanceProvider(financeRepository),
        ),
        ChangeNotifierProvider<TasksProvider>(
          create: (_) => TasksProvider(taskRepository, categoryRepository),
        ),
        ChangeNotifierProvider<SleepProvider>(
          create: (_) => SleepProvider(sleepRepository),
        ),
        ChangeNotifierProvider<WaterProvider>(
          create: (_) => WaterProvider(waterRepository),
        ),
        ChangeNotifierProvider<SportProvider>(
          create: (_) => SportProvider(sportRepository),
        ),
      ],
      child: AppTheme(initialRoute: initialRoute),
    ),
  );
}

class AppTheme extends StatelessWidget {
  final String initialRoute;

  const AppTheme({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MainApp(
      initialRoute: initialRoute,
      theme: themeProvider.themeData,
    );
  }
}

class MainApp extends StatelessWidget {
  final String initialRoute;
  final ThemeData theme;

  const MainApp({
    super.key,
    required this.initialRoute,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      theme: theme,
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/logout': (context) => const LogoutScreen(),
        '/tasks': (context) => const TasksScreen(),
        '/sleep': (context) => const SleepScreen(),
        '/water': (context) => const WaterScreen(),
        '/sport': (context) => const SportScreen(),
        '/sport/my': (context) => const UserSportsScreen(),
        '/sport/history': (context) => const TrainingHistoryScreen(),
      },
    );
  }
}