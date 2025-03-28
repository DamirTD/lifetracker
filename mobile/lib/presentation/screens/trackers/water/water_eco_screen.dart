import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/water_providers.dart';

class WaterEcoScreen extends StatefulWidget {
  const WaterEcoScreen({super.key});

  @override
  WaterEcoScreenState createState() => WaterEcoScreenState();
}

class WaterEcoScreenState extends State<WaterEcoScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final provider = Provider.of<WaterProvider>(context, listen: false);
      provider.loadEcoReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Экологический отчет'),
      ),
      body: Consumer<WaterProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка загрузки данных',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadEcoReport();
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          if (provider.ecoReport == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.eco_outlined,
                    size: 64,
                    color: Colors.green[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Начните отслеживать потребление воды',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Используйте трекер воды регулярно, чтобы увидеть свой экологический вклад',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return _buildEcoReport(context, provider);
        },
      ),
    );
  }

  Widget _buildEcoReport(BuildContext context, WaterProvider provider) {
    final ecoReport = provider.ecoReport!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ваш вклад в экологию',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Используя трекер воды, вы сокращаете использование пластиковых бутылок и помогаете сохранить окружающую среду.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _buildEcoCard(
            context,
            'Сэкономлено пластиковых бутылок',
            '${ecoReport.bottlesSaved}',
            'бутылок',
            Icons.water_drop,
            Colors.blue[100]!,
          ),
          const SizedBox(height: 16),
          _buildEcoCard(
            context,
            'Сэкономлено пластика',
            (ecoReport.plasticSavedG / 1000).toStringAsFixed(1),
            'кг',
            Icons.recycling,
            Colors.green[100]!,
          ),
          const SizedBox(height: 16),
          _buildEcoCard(
            context,
            'Снижение выбросов CO₂',
            (ecoReport.co2SavedG / 1000).toStringAsFixed(1),
            'кг',
            Icons.co2,
            Colors.orange[100]!,
          ),
          const SizedBox(height: 16),
          _buildEcoCard(
            context,
            'Сохранено воды при производстве',
            '${ecoReport.waterSavedL}',
            'литров',
            Icons.opacity,
            Colors.blue[100]!,
          ),
          const SizedBox(height: 16),
          _buildEcoCard(
            context,
            'Эквивалент в деревьях',
            ecoReport.treesEquivalent.toStringAsFixed(2),
            'деревьев',
            Icons.nature,
            Colors.green[100]!,
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Советы по снижению использования пластика',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildEcoTipCard(
            context,
            'Используйте многоразовую бутылку',
            'Качественная многоразовая бутылка прослужит годами и заменит сотни пластиковых бутылок.',
            Icons.water_drop,
          ),
          const SizedBox(height: 12),
          _buildEcoTipCard(
            context,
            'Фильтр для воды',
            'Используйте фильтр для воды дома, это экономичнее и экологичнее, чем покупка бутилированной воды.',
            Icons.filter_alt,
          ),
          const SizedBox(height: 12),
          _buildEcoTipCard(
            context,
            'Отказ от одноразовых стаканчиков',
            'Носите с собой свою кружку для кофе или чая вместо использования одноразовых стаканчиков.',
            Icons.coffee,
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                _shareEcoReport(context, ecoReport);
              },
              icon: const Icon(Icons.share),
              label: const Text('Поделиться вкладом'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoCard(
      BuildContext context,
      String title,
      String value,
      String unit,
      IconData icon,
      Color color,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withValues(alpha: 0.3 * 255),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEcoTipCard(
      BuildContext context,
      String title,
      String description,
      IconData icon,
      ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.green),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareEcoReport(BuildContext context, ecoReport) {
    // Здесь должен быть код для создания сообщения для шаринга
    // и открытия системного диалога шаринга

    final message = 'Я сэкономил(а) ${ecoReport.bottlesSaved} пластиковых бутылок, '
        '${(ecoReport.plasticSavedG / 1000).toStringAsFixed(1)} кг пластика и '
        '${(ecoReport.co2SavedG / 1000).toStringAsFixed(1)} кг CO₂, используя трекер воды.';

    // Вызов системного диалога шаринга
    // В реальном приложении здесь будет использоваться плагин для шаринга
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Шаринг: $message'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}