import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

/// Keeps the profile data in memory (resets when the app is closed).
class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final ValueNotifier<String> name = ValueNotifier('Student Shopper');
  final ValueNotifier<String> address = ValueNotifier('');
  final ValueNotifier<List<Product>> wishlist = ValueNotifier([]);
  final ValueNotifier<List<Product>> lastSeen = ValueNotifier([]);

  /// Reads the name saved at sign up (or falls back to the email name).
  void loadFromSession() {
    final u = Supabase.instance.client.auth.currentUser;
    if (u == null) return;
    final n = (u.userMetadata?['full_name'] as String?) ?? '';
    if (n.isNotEmpty) {
      name.value = n;
    } else if (u.email != null) {
      name.value = u.email!.split('@').first;
    }
  }

  void reset() {
    name.value = 'Student Shopper';
    address.value = '';
    wishlist.value = [];
    lastSeen.value = [];
  }

  bool isWished(Product p) => wishlist.value.any((x) => x.id == p.id);

  void toggleWish(Product p) {
    wishlist.value = isWished(p)
        ? wishlist.value.where((x) => x.id != p.id).toList()
        : [p, ...wishlist.value];
  }

  void markSeen(Product p) {
    final rest = lastSeen.value.where((x) => x.id != p.id).toList();
    lastSeen.value = [p, ...rest].take(20).toList();
  }
}
