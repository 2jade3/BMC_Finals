import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/product_model.dart';
import '../widgets/product_image.dart';
import 'product_detail_screen.dart';

/// Used for both Wishlist and Last seen.
class ProductCollectionScreen extends StatelessWidget {
  final String title;
  final String emptyText;
  final ValueNotifier<List<Product>> source;

  const ProductCollectionScreen({
    super.key,
    required this.title,
    required this.emptyText,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConfig.navy,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: ValueListenableBuilder<List<Product>>(
        valueListenable: source,
        builder: (context, list, _) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(emptyText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey)),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final p = list[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: SizedBox(
                      width: 56,
                      height: 56,
                      child: ProductImage(product: p, iconSize: 28)),
                  title: Text(p.name),
                  subtitle: Text(formatPeso(p.price),
                      style: const TextStyle(
                          color: AppConfig.navy, fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: p))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
