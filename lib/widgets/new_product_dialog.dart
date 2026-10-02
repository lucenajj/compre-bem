import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/categories.dart';
import '../store/app_store.dart';
import '../utils/format.dart';
import '../utils/product_image.dart';

/// Modal aberto quando o código lido ainda não está cadastrado.
class NewProductDialog extends StatefulWidget {
  final String barcode;
  const NewProductDialog({super.key, required this.barcode});

  @override
  State<NewProductDialog> createState() => _NewProductDialogState();
}

class _NewProductDialogState extends State<NewProductDialog> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _category = appCategories.first;
  String? _imageBase64;
  bool _pickingPhoto = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  double? _parsePrice(String s) {
    s = s.trim().replaceAll('R\$', '').trim();
    if (s.isEmpty) return null;
    if (s.contains(',')) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    }
    return double.tryParse(s);
  }

  void _err(String m) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _pickPhoto() async {
    setState(() => _pickingPhoto = true);
    final photo = await pickProductPhoto(context);
    if (!mounted) return;
    setState(() {
      _pickingPhoto = false;
      if (photo != null) _imageBase64 = photo;
    });
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final price = _parsePrice(_priceCtrl.text);
    if (name.isEmpty) {
      _err('Informe o nome do produto');
      return;
    }
    if (price == null || price < 0) {
      _err('Informe um preço válido');
      return;
    }
    context.read<AppStore>().registerProduct(
          barcode: widget.barcode,
          name: name,
          price: price,
          category: _category,
          imageBase64: _imageBase64,
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name cadastrado por ${brl.format(price)}')));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Produto não encontrado'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Esse código ainda não está cadastrado. Complete os dados:'),
            const SizedBox(height: 8),
            Chip(
              label: Text(widget.barcode,
                  style: const TextStyle(fontFamily: 'monospace')),
            ),
            TextField(
              controller: _nameCtrl,
              decoration:
                  const InputDecoration(labelText: 'Nome do produto'),
              textInputAction: TextInputAction.next,
              autofocus: true,
            ),
            TextField(
              controller: _priceCtrl,
              decoration: const InputDecoration(
                  labelText: 'Preço (R\$)', hintText: 'Ex: 24,90'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: _pickingPhoto ? null : _pickPhoto,
                  child: _pickingPhoto
                      ? const SizedBox(
                          width: 64,
                          height: 64,
                          child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : productThumb(_imageBase64, size: 64),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: _pickingPhoto ? null : _pickPhoto,
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: Text(_imageBase64 == null
                            ? 'Adicionar foto'
                            : 'Trocar foto'),
                      ),
                      if (_imageBase64 != null)
                        TextButton.icon(
                          onPressed: () =>
                              setState(() => _imageBase64 = null),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Remover'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: appCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar')),
        FilledButton(onPressed: _save, child: const Text('Salvar e adicionar')),
      ],
    );
  }
}
