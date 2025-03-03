import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isLoading              = false;
  final bool _obscurePassword  = true;
  bool isLogin                 = true;
  
  final TextEditingController _loginController           = TextEditingController();
  final TextEditingController _passwordController        = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController       = TextEditingController();
  final TextEditingController _lastNameController        = TextEditingController();
  final TextEditingController _emailController           = TextEditingController();
  final AuthRepository _authRepository                   = AuthRepository();
  final _formKey                                         = GlobalKey<FormState>();

   @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
      _controller.reset();
      _controller.forward();
    });
  }

   Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    final user = await _authRepository.login(
      _loginController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user != null) {
      _showSnackBar("Вход выполнен успешно!", Colors.green);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      _showSnackBar("Ошибка входа. Проверьте данные.", Colors.red);
    }
  }

  Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);

  final authRepo = AuthRepository();
  final response = await authRepo.register({
    "name": _firstNameController.text,
    "surname": _lastNameController.text,
    "login": _loginController.text,
    "email": _emailController.text,
    "password": _passwordController.text,
    "password_confirmation": _confirmPasswordController.text,
  });

  setState(() => _isLoading = false);

  if (response["status"] == 200) {
    _showSnackBar("Регистрация успешна!", Colors.green);
    _toggleAuthMode();
  } else {
    final errorData = response["body"];
    if (errorData.containsKey('errors')) {
      String errorMessage = errorData['errors'].values.map((e) => e.join("\n")).join("\n");
      _showSnackBar(errorMessage, Colors.red);
    } else {
      _showSnackBar("Ошибка регистрации. Попробуйте снова.", Colors.red);
    }
  }
}


  void _showSnackBar(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          height: size.height,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    isLogin ? "С возвращением!" : "Создайте аккаунт",
                    key: ValueKey<bool>(isLogin),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.primaryColorDark,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: isLogin ? theme.primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextButton(
                            onPressed: isLogin ? null : _toggleAuthMode,
                            child: Text(
                              "Вход",
                              style: TextStyle(
                                color: isLogin ? Colors.white : theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: !isLogin ? theme.primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextButton(
                            onPressed: !isLogin ? null : _toggleAuthMode,
                            child: Text(
                              "Регистрация",
                              style: TextStyle(
                                color: !isLogin ? Colors.white : theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                AnimatedSize(
                  duration: const Duration(milliseconds: 500),
                  child: isLogin ? _buildLoginForm(theme) : _buildRegisterForm(theme),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

 Widget _buildLoginForm(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(controller: _loginController, decoration: const InputDecoration(labelText: "Логин")),
        TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Пароль"), obscureText: _obscurePassword),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _login,
          child: _isLoading ? const CircularProgressIndicator() : const Text("Войти"),
        ),
        TextButton(
          onPressed: _toggleAuthMode,
          child: const Text("Нет аккаунта? Регистрация"),
        ),
      ],
    );
  }
  
  Widget _buildRegisterForm(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(controller: _firstNameController, decoration: const InputDecoration(labelText: "Имя")),
        TextField(controller: _lastNameController, decoration: const InputDecoration(labelText: "Фамилия")),
        TextField(controller: _loginController, decoration: const InputDecoration(labelText: "Логин")),
        TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
        TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Пароль"), obscureText: _obscurePassword),
        TextField(controller: _confirmPasswordController, decoration: const InputDecoration(labelText: "Подтвердите пароль"), obscureText: _obscurePassword),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _register,
          child: _isLoading ? const CircularProgressIndicator() : const Text("Зарегистрироваться"),
        ),
        TextButton(
          onPressed: _toggleAuthMode,
          child: const Text("Уже есть аккаунт? Войти"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}