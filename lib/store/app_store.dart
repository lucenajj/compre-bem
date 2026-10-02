import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../models/purchase.dart';
import '../utils/format.dart';

const _storageKey = 'comprebem_v1';

/// Códigos de barras dos produtos de exemplo (removidos na limpeza de 2026-10-02).
/// Usados só pela migração que apaga dados de exemplo de instalações antigas.
const _legacySeedBarcodes = {
  '7896036091024',
  '7896036091031',
  '7896036091048',
  '7896036091055',
  '7896036091062',
  '7896036091079',
  '7896036091086',
  '7896036091093',
  '7896036091109',
  '7896036091116',
  '7896036091123',
  '7896036091130',
};

/// Agregado de um mês: total gasto, nº de itens e quantidade por produto.
class MonthStats {
  final double total;
  final int itemCount;
  final Map<String, int> qtyByBarcode;
  const MonthStats({
    required this.total,
    required this.itemCount,
    required this.qtyByBarcode,
  });
}

/// Estado global do app: catálogo, carrinho e histórico de compras.
/// Persiste tudo em SharedPreferences (funciona em Android, iOS e Web).
class AppStore extends ChangeNotifier {
  Map<String, Product> products = {};
  List<CartItem> cart = [];
  List<Purchase> purchases = [];
  bool ready = false;

  // Usuário da sessão (tela de login)
  String? userName;
  String? userEmail;

  bool get isLoggedIn => userName != null && userName!.trim().isNotEmpty;

  String get firstName {
    final n = (userName ?? '').trim();
    if (n.isEmpty) return 'visitante';
    return n.split(RegExp(r'\s+')).first;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    var ok = false;
    if (raw != null) {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        products = Map.fromEntries((j['products'] as List).map((e) {
          final p =
              Product.fromJson(Map<String, dynamic>.from(e as Map));
          return MapEntry(p.barcode, p);
        }));
        purchases = (j['purchases'] as List)
            .map((e) =>
                Purchase.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        cart = (j['cart'] as List? ?? [])
            .map((e) =>
                CartItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        final u = j['user'] as Map<String, dynamic>?;
        userName = u?['name'] as String?;
        userEmail = u?['email'] as String?;
        ok = true;
      } catch (_) {
        ok = false;
      }
    }
    if (!ok) {
      // Primeira execução: começa vazio, sem dados de exemplo.
      products = {};
      purchases = [];
      cart = [];
      await _persist();
    } else {
      // Migração única: remove dados de exemplo de instalações antigas.
      final hadSeed = purchases.any((p) => p.id.startsWith('seed-')) ||
          products.keys.any(_legacySeedBarcodes.contains);
      if (hadSeed) {
        purchases.removeWhere((p) => p.id.startsWith('seed-'));
        for (final b in _legacySeedBarcodes) {
          products.remove(b);
        }
        cart.removeWhere((i) => _legacySeedBarcodes.contains(i.barcode));
        await _persist();
      }
    }
    ready = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _storageKey,
        jsonEncode({
          'products': products.values.map((p) => p.toJson()).toList(),
          'purchases': purchases.map((p) => p.toJson()).toList(),
          'cart': cart.map((i) => i.toJson()).toList(),
          'user': {'name': userName, 'email': userEmail},
        }));
  }

  // ---------- scanner ----------
  Product? findProduct(String barcode) => products[barcode];

  /// Processa um código lido. Retorna true se o produto já existia
  /// (e foi adicionado automaticamente); false se é novo (abrir modal).
  bool scan(String barcode) {
    if (!products.containsKey(barcode)) return false;
    addToCart(barcode);
    return true;
  }

  /// Cadastra produto novo (via modal) e já adiciona ao carrinho.
  void registerProduct({
    required String barcode,
    required String name,
    required double price,
    required String category,
  }) {
    products[barcode] =
        Product(barcode: barcode, name: name, price: price, category: category);
    addToCart(barcode);
  }

  // ---------- carrinho ----------
  void addToCart(String barcode, [int qty = 1]) {
    final p = products[barcode];
    if (p == null) return;
    final idx = cart.indexWhere((i) => i.barcode == barcode);
    if (idx >= 0) {
      cart[idx].qty += qty;
    } else {
      cart.add(CartItem(
          barcode: barcode,
          name: p.name,
          price: p.price,
          category: p.category,
          qty: qty));
    }
    _persist();
    notifyListeners();
  }

  void setQty(String barcode, int qty) {
    final idx = cart.indexWhere((i) => i.barcode == barcode);
    if (idx < 0) return;
    if (qty <= 0) {
      cart.removeAt(idx);
    } else {
      cart[idx].qty = qty;
    }
    _persist();
    notifyListeners();
  }

  void removeFromCart(String barcode) {
    cart.removeWhere((i) => i.barcode == barcode);
    _persist();
    notifyListeners();
  }

  int get cartCount => cart.fold(0, (s, i) => s + i.qty);
  double get cartTotal => cart.fold(0.0, (s, i) => s + i.subtotal);

  Future<void> checkout() async {
    if (cart.isEmpty) return;
    purchases.add(Purchase(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      items: List.of(cart),
    ));
    cart = [];
    await _persist();
    notifyListeners();
  }

  // ---------- login ----------
  Future<void> login(String name, String email) async {
    userName = name.trim();
    userEmail = email.trim();
    await _persist();
    notifyListeners();
  }

  Future<void> logout() async {
    userName = null;
    userEmail = null;
    await _persist();
    notifyListeners();
  }

  // ---------- comparação entre meses ----------
  List<String> get monthKeys {
    final keys =
        purchases.map((p) => monthKeyOf(p.date)).toSet().toList()..sort();
    return keys;
  }

  String? get currentMonth => monthKeys.isEmpty ? null : monthKeys.last;
  String? get previousMonth =>
      monthKeys.length < 2 ? null : monthKeys[monthKeys.length - 2];

  MonthStats statsFor(String monthKey) {
    double total = 0;
    int count = 0;
    final qty = <String, int>{};
    for (final p in purchases.where((p) => monthKeyOf(p.date) == monthKey)) {
      total += p.total;
      count += p.itemCount;
      for (final i in p.items) {
        qty[i.barcode] = (qty[i.barcode] ?? 0) + i.qty;
      }
    }
    return MonthStats(total: total, itemCount: count, qtyByBarcode: qty);
  }

  String productName(String barcode) {
    final p = products[barcode];
    if (p != null) return p.name;
    for (final pu in purchases) {
      for (final i in pu.items) {
        if (i.barcode == barcode) return i.name;
      }
    }
    return barcode;
  }

  /// Códigos comprados em [cur] mas não em [prev].
  List<String> newInMonth(String cur, String prev) {
    final a = statsFor(cur).qtyByBarcode.keys.toSet();
    final b = statsFor(prev).qtyByBarcode.keys.toSet();
    return a.difference(b).toList();
  }

  /// Códigos comprados em [prev] mas não recomprados em [cur].
  List<String> missingInMonth(String cur, String prev) {
    final a = statsFor(cur).qtyByBarcode.keys.toSet();
    final b = statsFor(prev).qtyByBarcode.keys.toSet();
    return b.difference(a).toList();
  }

  // ---------- dashboard ----------
  Purchase? get mostExpensivePurchase {
    if (purchases.isEmpty) return null;
    var best = purchases.first;
    for (final p in purchases.skip(1)) {
      if (p.total > best.total) best = p;
    }
    return best;
  }

  Map<String, int> get totalQtyByBarcode {
    final qty = <String, int>{};
    for (final p in purchases) {
      for (final i in p.items) {
        qty[i.barcode] = (qty[i.barcode] ?? 0) + i.qty;
      }
    }
    return qty;
  }

  MapEntry<String, int>? get mostBought {
    final q = totalQtyByBarcode;
    if (q.isEmpty) return null;
    return q.entries.reduce((a, b) => b.value > a.value ? b : a);
  }

  MapEntry<String, int>? get leastBought {
    final q = totalQtyByBarcode;
    if (q.isEmpty) return null;
    return q.entries.reduce((a, b) => b.value < a.value ? b : a);
  }

  List<MapEntry<String, int>> get ranking {
    final list = totalQtyByBarcode.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  /// Apaga produtos, carrinho e histórico (mantém o login).
  Future<void> clearAllData() async {
    products = {};
    purchases = [];
    cart = [];
    await _persist();
    notifyListeners();
  }
}
