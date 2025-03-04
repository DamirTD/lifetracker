import 'package:flutter/material.dart';

class SportScreen extends StatelessWidget {
  const SportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Спорт')),
      body: const Center(child: Text('Экран спорта')),
    );
  }
}
