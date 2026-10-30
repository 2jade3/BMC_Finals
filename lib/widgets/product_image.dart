import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/product_model.dart';

class ProductImage extends StatelessWidget {
  final Product product;
  final double iconSize;
  const ProductImage({super.key, required this.product, this.iconSize = 56});

  @override
  Widget build(BuildContext context) {
    final fallback = Center(
      child: Icon(categoryIcon(product.category),
          size: iconSize, color: const Color(0xFFB9B7E0)),
    );
    final url = product.imageUrl;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: const Color(0xFFF1F1F6),
          borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: (url == null || url.isEmpty)
          ? fallback
          : Image.network(url,
              fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback),
    );
  }
}

class RatingBadge extends StatelessWidget {
  final double rating;
  const RatingBadge(this.rating, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.star, size: 11, color: AppConfig.star),
        const SizedBox(width: 2),
        Text(rating.toStringAsFixed(1),
            style: const TextStyle(color: Colors.white, fontSize: 11)),
      ]),
    );
  }
}
