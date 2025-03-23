import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/finance/finance_category.dart';
import '../../../providers/finance_provider.dart';
import 'finance_category_form_screen.dart';
import 'finance_category_detail_screen.dart';

class FinanceCategoriesScreen extends StatefulWidget {
  const FinanceCategoriesScreen({super.key});

  @override
  State<FinanceCategoriesScreen> createState() => _FinanceCategoriesScreenState();
}

class _FinanceCategoriesScreenState extends State<FinanceCategoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    await provider.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
            Tab(text: 'Saving'),
            Tab(text: 'Investment'),
          ],
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(provider.categories.where((c) => c.type == 'expense').toList()),
          _buildCategoryList(provider.categories.where((c) => c.type == 'income').toList()),
          _buildCategoryList(provider.categories.where((c) => c.type == 'saving').toList()),
          _buildCategoryList(provider.categories.where((c) => c.type == 'investment').toList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddCategory(context),
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryList(List<FinanceCategory> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.category_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No categories found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first category to get started',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddCategory(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(FinanceCategory category) {
    final Color categoryColor = _getCategoryColor(category.type);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: categoryColor.withAlpha(50),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: categoryColor,
                    size: 20,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _navigateToEditCategory(context, category);
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, category);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Text(
              category.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              category.type.capitalize(),
              style: TextStyle(
                color: categoryColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String type) {
    switch (type) {
      case 'expense':
        return Colors.red;
      case 'income':
        return Colors.green;
      case 'saving':
        return Colors.blue;
      case 'investment':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(FinanceCategory category) {
    if (category.icon != null) {
      return _mapIconString(category.icon!);
    }

    switch (category.type) {
      case 'expense':
        return Icons.arrow_upward;
      case 'income':
        return Icons.arrow_downward;
      case 'saving':
        return Icons.savings;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }

  IconData _mapIconString(String iconName) {
    switch (iconName) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_cart;
      case 'bills':
        return Icons.receipt;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.health_and_safety;
      case 'education':
        return Icons.school;
      case 'salary':
        return Icons.work;
      case 'investment':
        return Icons.trending_up;
      case 'savings':
        return Icons.savings;
      default:
        return Icons.category;
    }
  }

  void _navigateToAddCategory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FinanceCategoryFormScreen(),
      ),
    ).then((value) {
      if (value == true) {
        _loadCategories();
      }
    });
  }

  void _navigateToEditCategory(BuildContext context, FinanceCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FinanceCategoryFormScreen(category: category),
      ),
    ).then((value) {
      if (value == true) {
        _loadCategories();
      }
    });
  }

  void _showDeleteDialog(BuildContext context, FinanceCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategory(category);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(FinanceCategory category) async {
    if (!mounted) return;

    final provider = Provider.of<FinanceProvider>(context, listen: false);

    try {
      final success = await provider.deleteCategory(category.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        _loadCategories();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete category'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}