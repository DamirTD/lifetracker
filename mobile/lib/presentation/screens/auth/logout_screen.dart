import 'package:flutter/material.dart';
import 'package:mobile/data/repositories/auth_repository.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  LogoutScreenState createState() => LogoutScreenState();
}

class LogoutScreenState extends State<LogoutScreen> {
  final AuthRepository _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _logout();
  }

  Future<void> _logout() async {
    try {
      await _authRepository.logout();
    } catch (e) {
      // ignore: avoid_print
      print("Ошибка при выходе: $e");
    }

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
