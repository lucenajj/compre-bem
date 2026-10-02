/// Item de compra/carrinho. Guarda nome e preço do momento da compra,
/// para o histórico não mudar se o preço do catálogo mudar depois.
class CartItem {
  final String barcode;

  /// Nome da marca/empresa (ex: "Dona Nena"), opcional.
  final String? brand;
  final String name;
  final double price;
  final String category;

  /// Foto do produto (thumbnail JPEG em base64), opcional.
  final String? imageBase64;
  int qty;

  CartItem({
    required this.barcode,
    this.brand,
    required this.name,
    required this.price,
    required this.category,
    this.imageBase64,
    this.qty = 1,
  });

  double get subtotal => price * qty;

  /// "Marca — Nome" ou só o nome quando não há marca.
  String get displayName {
    final b = brand?.trim();
    return (b == null || b.isEmpty) ? name : '$b — $name';
  }

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
        barcode: j['barcode'] as String,
        brand: j['brand'] as String?,
        name: j['name'] as String,
        price: (j['price'] as num).toDouble(),
        category: j['category'] as String? ?? 'Outros',
        imageBase64: j['imageBase64'] as String?,
        qty: (j['qty'] as num?)?.toInt() ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'barcode': barcode,
        'brand': brand,
        'name': name,
        'price': price,
        'category': category,
        'imageBase64': imageBase64,
        'qty': qty,
      };
}

/// Uma compra finalizada, com data e itens.
class Purchase {
  final String id;
  final DateTime date;
  final List<CartItem> items;

  Purchase({required this.id, required this.date, required this.items});

  double get total => items.fold(0.0, (s, i) => s + i.subtotal);
  int get itemCount => items.fold(0, (s, i) => s + i.qty);

  factory Purchase.fromJson(Map<String, dynamic> j) => Purchase(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        items: (j['items'] as List)
            .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
      };
}
