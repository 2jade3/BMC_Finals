class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String store;
  final double rating;
  final String? imageUrl;
  final List<String> colors;
  final List<String> sizes;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.store,
    required this.rating,
    this.imageUrl,
    this.colors = const [],
    this.sizes = const [],
  });

  factory Product.fromMap(Map<String, dynamic> m) => Product(
        id: m['id'] as String,
        name: m['name'] as String,
        description: (m['description'] ?? '') as String,
        price: (m['price'] as num).toDouble(),
        category: (m['category'] ?? 'General') as String,
        store: (m['store'] ?? 'Student Shop') as String,
        rating: ((m['rating'] ?? 4.0) as num).toDouble(),
        imageUrl: m['image_url'] as String?,
        colors: List<String>.from(m['colors'] ?? const []),
        sizes: List<String>.from(m['sizes'] ?? const []),
      );
}
