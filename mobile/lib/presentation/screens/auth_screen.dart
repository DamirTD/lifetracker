import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final TextEditingController loginController           = TextEditingController();
  final TextEditingController passwordController        = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController firstNameController       = TextEditingController();
  final TextEditingController lastNameController        = TextEditingController();
  final TextEditingController emailController           = TextEditingController();
  final TextEditingController phoneController           = TextEditingController();
  final AuthRepository authRepository                   = AuthRepository();

  void login() async {
    final user = await authRepository.login(
      loginController.text,
      passwordController.text,
    );

    if (!mounted) return;

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Вход успешен!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ошибка входа. Проверьте данные.")),
      );
    }
  }

  void register() {
    // Логика регистрации
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Регистрация успешна!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Добро пожаловать"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() => isLogin = true),
                child: Text(
                  "Вход",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isLogin ? Colors.black : Colors.grey,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => isLogin = false),
                child: Text(
                  "Регистрация",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: !isLogin ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: isLogin ? _buildLoginForm() : _buildRegisterForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.lock_outline, size: 80, color: Colors.blueAccent),
        const SizedBox(height: 10),
        const Text(
          "Войдите в аккаунт",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: loginController,
          decoration: const InputDecoration(
            labelText: "Логин или Email",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Пароль",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: login,
            child: const Text("Войти"),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: firstNameController,
            decoration: const InputDecoration(
              labelText: "Имя",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: lastNameController,
            decoration: const InputDecoration(
              labelText: "Фамилия",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: "Номер телефона",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Пароль",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Подтвердите пароль",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Нажимая на кнопку, вы подтверждаете согласие с условиями использования.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: register,
              child: const Text("Зарегистрироваться"),
            ),
          ),
        ],
      ),
    );
  }
}
