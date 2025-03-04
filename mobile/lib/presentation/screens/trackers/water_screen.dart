import 'package:flutter/material.dart';

class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вода')),
      body: const Center(child: Text('Экран воды')),
    );
  }
}
