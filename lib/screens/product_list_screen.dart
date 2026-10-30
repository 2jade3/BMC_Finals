import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../services/payment_service.dart';
import '../widgets/product_image.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _future;
  String _query = '';
  String _category = 'All';

  static const _tiles = [
    ['All', 'Best Offer'],
    ['Shoes', 'Shoes'],
    ['Women Dress', 'Women Dress'],
    ['Men Clothes', 'Men Clothes'],
  ];

  @override
  void initState() {
    super.initState();
    _future = PaymentService.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _header(context),
      Expanded(
        child: FutureBuilder<List<Product>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                  child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Error: ${snap.error}'),
              ));
            }
            final items = snap.data!
                .where((p) =>
                    (_category == 'All' || p.category == _category) &&
                    p.name.toLowerCase().contains(_query.toLowerCase()))
                .toList();
            return CustomScrollView(slivers: [
              SliverToBoxAdapter(child: _categoryBand()),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: Text('Super recommendation',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _card(items[i]),
                    childCount: items.length,
                  ),
                ),
              ),
            ]);
          },
        ),
      ),
    ]);
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppConfig.navy,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 14, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Expanded(
            child: Text('Find the best\noutfit for you.',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.25)),
          ),
          _bagButton(context),
        ]),
        const SizedBox(height: 14),
        TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: 'Find a product...',
            hintStyle: const TextStyle(fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.search, size: 20),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none),
          ),
        ),
      ]),
    );
  }

  Widget _bagButton(BuildContext context) {
    return ValueListenableBuilder<List<CartItem>>(
      valueListenable: CartService.instance.items,
      builder: (_, __, ___) {
        final n = CartService.instance.count;
        return InkWell(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CartScreen())),
          child: Stack(clipBehavior: Clip.none, children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppConfig.navyLight,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.shopping_bag_outlined,
                  color: Colors.white, size: 22),
            ),
            if (n > 0)
              Positioned(
                right: -4,
                top: -4,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: AppConfig.star,
                  child: Text('$n',
                      style:
                          const TextStyle(fontSize: 10, color: Colors.black)),
                ),
              ),
          ]),
        );
      },
    );
  }

  Widget _categoryBand() {
    return Container(
      color: AppConfig.navy,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(children: [
        Row(children: [
          const Expanded(
            child: Text('Category',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          GestureDetector(
            onTap: () => setState(() => _category = 'All'),
            child: const Text('View More',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ]),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          for (final t in _tiles) _tile(t[0], t[1]),
        ]),
      ]),
    );
  }

  Widget _tile(String value, String label) {
    final selected = _category == value;
    return GestureDetector(
      onTap: () => setState(() => _category = value),
      child: Column(children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: AppConfig.navyLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? AppConfig.star : Colors.white24,
                width: selected ? 2 : 1),
          ),
          child: Icon(categoryIcon(value), color: Colors.white, size: 26),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 10)),
      ]),
    );
  }

  Widget _card(Product p) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p))),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Stack(children: [
              Positioned.fill(child: ProductImage(product: p)),
              Positioned(left: 6, top: 6, child: RatingBadge(p.rating)),
            ]),
          ),
          const SizedBox(height: 8),
          Text(p.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 2),
          Text(formatPeso(p.price),
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(p.store,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ]),
      ),
    );
  }
}
