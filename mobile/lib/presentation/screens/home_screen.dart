import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Главная страница")),
      body: Center(
        child: Text("Добро пожаловать!", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
