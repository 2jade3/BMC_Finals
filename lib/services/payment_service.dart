import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import 'cart_service.dart';

class PaymentService {
  static final _db = Supabase.instance.client;

  static Future<List<Product>> fetchProducts() async {
    final rows = await _db.from('products').select().order('created_at');
    return (rows as List).map((e) => Product.fromMap(e)).toList();
  }

  /// Calls the create-invoice Edge Function. Returns {order_id, invoice_url}.
  static Future<Map<String, dynamic>> createInvoice(List<CartItem> cart) async {
    final res = await _db.functions.invoke('create-invoice', body: {
      'items': [
        for (final c in cart)
          {
            'product_id': c.product.id,
            'quantity': c.qty,
            'color': c.color,
            'size': c.size,
          }
      ],
    });
    final data = Map<String, dynamic>.from(res.data as Map);
    if (data['invoice_url'] == null) {
      throw Exception(data['error'] ?? 'Could not create invoice');
    }
    return data;
  }

  static Future<String?> fetchStatus(String orderId) async {
    final row = await _db
        .from('orders')
        .select('status')
        .eq('id', orderId)
        .maybeSingle();
    return row?['status'] as String?;
  }

  static Future<List<Map<String, dynamic>>> fetchOrders() async {
    final rows =
        await _db.from('orders').select().order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows as List);
  }
}
