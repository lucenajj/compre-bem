/// Produto do catálogo, identificado pelo código de barras.
class Product {
  final String barcode;
  final String name;
  final double price;
  final String category;

  const Product({
    required this.barcode,
    required this.name,
    required this.price,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        barcode: j['barcode'] as String,
        name: j['name'] as String,
        price: (j['price'] as num).toDouble(),
        category: j['category'] as String? ?? 'Outros',
      );

  Map<String, dynamic> toJson() => {
        'barcode': barcode,
        'name': name,
        'price': price,
        'category': category,
      };
}
