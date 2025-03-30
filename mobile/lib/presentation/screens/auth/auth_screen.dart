import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../home/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading       = false;
  bool _obscurePassword = true;
  int _currentStep      = 0;
  final int _totalSteps = 3;

  final TextEditingController _loginController           = TextEditingController();
  final TextEditingController _passwordController        = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController       = TextEditingController();
  final TextEditingController _lastNameController        = TextEditingController();
  final TextEditingController _emailController           = TextEditingController();
  final AuthRepository _authRepository                   = AuthRepository();
  final _formKey = GlobalKey<FormState>();

  final _stepOneFormKey   = GlobalKey<FormState>();
  final _stepTwoFormKey   = GlobalKey<FormState>();
  final _stepThreeFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _currentStep = 0;
        _clearFields();
      }
      setState(() {});
    });
  }

  void _clearFields() {
    _loginController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _nextStep() {
    bool isValid = false;

    switch (_currentStep) {
      case 0:
        isValid = _stepOneFormKey.currentState?.validate() ?? false;
        break;
      case 1:
        isValid = _stepTwoFormKey.currentState?.validate() ?? false;
        break;
      case 2:
        isValid = _stepThreeFormKey.currentState?.validate() ?? false;
        break;
    }

    if (isValid) {
      setState(() {
        if (_currentStep < _totalSteps - 1) {
          _currentStep++;
        }
      });
    }
  }

  void _prevStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
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
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar("Ошибка соединения. Попробуйте позже.", Colors.red);
    }
  }

  Future<void> _register() async {
    if (!_stepThreeFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final response = await _authRepository.register({
        "name": _firstNameController.text,
        "surname": _lastNameController.text,
        "login": _loginController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "password_confirmation": _confirmPasswordController.text,
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response["status"] == 200) {
        _showSnackBar("Регистрация успешна!", Colors.green);
        _tabController.animateTo(0);
        _currentStep = 0;
      } else {
        final errorData = response["body"];
        if (errorData.containsKey('errors')) {
          String errorMessage = errorData['errors'].values.map((e) => e.join("\n")).join("\n");
          _showSnackBar(errorMessage, Colors.red);
        } else {
          _showSnackBar("Ошибка регистрации. Попробуйте снова.", Colors.red);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar("Ошибка соединения. Попробуйте позже.", Colors.red);
    }
  }

  void _showSnackBar(String text, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withAlpha(26),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.05),
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(26),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withAlpha(77),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: theme.primaryColor,
                        tabs: [
                          Tab(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              child: const Text(
                                "Вход",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          Tab(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              child: const Text(
                                "Регистрация",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    IndexedStack(
                      index: _tabController.index,
                      children: [
                        _buildLoginForm(theme),
                        _buildRegisterForm(theme),
                      ],
                    ),
                    SizedBox(height: size.height * 0.05),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "С возвращением!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.primaryColorDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Войдите, чтобы продолжить",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _loginController,
          label: "Логин",
          prefixIcon: Icons.person_outline_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Введите логин";
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: "Пароль",
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: theme.primaryColor,
            ),
            onPressed: _togglePasswordVisibility,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Введите пароль";
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "Забыли пароль?",
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: theme.primaryColor.withAlpha(102),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text(
              "Войти",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(ThemeData theme) {
    String stepTitle = "";
    String stepSubtitle = "";

    switch (_currentStep) {
      case 0:
        stepTitle = "Основная информация";
        stepSubtitle = "Расскажите о себе";
        break;
      case 1:
        stepTitle = "Создание аккаунта";
        stepSubtitle = "Укажите данные для входа";
        break;
      case 2:
        stepTitle = "Безопасность";
        stepSubtitle = "Создайте надежный пароль";
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(_totalSteps, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 8.0 : 0),
                decoration: BoxDecoration(
                  color: index <= _currentStep
                      ? theme.primaryColor
                      : Colors.grey.withAlpha(77),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),

        Text(
          stepTitle,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.primaryColorDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          stepSubtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),

        if (_currentStep == 0) _buildRegisterStepOne(theme),
        if (_currentStep == 1) _buildRegisterStepTwo(theme),
        if (_currentStep == 2) _buildRegisterStepThree(theme),

        const SizedBox(height: 24),

        Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _prevStep,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Назад",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),

            if (_currentStep > 0) const SizedBox(width: 16),

            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_currentStep < _totalSteps - 1 ? _nextStep : _register),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: theme.primaryColor.withAlpha(102),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    _currentStep < _totalSteps - 1 ? "Далее" : "Регистрация",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterStepOne(ThemeData theme) {
    return Form(
      key: _stepOneFormKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _firstNameController,
            label: "Имя",
            prefixIcon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Введите имя";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _lastNameController,
            label: "Фамилия",
            prefixIcon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Введите фамилию";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterStepTwo(ThemeData theme) {
    return Form(
      key: _stepTwoFormKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _loginController,
            label: "Логин",
            prefixIcon: Icons.account_circle_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Введите логин";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _emailController,
            label: "Email",
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Введите email";
              }
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return "Введите корректный email";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterStepThree(ThemeData theme) {
    return Form(
      key: _stepThreeFormKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _passwordController,
            label: "Пароль",
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: theme.primaryColor,
              ),
              onPressed: _togglePasswordVisibility,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Введите пароль";
              }
              if (value.length < 6) {
                return "Пароль должен содержать минимум 6 символов";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _confirmPasswordController,
            label: "Подтвердите пароль",
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Подтвердите пароль";
              }
              if (value != _passwordController.text) {
                return "Пароли не совпадают";
              }
              return null;
            },
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Требования к паролю:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColorDark,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPasswordRequirement(
                    "Минимум 6 символов",
                    _passwordController.text.length >= 6,
                    theme
                ),
                _buildPasswordRequirement(
                    "Пароли совпадают",
                    _confirmPasswordController.text.isNotEmpty &&
                        _confirmPasswordController.text == _passwordController.text,
                    theme
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? Colors.green : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? theme.primaryColorDark : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.withAlpha(26),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        errorStyle: const TextStyle(height: 0.8),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}