import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/presentation/screens/auth/auth_screen.dart';
import 'package:mobile/presentation/screens/home/home_screen.dart';
import 'package:mobile/presentation/screens/auth/logout_screen.dart';
import 'package:mobile/presentation/screens/home/profile_screen.dart';
import 'package:mobile/presentation/screens/auth/welcome_screen.dart';
import 'package:mobile/presentation/screens/trackers/tasks_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('ru_RU');
  
  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token') ?? '';
  final initialRoute = token.isNotEmpty ? '/home' : '/welcome';

  runApp(MainApp(initialRoute: initialRoute));
}

class MainApp extends StatelessWidget {
  final String initialRoute;

  const MainApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/logout': (context) => const LogoutScreen(),
        '/tasks': (context) => const TasksScreen(),
      },
    );
  }
}