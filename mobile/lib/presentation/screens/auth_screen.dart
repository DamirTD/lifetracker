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
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool isLogin = true;
  
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  final _formKey = GlobalKey<FormState>();

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
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ),
      );
    } else {
      _showSnackBar("Ошибка входа. Проверьте данные.", Colors.red);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    // Реализация регистрации
    await Future.delayed(const Duration(seconds: 1)); // Заглушка для имитации
    
    if (!mounted) return;
    setState(() => _isLoading = false);
    _showSnackBar("Регистрация успешна!", Colors.green);
    _toggleAuthMode();
  }

  void _showSnackBar(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(color == Colors.green ? Icons.check_circle : Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                
                // Toggle Auth Mode
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
                
                // Форма
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
      children: [
        _buildInputField(
          controller: _loginController,
          icon: Icons.person_outline,
          label: "Логин или Email",
          validator: (value) => value!.isEmpty ? 'Введите логин' : null,
        ),
        const SizedBox(height: 20),
        _buildPasswordField(
          controller: _passwordController,
          label: "Пароль",
          obscureText: _obscurePassword,
          toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
          validator: (value) => value!.length < 6 ? 'Минимум 6 символов' : null,
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _login,
            icon: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.login_rounded),
            label: Text(_isLoading ? "Загрузка..." : "Войти"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
              elevation: 3,
            ),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text("Забыли пароль?"),
        ),
      ],
    );
  }
  

  Widget _buildRegisterForm(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: _firstNameController,
                icon: Icons.person_outline,
                label: "Имя",
                validator: (value) => value!.isEmpty ? 'Введите имя' : null,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildInputField(
                controller: _lastNameController,
                icon: Icons.person_outline,
                label: "Фамилия",
                validator: (value) => value!.isEmpty ? 'Введите фамилию' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildInputField(
          controller: _emailController,
          icon: Icons.email_outlined,
          label: "Email",
          validator: (value) => !value!.contains('@') ? 'Некорректный email' : null,
        ),
        const SizedBox(height: 20),
        _buildInputField(
          controller: _phoneController,
          icon: Icons.phone_outlined,
          label: "Телефон",
          validator: (value) => value!.length < 10 ? 'Некорректный телефон' : null,
        ),
        const SizedBox(height: 20),
        _buildPasswordField(
          controller: _passwordController,
          label: "Пароль",
          obscureText: _obscurePassword,
          toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
          validator: (value) => value!.length < 6 ? 'Минимум 6 символов' : null,
        ),
        const SizedBox(height: 20),
        _buildPasswordField(
          controller: _confirmPasswordController,
          label: "Подтвердите пароль",
          obscureText: _obscureConfirmPassword,
          toggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          validator: (value) => value != _passwordController.text ? 'Пароли не совпадают' : null,
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _register,
            icon: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.app_registration_rounded),
            label: Text(_isLoading ? "Регистрация..." : "Зарегистрироваться"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
              elevation: 3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        errorStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    bool obscureText = true,
    VoidCallback? toggleObscure,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600),
        suffixIcon: toggleObscure != null 
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade600,
                ),
                onPressed: toggleObscure,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        errorStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}