import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/models/finance/finance_record.dart';
import 'package:mobile/presentation/providers/finance_provider.dart';
import 'package:mobile/presentation/screens/trackers/finance/finance_record_form_screen.dart';
import 'package:provider/provider.dart';

class FinanceRecordsScreen extends StatefulWidget {
  const FinanceRecordsScreen({super.key});

  @override
  State<FinanceRecordsScreen> createState() => _FinanceRecordsScreenState();
}

class _FinanceRecordsScreenState extends State<FinanceRecordsScreen> {
  late NumberFormat currencyFormat;

  @override
  void initState() {
    super.initState();
    currencyFormat = NumberFormat.currency(
      locale: 'kk_KZ',
      symbol: '₸',
      decimalDigits: 0,
    );
  }

  String _getTitle() {
    return 'История операций';
  }

  String _getSubtitle() {
    return 'Все транзакции по датам';
  }

  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Загружаем данные при первом открытии экрана
    if (!_hasLoaded) {
      _hasLoaded = true;
      _loadRecords();
    }
  }

  Future<void> _loadRecords() async {
    try {
      final provider = Provider.of<FinanceProvider>(
        context,
        listen: false,
      );
      await provider.getFinanceRecords(
        sortBy: 'date',
        sortDirection: 'desc',
        perPage: 1000,
      );
    } catch (e) {
      // Ошибка уже обработана в провайдере
    }
  }

  void _navigateToAddRecord(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FinanceRecordFormScreen()),
    ).then((_) => _loadRecords());
  }

  void _navigateToEditRecord(BuildContext context, FinanceRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FinanceRecordFormScreen(record: record),
      ),
    ).then((_) => _loadRecords());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getTitle(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _getSubtitle(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withOpacity(0.05),
              Colors.white,
              const Color(0xFFF8F9FA),
            ],
          ),
        ),
        child: Consumer<FinanceProvider>(
          builder: (context, provider, child) {
            return _buildContent(theme, provider);
          },
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, FinanceProvider provider) {
    return RefreshIndicator(
      onRefresh: () => _loadRecords(),
      color: theme.primaryColor,
      child: CustomScrollView(
        slivers: [
          // Контент в зависимости от состояния
          if (provider.isLoading && provider.records.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.error != null && provider.records.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Ошибка загрузки',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          provider.error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Повторить'),
                        onPressed: () => _loadRecords(),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (provider.records.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.primaryColor.withOpacity(0.2),
                              theme.primaryColor.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(70),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          size: 70,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Нет транзакций',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Начните отслеживать свои финансы.\nДобавьте первую транзакцию!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: () => _navigateToAddRecord(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.primaryColor,
                                theme.primaryColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                              const SizedBox(width: 8),
                              const Text(
                                'Добавить транзакцию',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            // Список транзакций, сгруппированных по датам
            _buildGroupedByDateList(theme, provider),
        ],
      ),
    );
  }

  Widget _buildGroupedByDateList(ThemeData theme, FinanceProvider provider) {
    final records = [...provider.records]
      ..sort((a, b) => b.date.compareTo(a.date));

    final List<Widget> children = [];
    String? lastDateKey;

    for (final record in records) {
      final date = DateTime(record.date.year, record.date.month, record.date.day);
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      if (dateKey != lastDateKey) {
        lastDateKey = dateKey;
        children.add(_buildDateHeader(theme, date));
      }

      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
          child: _buildDismissibleCard(record, theme, provider),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate(children),
    );
  }

  Widget _buildDateHeader(ThemeData theme, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    String label;
    if (target == today) {
      label = 'Сегодня';
    } else if (target == today.subtract(const Duration(days: 1))) {
      label = 'Вчера';
    } else {
      label = DateFormat('d MMMM yyyy', 'ru').format(date);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissibleCard(FinanceRecord record, ThemeData theme, FinanceProvider provider) {
    return Dismissible(
      key: Key('transaction_${record.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 32),
            SizedBox(height: 8),
            Text(
              'Удалить',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmationDialog(record);
      },
      onDismissed: (direction) {
        _deleteRecord(record.id);
      },
      child: _buildTransactionCard(record, theme),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(FinanceRecord record) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Удалить транзакцию?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Вы уверены, что хотите удалить эту транзакцию?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.categoryName ?? 'Без категории',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currencyFormat.format(record.amount)} • ${DateFormat('dd.MM.yyyy').format(record.date)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Это действие нельзя отменить.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Отмена',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Удалить',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _deleteRecord(int recordId) async {
    try {
      final provider = Provider.of<FinanceProvider>(context, listen: false);
      final success = await provider.deleteFinanceRecord(recordId);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Транзакция удалена'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Не удалось удалить транзакцию'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Widget _buildTransactionCard(FinanceRecord record, ThemeData theme) {
    final isIncome = record.type == 'income';
    final color = isIncome ? Colors.green : Colors.red;
    final icon = isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    final typeLabel = isIncome ? 'Доход' : 'Расход';
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToEditRecord(context, record),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Иконка с градиентом и эффектом свечения
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.25),
                        color.withOpacity(0.15),
                        color.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      Icon(icon, color: color, size: 30),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                // Основная информация
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              record.categoryName ?? 'Без категории',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  color.withOpacity(0.15),
                                  color.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: color.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              typeLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: color,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 13,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd.MM.yyyy').format(record.date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (record.description != null && record.description!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.description_rounded,
                                      size: 13,
                                      color: Colors.blue[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        record.description!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Сумма и подсказка свайпа
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.15),
                            color.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        currencyFormat.format(record.amount),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.swipe_left_rounded,
                          color: Colors.grey[400],
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'удалить',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
