import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../store/app_store.dart';
import '../utils/format.dart';

/// Compara o mês atual com o mês anterior:
/// totais, novidades, itens não recomprados e tabela produto a produto.
class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final cur = store.currentMonth;
    if (cur == null) {
      return const Center(child: Text('Sem compras ainda.'));
    }
    final prev = store.previousMonth;
    final a = store.statsFor(cur);
    final b = prev != null ? store.statsFor(prev) : null;

    final newCodes = prev != null ? store.newInMonth(cur, prev) : <String>[];
    final missingCodes =
        prev != null ? store.missingInMonth(cur, prev) : <String>[];

    double? diffPct;
    if (b != null && b.total > 0) {
      diffPct = (a.total - b.total) / b.total * 100;
    }

    final keysA = a.qtyByBarcode.keys.toSet();
    final keysB = b?.qtyByBarcode.keys.toSet() ?? <String>{};
    final union = {...keysA, ...keysB}.toList()
      ..sort((x, y) => store.productName(x).compareTo(store.productName(y)));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: _monthCard(context, prev == null ? '—' : monthLabel(prev), b)),
            const SizedBox(width: 12),
            Expanded(child: _monthCard(context, monthLabel(cur), a)),
          ],
        ),
        if (diffPct != null) ...[
          const SizedBox(height: 12),
          Center(
            child: Text(
              '${diffPct >= 0 ? '▲' : '▼'} ${diffPct.abs().toStringAsFixed(1)}% em relação a ${monthLabel(prev!).toLowerCase()}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: diffPct >= 0 ? Colors.red : Colors.green,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text('✨ Comprou este mês, mas não no anterior',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        _pillWrap(context, newCodes, a.qtyByBarcode, Colors.green,
            empty: 'Nada por aqui.'),
        const SizedBox(height: 16),
        Text('⚠️ Comprou no mês anterior e não recomprou',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        _pillWrap(context, missingCodes, b?.qtyByBarcode ?? {}, Colors.orange,
            empty: 'Nada por aqui.'),
        const SizedBox(height: 16),
        Text('🔍 Produto a produto',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Card(
          child: DataTable(
            columns: [
              const DataColumn(label: Text('Produto')),
              DataColumn(label: Text(prev == null ? 'Ant.' : shortMonth(prev))),
              DataColumn(label: Text(shortMonth(cur))),
            ],
            rows: union.map((code) {
              final qa = a.qtyByBarcode[code] ?? 0;
              final qb = b?.qtyByBarcode[code] ?? 0;
              final mark = qa > qb ? ' ▲' : qb > qa ? ' ▼' : '';
              return DataRow(cells: [
                DataCell(Text(store.productName(code))),
                DataCell(Text(qb == 0 ? '—' : '$qb')),
                DataCell(Text('${qa == 0 ? '—' : qa}$mark',
                    style: const TextStyle(fontWeight: FontWeight.bold))),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _monthCard(BuildContext context, String label, MonthStats? s) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(s == null ? '—' : brl.format(s.total),
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            Text(s == null ? '—' : '${s.itemCount} itens',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _pillWrap(BuildContext context, List<String> codes,
      Map<String, int> qty, Color color,
      {required String empty}) {
    final store = context.read<AppStore>();
    if (codes.isEmpty) {
      return Text(empty, style: const TextStyle(color: Colors.grey));
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: codes
          .map((c) => Chip(
                label: Text('${store.productName(c)} ×${qty[c] ?? 0}'),
                side: BorderSide(color: color),
              ))
          .toList(),
    );
  }
}
