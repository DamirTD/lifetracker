import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/finance/finance_category.dart';
import '../../../providers/finance_provider.dart';


class FinanceCategoryFormScreen extends StatefulWidget {
  final FinanceCategory? category;

  const FinanceCategoryFormScreen({
    super.key,
    this.category,
  });

  @override
  State<FinanceCategoryFormScreen> createState() => _FinanceCategoryFormScreenState();
}

class _FinanceCategoryFormScreenState extends State<FinanceCategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedType = 'expense';
  String? _selectedIcon;
  bool _isLoading = false;
  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'food', 'icon': Icons.restaurant, 'label': 'Food & Dining'},
    {'name': 'transport', 'icon': Icons.directions_car, 'label': 'Transport'},
    {'name': 'shopping', 'icon': Icons.shopping_cart, 'label': 'Shopping'},
    {'name': 'bills', 'icon': Icons.receipt, 'label': 'Bills & Utilities'},
    {'name': 'entertainment', 'icon': Icons.movie, 'label': 'Entertainment'},
    {'name': 'health', 'icon': Icons.health_and_safety, 'label': 'Health'},
    {'name': 'education', 'icon': Icons.school, 'label': 'Education'},
    {'name': 'salary', 'icon': Icons.work, 'label': 'Salary'},
    {'name': 'investment', 'icon': Icons.trending_up, 'label': 'Investments'},
    {'name': 'savings', 'icon': Icons.savings, 'label': 'Savings'},
    {'name': 'other', 'icon': Icons.category, 'label': 'Other'},
  ];

  @override
  void initState() {
    super.initState();

    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedType = widget.category!.type;
      _selectedIcon = widget.category!.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter category name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.style),
              ),
              value: _selectedType,
              items: const [
                DropdownMenuItem(value: 'expense', child: Text('Expense')),
                DropdownMenuItem(value: 'income', child: Text('Income')),
                DropdownMenuItem(value: 'saving', child: Text('Saving')),
                DropdownMenuItem(value: 'investment', child: Text('Investment')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Select Icon',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            // Сетка иконок
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: _availableIcons.length,
              itemBuilder: (context, index) {
                final iconData = _availableIcons[index];
                final isSelected = _selectedIcon == iconData['name'];

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIcon = iconData['name'];
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          iconData['icon'],
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          iconData['name'],
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _submitForm,
              child: Text(
                widget.category == null ? 'Create Category' : 'Update Category',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<FinanceProvider>(context, listen: false);

      bool success;
      if (widget.category == null) {
        final result = await provider.createCategory(
          name: _nameController.text,
          type: _selectedType,
          icon: _selectedIcon,
        );
        success = result != null;
      } else {
        final result = await provider.updateCategory(
          widget.category!.id,
          name: _nameController.text,
          type: _selectedType,
          icon: _selectedIcon,
        );
        success = result != null;
      }

      if (success && mounted) {
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save category. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}