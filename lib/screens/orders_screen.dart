import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/payment_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = PaymentService.fetchOrders();
  }

  Color _color(String s) => s == 'PAID'
      ? Colors.green
      : s == 'EXPIRED'
          ? Colors.red
          : Colors.orange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConfig.navy,
        foregroundColor: Colors.white,
        title: const Text('Order History'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = PaymentService.fetchOrders());
          await _future;
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
            final orders = snap.data!;
            if (orders.isEmpty) {
              return ListView(children: const [
                SizedBox(height: 200),
                Center(child: Text('No orders yet')),
              ]);
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              itemBuilder: (_, i) {
                final o = orders[i];
                final status = o['status'] as String;
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: const Icon(Icons.shopping_bag_outlined,
                        color: AppConfig.navy),
                    title: Text(o['product_name']),
                    subtitle: Text(
                        'Qty ${o['quantity']} • ${formatPeso(o['amount'] as num)}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _color(status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(status,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
