import 'package:compre_bem/widgets/new_product_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dialog mostra botão de foto', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: NewProductDialog(barcode: '123')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Adicionar foto'), findsOneWidget);
    expect(find.text('Produto não encontrado'), findsOneWidget);
  });
}
