import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../store/app_store.dart';
import '../utils/device.dart';
import '../widgets/new_product_dialog.dart';

/// Tela do leitor de código de barras (câmera + entrada manual).
/// A câmera aparece no celular (app nativo ou navegador mobile).
/// No desktop a aba Escanear nem existe.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _codeCtrl = TextEditingController();
  final _scannerCtrl = MobileScannerController();
  String? _lastCode;
  DateTime? _lastAt;
  bool _dialogOpen = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _scannerCtrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (capture.barcodes.isEmpty) return;
    final v = capture.barcodes.first.rawValue;
    if (v == null || v.isEmpty) return;
    // Evita leituras repetidas do mesmo código em sequência.
    final now = DateTime.now();
    if (v == _lastCode &&
        _lastAt != null &&
        now.difference(_lastAt!).inSeconds < 3) {
      return;
    }
    _lastCode = v;
    _lastAt = now;
    _handleCode(v);
  }

  Future<void> _handleCode(String code) async {
    final store = context.read<AppStore>();
    final existed = store.scan(code);
    if (!mounted) return;
    if (existed) {
      final name = store.productName(code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✓ $name adicionado automaticamente')),
      );
    } else {
      if (_dialogOpen) return;
      _dialogOpen = true;
      await showDialog(
        context: context,
        builder: (_) => NewProductDialog(barcode: code),
      );
      _dialogOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (isMobileDevice) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 260,
              child: MobileScanner(
                controller: _scannerCtrl,
                onDetect: _onDetect,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Código de barras',
                  hintText: 'Digite o código do produto',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onSubmitted: (v) {
                  final code = v.trim();
                  if (code.isNotEmpty) _handleCode(code);
                  _codeCtrl.clear();
                },
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () {
                final code = _codeCtrl.text.trim();
                if (code.isNotEmpty) {
                  _handleCode(code);
                  _codeCtrl.clear();
                }
              },
              child: const Text('Buscar'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          isMobileDevice
              ? 'Aponte a câmera para o código de barras do produto.'
              : 'Digite o código de barras para buscar o produto ou cadastrá-lo.',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
