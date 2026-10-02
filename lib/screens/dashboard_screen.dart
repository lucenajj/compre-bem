import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../store/app_store.dart';
import '../utils/format.dart';

/// Dashboard: compra mais cara, produtos mais/menos comprados,
/// gasto por mês e ranking.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final exp = store.mostExpensivePurchase;
    final most = store.mostBought;
    final least = store.leastBought;
    final months = store.monthKeys;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _statCard(context,
            icon: '🧾',
            title: 'Compra mais cara',
            value: exp == null ? '—' : brl.format(exp.total),
            sub: exp == null
                ? '—'
                : 'Compra de ${fmtDate(exp.date)} (${exp.itemCount} itens)'),
        _statCard(context,
            icon: '🏆',
            title: 'Produto que você mais compra',
            value: most == null ? '—' : '${most.value} un.',
            sub: most == null ? '—' : store.productName(most.key)),
        _statCard(context,
            icon: '📉',
            title: 'Produto que você menos compra',
            value: least == null ? '—' : '${least.value} un.',
            sub: least == null ? '—' : store.productName(least.key)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gasto por mês',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                SizedBox(height: 200, child: _monthChart(context, store, months)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ranking de produtos',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...store.ranking.take(8).map((e) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(store.productName(e.key)),
                      trailing: Text('${e.value} un.',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    )),
                Center(
                  child: TextButton(
                    onPressed: () => store.resetDemo(),
                    child: const Text('Restaurar dados de exemplo'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard(BuildContext context,
      {required String icon,
      required String title,
      required String value,
      required String sub}) {
    return Card(
      child: ListTile(
        leading: Text(icon, style: const TextStyle(fontSize: 30)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _monthChart(BuildContext context, AppStore store, List<String> months) {
    if (months.isEmpty) return const Center(child: Text('Sem dados'));
    final maxY =
        months.map((k) => store.statsFor(k).total).reduce((a, b) => a > b ? a : b);
    return BarChart(
      BarChartData(
        maxY: maxY * 1.25,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              getTitlesWidget: (v, meta) => Text(
                brl.format(v),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= months.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(shortMonth(months[i]),
                      style: const TextStyle(fontSize: 11)),
                );
              },
            ),
          ),
        ),
        barGroups: months.asMap().entries.map((e) {
          final st = store.statsFor(e.value);
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: st.total,
                width: 44,
                borderRadius: BorderRadius.circular(6),
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
