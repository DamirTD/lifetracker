import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/finance_provider.dart';
import 'finance/finance_dashboard_screen.dart';
import 'finance/finance_budget_screen.dart';
import 'finance/finance_goals_screen.dart';
import 'finance/finance_categories_screen.dart';
import 'finance/finance_budget_form_screen.dart';
import 'finance/finance_goal_form_screen.dart';
import 'finance/finance_category_form_screen.dart';
import 'finance/finance_record_form_screen.dart';

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
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              title: const Text(
                'Финансы',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.refresh,
                      size: 20,
                      color: Colors.blue,
                    ),
                  ),
                  tooltip: 'Обновить данные',
                  onPressed: _refreshData,
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                  onPressed:
                      () => _showNavigationDrawer(
                        scaffoldContext,
                      ), // передаем правильный context
                ),
                const SizedBox(width: 8),
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
              },
              children: const [
                FinanceDashboardWidget(),
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
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Финансы',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Управление финансами',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                _buildDrawerItem(Icons.dashboard_rounded, 'Обзор', 0),
                _buildDrawerItem(Icons.account_balance_wallet_rounded, 'Бюджеты', 1),
                _buildDrawerItem(Icons.flag_rounded, 'Цели', 2),
                _buildDrawerItem(Icons.category_rounded, 'Категории', 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? theme.primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected 
                ? theme.primaryColor.withOpacity(0.15)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected ? theme.primaryColor : Colors.grey[700],
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? theme.primaryColor : Colors.grey[800],
            fontSize: 15,
          ),
        ),
        selected: isSelected,
        onTap: () {
          // Закрываем drawer перед переключением страницы
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          setState(() {
            _selectedIndex = index;
          });
          _pageController.jumpToPage(index);
          _loadDataForTab(index);
        },
      ),
    );
  }

  void _showNavigationDrawer(BuildContext scaffoldContext) {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  Widget? _buildFloatingActionButton() {
    final actions = {
      0: {'action': _navigateToAddTransaction, 'label': 'Транзакцию'},
      1: {'action': _navigateToAddBudget, 'label': 'Бюджет'},
      2: {'action': _navigateToAddGoal, 'label': 'Цель'},
      3: {'action': _navigateToAddCategory, 'label': 'Категорию'},
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
          await provider.getFinanceRecords(period: 'month');
          break;
        case 1:
          await provider.getBudgets();
          break;
        case 2:
          await provider.getFinancialGoals();
          break;
        case 3:
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

  void _navigateToAddTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FinanceRecordFormScreen(),
      ),
    ).then((value) {
      // После возврата обновляем обзор
      _loadDataForTab(0);
    });
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
