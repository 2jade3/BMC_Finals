import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/cart_service.dart';
import '../services/payment_service.dart';
import '../widgets/product_image.dart';
import 'xendit_webview_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _busy = false;
  final _cart = CartService.instance;

  Future<void> _checkout() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _busy = true);
    try {
      final inv = await PaymentService.createInvoice(_cart.items.value);
      if (!mounted) return;
      setState(() => _busy = false);

      await nav.push(MaterialPageRoute(
          builder: (_) => XenditWebViewScreen(url: inv['invoice_url'])));

      // Webhook may take a moment, so check a few times
      String? status;
      for (var i = 0; i < 6; i++) {
        status = await PaymentService.fetchStatus(inv['order_id']);
        if (status == 'PAID') break;
        await Future.delayed(const Duration(seconds: 1));
      }
      if (status == 'PAID') {
        _cart.clear();
        messenger.showSnackBar(const SnackBar(
            content: Text('Payment Verified! Your order is PAID.'),
            backgroundColor: Colors.green));
        if (mounted) nav.pop();
      } else {
        messenger.showSnackBar(const SnackBar(
            content: Text('Payment not confirmed yet. Check Orders tab.'),
            backgroundColor: Colors.orange));
      }
    } catch (e) {
      if (mounted) setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(
          content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConfig.navy,
        foregroundColor: Colors.white,
        title: const Text('My Cart'),
      ),
      body: Stack(children: [
        ValueListenableBuilder<List<CartItem>>(
          valueListenable: _cart.items,
          builder: (context, items, _) {
            if (items.isEmpty) return _empty(context);
            return Column(children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _row(items[i]),
                ),
              ),
              _summary(),
            ]);
          },
        ),
        if (_busy)
          Container(
              color: Colors.black38,
              child: const Center(child: CircularProgressIndicator())),
      ]),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.shopping_bag, size: 90, color: AppConfig.navy),
          const SizedBox(height: 12),
          const Text('Empty Cart 😟',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text(
              'Go to home and explore our interesting products and add to cart',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppConfig.navy),
            onPressed: () => Navigator.pop(context),
            child: const Text('Start Shopping'),
          ),
        ]),
      ),
    );
  }

  Widget _row(CartItem c) {
    final variant = [c.color, c.size].whereType<String>().join(' • ');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        SizedBox(
            width: 70,
            height: 70,
            child: ProductImage(product: c.product, iconSize: 32)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            if (variant.isNotEmpty)
              Text(variant,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(formatPeso(c.product.price * c.qty),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppConfig.navy)),
          ]),
        ),
        Column(children: [
          Row(children: [
            _qtyBtn(Icons.remove, () => _cart.setQty(c, c.qty - 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('${c.qty}'),
            ),
            _qtyBtn(Icons.add, () => _cart.setQty(c, c.qty + 1)),
          ]),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
            onPressed: () => _cart.remove(c),
          ),
        ]),
      ]),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, size: 16),
        ),
      );

  Widget _summary() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Shipping', style: TextStyle(color: Colors.grey)),
            const Text('Free delivery', style: TextStyle(color: Colors.green)),
          ]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Subtotal', style: TextStyle(color: Colors.grey)),
            Text(formatPeso(_cart.total),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: AppConfig.navy,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: _busy ? null : _checkout,
              child: Text('Checkout   |   ${formatPeso(_cart.total)}'),
            ),
          ),
        ]),
      ),
    );
  }
}
