import 'package:flutter/material.dart';
import 'auth_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 50),
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(seconds: 1),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: child,
                    );
                  },
                  child: const Text(
                    "LifeTracker",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'DancingScript',
                      shadows: [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black54,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Column(
                  children: [
                    _buildButton(
                      context,
                      text: "Что умеет LifeTracker?",
                      color: Colors.white,
                      textColor: Colors.black,
                      onPressed: () => _showFeatureDialog(context),
                    ),
                    const SizedBox(height: 15),
                    _buildButton(
                      context,
                      text: "Войти / Зарегистрироваться",
                      color: Colors.black,
                      textColor: Colors.white,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthScreen()),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, {required String text, required Color color, required Color textColor, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        child: Text(text),
      ),
    );
  }

  void _showFeatureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Что умеет LifeTracker?"),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.fitness_center, color: Colors.blue),
                title: Text("Фитнес-трекер"),
                subtitle: Text("Следите за тренировками и расходом калорий."),
              ),
              ListTile(
                leading: Icon(Icons.attach_money, color: Colors.green),
                title: Text("Финансовый контроль"),
                subtitle: Text("Управляйте своими расходами и доходами."),
              ),
              ListTile(
                leading: Icon(Icons.favorite, color: Colors.red),
                title: Text("Мониторинг здоровья"),
                subtitle: Text("Отслеживайте сон, сердцебиение и водный баланс."),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Закрыть"),
            ),
          ],
        );
      },
    );
  }
}
