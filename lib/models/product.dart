/// Produto do catálogo, identificado pelo código de barras.
class Product {
  final String barcode;
  final String name;
  final double price;
  final String category;

  /// Foto do produto (thumbnail JPEG em base64), opcional.
  final String? imageBase64;

  const Product({
    required this.barcode,
    required this.name,
    required this.price,
    required this.category,
    this.imageBase64,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        barcode: j['barcode'] as String,
        name: j['name'] as String,
        price: (j['price'] as num).toDouble(),
        category: j['category'] as String? ?? 'Outros',
        imageBase64: j['imageBase64'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'barcode': barcode,
        'name': name,
        'price': price,
        'category': category,
        'imageBase64': imageBase64,
      };
}
