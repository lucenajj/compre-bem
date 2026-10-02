import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../store/app_store.dart';
import '../utils/device.dart';
import '../utils/format.dart';
import '../utils/product_image.dart';

/// Compra atual: itens escaneados, quantidades, total e finalização.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return Column(
      children: [
        Expanded(
          child: store.cart.isEmpty
              ? Center(
                  child: Text(
                    isMobileDevice
                        ? '🧺 Nenhum item ainda.\nEscaneie produtos na aba Escanear.'
                        : '🧺 Nenhum item ainda.\nEscaneie produtos pelo app no celular.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: store.cart.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final it = store.cart[i];
                    return ListTile(
                      leading: productThumb(it.imageBase64),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (it.brand?.trim().isNotEmpty == true)
                            Text(it.brand!.trim(),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600)),
                          Text(it.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      subtitle: Text(
                          '${brl.format(it.price)} cada · ${it.category}\nSubtotal: ${brl.format(it.subtotal)}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () =>
                                store.setQty(it.barcode, it.qty - 1),
                          ),
                          Text('${it.qty}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () =>
                                store.setQty(it.barcode, it.qty + 1),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
            color: Colors.white,
          ),
          child: SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(brl.format(store.cartTotal),
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: store.cart.isEmpty
                        ? null
                        : () async {
                            await store.checkout();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Compra salva! 🎉')),
                              );
                            }
                          },
                    icon: const Icon(Icons.check),
                    label: const Text('Finalizar compra'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
