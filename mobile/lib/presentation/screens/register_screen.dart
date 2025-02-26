import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController            = TextEditingController();
  final TextEditingController surnameController         = TextEditingController();
  final TextEditingController loginController           = TextEditingController();
  final TextEditingController emailController           = TextEditingController();
  final TextEditingController passwordController        = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final AuthRepository authRepository = AuthRepository();

  void register() async {
    final user = await authRepository.register(
      name:                 nameController.text,
      surname:              surnameController.text,
      login:                loginController.text,
      email:                emailController.text,
      password:             passwordController.text,
      passwordConfirmation: confirmPasswordController.text,
    );

   if (!mounted) return;

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Регистрация успешна!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка регистрации")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Регистрация")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Имя")),
            TextField(controller: surnameController, decoration: InputDecoration(labelText: "Фамилия")),
            TextField(controller: loginController, decoration: InputDecoration(labelText: "Логин")),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Пароль"), obscureText: true),
            TextField(controller: confirmPasswordController, decoration: InputDecoration(labelText: "Подтвердите пароль"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: Text("Зарегистрироваться")),
          ],
        ),
      ),
    );
  }
}
