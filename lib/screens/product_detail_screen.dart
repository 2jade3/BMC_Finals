import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../services/user_service.dart';
import '../widgets/product_image.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _color;
  String? _size;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _color = p.colors.isNotEmpty ? p.colors.first : null;
    _size = p.sizes.isNotEmpty ? p.sizes.last : null;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => UserService.instance.markSeen(p));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppConfig.navy,
        foregroundColor: Colors.white,
        title: Text(p.store, style: const TextStyle(fontSize: 14)),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<List<Product>>(
            valueListenable: UserService.instance.wishlist,
            builder: (_, __, ___) => IconButton(
              icon: Icon(UserService.instance.isWished(p)
                  ? Icons.favorite
                  : Icons.favorite_border),
              onPressed: () => UserService.instance.toggleWish(p),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        SizedBox(height: 240, child: ProductImage(product: p, iconSize: 110)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: Text(p.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          RatingBadge(p.rating),
        ]),
        const SizedBox(height: 4),
        Text(formatPeso(p.price),
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConfig.navy)),
        const SizedBox(height: 8),
        Text(p.description,
            style: const TextStyle(color: Colors.black54, fontSize: 13)),
        if (p.colors.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Text('Color', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(spacing: 12, children: [
            for (final c in p.colors)
              GestureDetector(
                onTap: () => setState(() => _color = c),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colorFromName(c),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _color == c ? AppConfig.navy : Colors.black26,
                        width: _color == c ? 3 : 1),
                  ),
                ),
              ),
          ]),
        ],
        if (p.sizes.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Text('Size', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(spacing: 12, children: [
            for (final s in p.sizes)
              GestureDetector(
                onTap: () => setState(() => _size = s),
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _size == s ? AppConfig.navy : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black26),
                  ),
                  child: Text(s,
                      style: TextStyle(
                          fontSize: 12,
                          color: _size == s ? Colors.white : Colors.black87)),
                ),
              ),
          ]),
        ],
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                  color: AppConfig.navy,
                  borderRadius: BorderRadius.circular(10)),
              child:
                  const Icon(Icons.chat_bubble_outline, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: AppConfig.navy,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    CartService.instance.add(p, color: _color, size: _size);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to cart')),
                    );
                  },
                  child: const Text('Add To Cart'),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
