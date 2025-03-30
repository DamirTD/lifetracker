import 'package:flutter/material.dart';
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
  final sportRepository = SportRepository(apiClient); // Добавлен репозиторий спорта

  runApp(
    MultiProvider(
      providers: [
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
        ChangeNotifierProvider<SportProvider>( // Добавлен провайдер спорта
          create: (_) => SportProvider(sportRepository),
        ),
      ],
      child: MainApp(initialRoute: initialRoute),
    ),
  );
}

class MainApp extends StatelessWidget {
  final String initialRoute;

  const MainApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
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