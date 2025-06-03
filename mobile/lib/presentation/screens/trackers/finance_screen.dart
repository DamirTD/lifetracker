import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/finance_provider.dart';
import 'finance/finance_dashboard_screen.dart';
import 'finance/finance_records_screen.dart';
import 'finance/finance_statistics_screen.dart';
import 'finance/finance_budget_screen.dart';
import 'finance/finance_goals_screen.dart';
import 'finance/finance_categories_screen.dart';
import 'finance/finance_budget_form_screen.dart';
import 'finance/finance_goal_form_screen.dart';
import 'finance/finance_category_form_screen.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Provider.of<FinanceProvider>(
      context,
      listen: false,
    ).getFinanceRecords(period: 'month');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder:
          (scaffoldContext) => Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: const Text(
                'Финансы',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Обновить данные',
                  onPressed: _refreshData,
                ),
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed:
                      () => _showNavigationDrawer(
                        scaffoldContext,
                      ), // передаем правильный context
                ),
              ],
            ),
            endDrawer: _buildNavigationDrawer(),
            body: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                _loadDataForTab(index);
                Navigator.pop(context); // Закрываем drawer после выбора
              },
              children: const [
                FinanceDashboardWidget(),
                FinanceRecordsScreen(),
                FinanceStatisticsScreen(),
                FinanceBudgetScreen(),
                FinanceGoalsScreen(),
                FinanceCategoriesScreen(),
              ],
            ),
            floatingActionButton: _buildFloatingActionButton(),
          ),
    );
  }

  Widget _buildNavigationDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Финансовое управление',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Обзор', 0),
          _buildDrawerItem(Icons.receipt_long, 'Транзакции', 1),
          _buildDrawerItem(Icons.analytics, 'Статистика', 2),
          _buildDrawerItem(Icons.account_balance_wallet, 'Бюджеты', 3),
          _buildDrawerItem(Icons.flag, 'Цели', 4),
          _buildDrawerItem(Icons.category, 'Категории', 5),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Помощь'),
            onTap: () {
              Navigator.pop(context);
              _showHelpDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            _selectedIndex == index
                ? Theme.of(context).primaryColor
                : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight:
              _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _pageController.jumpToPage(index);
        _loadDataForTab(index);
      },
    );
  }

  void _showNavigationDrawer(BuildContext scaffoldContext) {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _showHelpDialog() {
    final tabNames = [
      'Обзор',
      'Транзакции',
      'Статистика',
      'Бюджеты',
      'Цели',
      'Категории',
    ];
    final currentTabName = tabNames[_selectedIndex];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Помощь: $currentTabName'),
            content: Text(
              _getHelpTextForCurrentTab(),
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Понятно'),
              ),
            ],
          ),
    );
  }

  String _getHelpTextForCurrentTab() {
    switch (_selectedIndex) {
      case 0:
        return 'Общий обзор ваших финансов: баланс, доходы, расходы и советы.';
      case 1:
        return 'Просмотр и управление всеми транзакциями. Используйте фильтры для поиска.';
      case 2:
        return 'Детальная статистика доходов и расходов с графиками.';
      case 3:
        return 'Управление бюджетами и лимитами по категориям.';
      case 4:
        return 'Постановка и отслеживание финансовых целей.';
      case 5:
        return 'Управление категориями для точного учета операций.';
      default:
        return '';
    }
  }

  Widget? _buildFloatingActionButton() {
    final actions = {
      3: {'action': _navigateToAddBudget, 'label': 'Бюджет'},
      4: {'action': _navigateToAddGoal, 'label': 'Цель'},
      5: {'action': _navigateToAddCategory, 'label': 'Категорию'},
    };

    final config = actions[_selectedIndex];
    if (config == null) return null;

    return FloatingActionButton.extended(
      onPressed: config['action'] as void Function()?,
      icon: const Icon(Icons.add),
      label: Text('Добавить ${config['label']}'),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Future<void> _loadDataForTab(int index) async {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    try {
      switch (index) {
        case 0:
          await Future.wait([
            provider.getFinanceRecords(period: 'month'),
            provider.getFinancialAdvice(),
          ]);
          break;
        case 1:
          await provider.getFinanceRecords(period: 'month');
          break;
        case 2:
          await provider.getFinanceStatistics(period: 'month');
          break;
        case 3:
          await provider.getBudgets();
          break;
        case 4:
          await provider.getFinancialGoals();
          break;
        case 5:
          await provider.getCategories();
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Обновление данных...'),
        duration: Duration(seconds: 1),
      ),
    );
    await _loadDataForTab(_selectedIndex);
  }

  void _navigateToAddBudget() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FinanceBudgetFormScreen()),
    ).then((value) {
      if (value == true) _refreshData();
    });
  }

  void _navigateToAddGoal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FinanceGoalFormScreen()),
    ).then((value) {
      if (value == true) _refreshData();
    });
  }

  void _navigateToAddCategory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FinanceCategoryFormScreen(),
      ),
    ).then((value) {
      if (value == true) _refreshData();
    });
  }
}
