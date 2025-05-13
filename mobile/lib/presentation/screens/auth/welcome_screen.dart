import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'auth_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _controller = PageController();
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_controller.hasClients) {
        int nextPage = (_controller.page?.round() ?? 0) + 1;
        if (nextPage > 2) nextPage = 0;
        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Логотип
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  size: 60,
                  color: Colors.lightBlue,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "LifeTracker",
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Здоровый образ жизни начинается здесь",
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.blueGrey,
                ),
              ),

              const SizedBox(height: 24),

              // Слайдер
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (index) {},
                  children: [
                    _buildSlide(
                      icon: Icons.fitness_center,
                      title: "Фитнес-трекер",
                      description:
                          "Следите за тренировками и сжиганием калорий",
                      color: Colors.lightBlue,
                    ),
                    _buildSlide(
                      icon: Icons.auto_graph,
                      title: "Финансовый контроль",
                      description: "Отслеживайте доходы, расходы и цели",
                      color: Colors.blueAccent,
                    ),
                    _buildSlide(
                      icon: Icons.nightlight_round,
                      title: "Качество сна",
                      description: "Анализируйте сон и улучшайте здоровье",
                      color: Colors.indigo,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Индикатор
              SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: ExpandingDotsEffect(
                  activeDotColor: Colors.blueAccent,
                  dotColor: Colors.blue.shade100,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),

              const SizedBox(height: 30),

              // Кнопки Войти / Зарегистрироваться
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedButton(
                      icon: Icons.login,
                      label: "Войти",
                      backgroundColor: Colors.blueAccent,
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AuthScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    AnimatedButton(
                      icon: Icons.person_add_alt_1,
                      label: "Зарегистрироваться",
                      backgroundColor: Colors.white,
                      textColor: Colors.blueAccent,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AuthScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: color),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

// Кастомная кнопка
class AnimatedButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  const AnimatedButton({
    super.key,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
      ),
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontFamily: 'Poppins'),
      ),
    );
  }
}
