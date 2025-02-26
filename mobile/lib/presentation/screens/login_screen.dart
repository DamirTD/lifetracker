import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController loginController    = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthRepository        authRepository     = AuthRepository();

  void login() async {
    final user = await authRepository.login(
      loginController.text,
      passwordController.text,
    );

    if (!mounted) return;

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Вход успешен!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка входа")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Вход")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: loginController, decoration: InputDecoration(labelText: "Логин")),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Пароль"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: Text("Войти")),
          ],
        ),
      ),
    );
  }
}
