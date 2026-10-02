import 'package:compre_bem/widgets/new_product_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dialog tem foto e marca acima do nome', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: NewProductDialog(barcode: '123')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Adicionar foto'), findsOneWidget);
    expect(find.text('Nome da marca'), findsOneWidget);
    expect(find.text('Nome do produto'), findsOneWidget);
    // marca aparece antes do nome do produto na ordem dos campos
    final brandPos = tester.getTopLeft(find.text('Nome da marca')).dy;
    final namePos = tester.getTopLeft(find.text('Nome do produto')).dy;
    expect(brandPos, lessThan(namePos));
  });
}
