import 'package:flutter/material.dart';
import 'auth_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Фоновое изображение с затемнением
          Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/img/background.jpg'),
                fit: BoxFit.cover,
              ),
              color: Colors.black.withOpacity(0.3),
              backgroundBlendMode: BlendMode.darken,
            ),
          ),

          // Основной контент
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.12),
                
                // Анимированный логотип
                AnimatedScale(
                  duration: const Duration(milliseconds: 500),
                  scale: 1,
                  child: const Text(
                    "LifeTracker",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const Spacer(),

                // Кнопки действий
                Column(
                  children: [
                    _buildFeatureButton(context),
                    const SizedBox(height: 20),
                    _buildAuthButton(context),
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

  Widget _buildFeatureButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showFeatureDialog(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.95),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.3),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.quiz_outlined, size: 24),
          const SizedBox(width: 12),
          const Text("Возможности"),
        ],
      ),
    );
  }

  Widget _buildAuthButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
        shadowColor: Colors.blueAccent.withOpacity(0.4),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login_rounded, size: 24),
          SizedBox(width: 12),
          Text("Начать использовать"),
        ],
      ),
    );
  }

  void _showFeatureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          backgroundColor: Colors.white.withOpacity(0.95),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Возможности LifeTracker",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 20),
                _buildFeatureTile(
                  icon: Icons.fitness_center,
                  title: "Фитнес-трекер",
                  description: "Анализ тренировок и расхода калорий",
                  color: Colors.blueAccent,
                ),
                _buildFeatureTile(
                  icon: Icons.auto_graph_rounded,
                  title: "Финансы",
                  description: "Управление бюджетом и статистика",
                  color: Colors.green,
                ),
                _buildFeatureTile(
                  icon: Icons.health_and_safety,
                  title: "Здоровье",
                  description: "Мониторинг сна и показателей здоровья",
                  color: Colors.orange,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Понятно", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}