import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/finance_provider.dart';
import 'finance/finance_dashboard_screen.dart';
import 'finance/finance_records_screen.dart';
import 'finance/finance_statistics_screen.dart';
import 'finance/finance_budget_screen.dart';
import 'finance/finance_goals_screen.dart';
import 'finance/finance_categories_screen.dart';
import 'finance/finance_record_form_screen.dart';
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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FinanceProvider>(context, listen: false).getFinanceRecords(period: 'month');
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Финансы'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Уведомления пока недоступны'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_selectedIndex) {
      case 0: // Dashboard
        return FloatingActionButton(
          onPressed: () => _navigateToAddRecord(),
          tooltip: 'Add Transaction',
          child: const Icon(Icons.add),
        );
      case 1: // Records
        return FloatingActionButton(
          onPressed: () => _navigateToAddRecord(),
          tooltip: 'Add Record',
          child: const Icon(Icons.add),
        );
      case 3: // Budget
        return FloatingActionButton(
          onPressed: () => _navigateToAddBudget(),
          tooltip: 'Add Budget',
          child: const Icon(Icons.add),
        );
      case 4: // Goals
        return FloatingActionButton(
          onPressed: () => _navigateToAddGoal(),
          tooltip: 'Add Goal',
          child: const Icon(Icons.add),
        );
      case 5: // Categories
        return FloatingActionButton(
          onPressed: () => _navigateToAddCategory(),
          tooltip: 'Add Category',
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    _loadDataForTab(index);
  }

  void _loadDataForTab(int index) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);

    switch (index) {
      case 0: // Dashboard
        provider.getFinanceRecords(period: 'month');
        provider.getFinancialAdvice();
        break;
      case 1: // Records
        provider.getFinanceRecords(period: 'month');
        break;
      case 2: // Statistics
        provider.getFinanceStatistics(period: 'month');
        break;
      case 3: // Budget
        provider.getBudgets();
        break;
      case 4: // Goals
        provider.getFinancialGoals();
        break;
      case 5: // Categories
        provider.getCategories();
        break;
    }
  }

  void _refreshData() {
    _loadDataForTab(_selectedIndex);
  }

  void _navigateToAddRecord() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FinanceRecordFormScreen(),
      ),
    ).then((value) {
      if (value == true) {
        _refreshData();
      }
    });
  }

  void _navigateToAddBudget() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FinanceBudgetFormScreen(),
      ),
    ).then((value) {
      if (value == true) {
        _refreshData();
      }
    });
  }

  void _navigateToAddGoal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FinanceGoalFormScreen(),
      ),
    ).then((value) {
      if (value == true) {
        _refreshData();
      }
    });
  }

  void _navigateToAddCategory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FinanceCategoryFormScreen(),
      ),
    ).then((value) {
      if (value == true) {
        _refreshData();
      }
    });
  }
}