import '../models/product.dart';
import '../models/purchase.dart';

const seedCategories = [
  'Mercearia',
  'Frios e Laticínios',
  'Hortifruti',
  'Bebidas',
  'Limpeza',
  'Higiene',
  'Padaria',
  'Outros',
];

List<Product> seedProducts() => const [
      Product(barcode: '7896036091024', name: 'Arroz branco 5kg', price: 24.90, category: 'Mercearia'),
      Product(barcode: '7896036091031', name: 'Feijão carioca 1kg', price: 8.49, category: 'Mercearia'),
      Product(barcode: '7896036091048', name: 'Café torrado e moído 500g', price: 16.90, category: 'Mercearia'),
      Product(barcode: '7896036091055', name: 'Leite integral 1L', price: 5.29, category: 'Frios e Laticínios'),
      Product(barcode: '7896036091062', name: 'Açúcar cristal 1kg', price: 4.99, category: 'Mercearia'),
      Product(barcode: '7896036091079', name: 'Óleo de soja 900ml', price: 7.89, category: 'Mercearia'),
      Product(barcode: '7896036091086', name: 'Macarrão espaguete 500g', price: 4.49, category: 'Mercearia'),
      Product(barcode: '7896036091093', name: 'Farinha de trigo 1kg', price: 5.99, category: 'Mercearia'),
      Product(barcode: '7896036091109', name: 'Sal refinado 1kg', price: 2.99, category: 'Mercearia'),
      Product(barcode: '7896036091116', name: 'Azeite extravirgem 500ml', price: 32.90, category: 'Mercearia'),
      Product(barcode: '7896036091123', name: 'Biscoito recheado chocolate', price: 3.49, category: 'Mercearia'),
      Product(barcode: '7896036091130', name: 'Sabonete 90g', price: 2.79, category: 'Higiene'),
    ];

List<Purchase> seedPurchases(Map<String, Product> byBarcode) {
  CartItem it(String code, int qty) {
    final p = byBarcode[code]!;
    return CartItem(
        barcode: code, name: p.name, price: p.price, category: p.category, qty: qty);
  }

  return [
    Purchase(id: 'seed-1', date: DateTime(2026, 9, 5), items: [
      it('7896036091024', 1),
      it('7896036091031', 2),
      it('7896036091048', 1),
      it('7896036091055', 4),
      it('7896036091062', 1),
      it('7896036091079', 1),
      it('7896036091086', 2),
    ]),
    Purchase(id: 'seed-2', date: DateTime(2026, 9, 19), items: [
      it('7896036091055', 2),
      it('7896036091123', 4),
      it('7896036091130', 3),
      it('7896036091048', 1),
    ]),
    Purchase(id: 'seed-3', date: DateTime(2026, 10, 1), items: [
      it('7896036091024', 1),
      it('7896036091031', 1),
      it('7896036091055', 2),
      it('7896036091109', 1),
    ]),
  ];
}
