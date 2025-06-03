import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/presentation/providers/theme_provider.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/data/repositories/user_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userRepository = UserRepository();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _userRepository.getUser();
    if (mounted) setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: colors.onSurface),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body:
          _user == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildUserHeader(context),
                    const SizedBox(height: 24),
                    _buildSettingsCard(context, themeProvider),
                    const SizedBox(height: 16),
                    _buildUserInfoCard(context),
                    const SizedBox(height: 16),
                    _buildActionsSection(context),
                  ],
                ),
              ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primaryContainer,
            border: Border.all(
              color: colors.primary.withAlpha((0.2 * 255).round()),
              width: 2,
            ),
          ),
          child: Icon(Icons.person, size: 60, color: colors.primary),
        ),
        const SizedBox(height: 16),
        Text(
          _user?.name ?? 'Без имени',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _user?.email ?? '',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface.withAlpha((0.6 * 255).round()),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context, ThemeProvider themeProvider) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colors.outlineVariant.withAlpha((0.3 * 255).round()),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'НАСТРОЙКИ',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurface.withAlpha((0.6 * 255).round()),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            _buildListTile(
              context,
              icon: Icons.dark_mode,
              title: 'Темная тема',
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(),
                activeColor: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colors.outlineVariant.withAlpha((0.3 * 255).round()),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ИНФОРМАЦИЯ',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurface.withAlpha((0.6 * 255).round()),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(context, 'Имя', _user?.name ?? '-'),
            _buildInfoRow(context, 'Email', _user?.email ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          context,
          icon: Icons.edit,
          text: 'Редактировать профиль',
          onPressed: () {},
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          context,
          icon: Icons.help,
          text: 'Помощь и поддержка',
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (_) => AlertDialog(
                    title: const Text('Помощь и поддержка'),
                    content: const Text('Пишите нам: support@lifetracker.app'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Ок'),
                      ),
                    ],
                  ),
            );
          },
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          context,
          icon: Icons.privacy_tip,
          text: 'Политика конфиденциальности',
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (_) => AlertDialog(
                    title: const Text('Политика конфиденциальности'),
                    content: const Text(
                      'Мы заботимся о вашей конфиденциальности.\n\nВаши данные хранятся безопасно и не передаются третьим лицам.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Ок'),
                      ),
                    ],
                  ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: colors.primary),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildInfoRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withAlpha((0.6 * 255).round()),
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    final colors = Theme.of(context).colorScheme;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.onSurface,
        side: BorderSide(color: colors.outlineVariant),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(text)],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Выход'),
            content: const Text('Вы уверены, что хотите выйти из аккаунта?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/logout');
                },
                child: const Text('Выйти'),
              ),
            ],
          ),
    );
  }
}
