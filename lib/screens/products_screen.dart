import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../store/app_store.dart';
import '../utils/device.dart';
import '../utils/format.dart';
import '../utils/product_image.dart';
import '../widgets/new_product_dialog.dart';

/// Catálogo de produtos: busca, edição e exclusão.
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(
      BuildContext context, AppStore store, String barcode, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Excluir produto?'),
        content: Text(
            'Remover "$name" do catálogo? Ele também sai do carrinho atual. O histórico de compras é mantido.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    if (ok == true) store.deleteProduct(barcode);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final q = _searchCtrl.text.trim().toLowerCase();
    final items = store.products.values.where((p) {
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          (p.brand?.toLowerCase().contains(q) ?? false) ||
          p.barcode.contains(q);
    }).toList()
      ..sort((a, b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              labelText: 'Buscar produto',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    q.isEmpty
                        ? isMobileDevice
                            ? '📦 Nenhum produto cadastrado ainda.\nEscaneie um código na aba Escanear.'
                            : '📦 Nenhum produto cadastrado ainda.\nCadastre pelo app no celular.'
                        : 'Nenhum produto encontrado.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final p = items[i];
                    return ListTile(
                      leading: productThumb(p.imageBase64),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (p.brand?.trim().isNotEmpty == true)
                            Text(p.brand!.trim(),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600)),
                          Text(p.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      subtitle: Text(
                          '${brl.format(p.price)} · ${p.category}\n${p.barcode}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) => NewProductDialog(
                                  barcode: p.barcode, existing: p),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Excluir',
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () => _confirmDelete(
                                context, store, p.barcode, p.displayName),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
