import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class CartItem {
  final Product product;
  final String? color;
  final String? size;
  int qty;
  CartItem({required this.product, this.color, this.size, this.qty = 1});
}

class CartService {
  CartService._();
  static final CartService instance = CartService._();

  final ValueNotifier<List<CartItem>> items = ValueNotifier([]);

  int get count => items.value.fold(0, (s, i) => s + i.qty);
  double get total =>
      items.value.fold(0.0, (s, i) => s + i.product.price * i.qty);

  void add(Product p, {String? color, String? size, int qty = 1}) {
    final list = [...items.value];
    final idx = list.indexWhere(
        (i) => i.product.id == p.id && i.color == color && i.size == size);
    if (idx >= 0) {
      list[idx].qty += qty;
    } else {
      list.add(CartItem(product: p, color: color, size: size, qty: qty));
    }
    items.value = list;
  }

  void setQty(CartItem item, int qty) {
    if (qty < 1) return;
    item.qty = qty;
    items.value = [...items.value];
  }

  void remove(CartItem item) {
    items.value = items.value.where((i) => i != item).toList();
  }

  void clear() => items.value = [];
}
