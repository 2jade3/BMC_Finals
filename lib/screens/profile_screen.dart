import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../services/cart_service.dart';
import '../services/user_service.dart';
import 'orders_screen.dart';
import 'product_collection_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  UserService get _u => UserService.instance;

  Future<String?> _askText(BuildContext context, String title, String initial,
      {String hint = ''}) {
    final c = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: c,
          autofocus: true,
          maxLines: null,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppConfig.navy),
              onPressed: () => Navigator.pop(ctx, c.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _openPreferences(BuildContext context) {
    bool notif = true;
    bool promo = false;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Preferences',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: const Text('Order notifications'),
            value: notif,
            activeThumbColor: AppConfig.navy,
            onChanged: (v) => setS(() => notif = v),
          ),
          SwitchListTile(
            title: const Text('Promo & marketing info'),
            value: promo,
            activeThumbColor: AppConfig.navy,
            onChanged: (v) => setS(() => promo = v),
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: double.infinity,
        color: AppConfig.navy,
        padding: EdgeInsets.fromLTRB(
            20, MediaQuery.of(context).padding.top + 24, 20, 24),
        child: Column(children: [
          const CircleAvatar(
              radius: 36,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 44, color: AppConfig.navy)),
          const SizedBox(height: 10),
          ValueListenableBuilder<String>(
            valueListenable: _u.name,
            builder: (_, name, __) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.edit, color: Colors.white70, size: 16),
                  onPressed: () async {
                    final v = await _askText(context, 'Edit name', name);
                    if (v != null && v.isNotEmpty) _u.name.value = v;
                  },
                ),
              ],
            ),
          ),
          Text(Supabase.instance.client.auth.currentUser?.email ?? '',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ),
      Expanded(
        child: ListenableBuilder(
          listenable: Listenable.merge([_u.wishlist, _u.lastSeen, _u.address]),
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _section('ACCOUNT'),
              _tile(
                Icons.favorite_border,
                'Wishlist',
                subtitle: '${_u.wishlist.value.length} items',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProductCollectionScreen(
                              title: 'Wishlist',
                              emptyText:
                                  'Nothing here yet.\nTap the heart on a product to save it.',
                              source: _u.wishlist,
                            ))),
              ),
              _tile(
                Icons.visibility_outlined,
                'Last seen',
                subtitle: '${_u.lastSeen.value.length} items',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProductCollectionScreen(
                              title: 'Last seen',
                              emptyText: 'Products you open will show up here.',
                              source: _u.lastSeen,
                            ))),
              ),
              _tile(
                Icons.receipt_long,
                'Orders',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const OrdersScreen())),
              ),
              _tile(
                Icons.account_balance_wallet_outlined,
                'Wallet',
                onTap: () => showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Wallet'),
                    content: const Text(
                        'Balance: ₱0.00\n\nPayments are made at checkout through Xendit (GCash, Maya, cards).'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('OK')),
                    ],
                  ),
                ),
              ),
              _tile(
                Icons.location_on_outlined,
                'Addresses',
                subtitle: _u.address.value.isEmpty
                    ? 'Tap to add your shipping address'
                    : _u.address.value,
                onTap: () async {
                  final v = await _askText(
                      context, 'Shipping address', _u.address.value,
                      hint: 'Street, barangay, city');
                  if (v != null) _u.address.value = v;
                },
              ),
              _section('SETTINGS'),
              _tile(Icons.settings_outlined, 'Preferences',
                  onTap: () => _openPreferences(context)),
              _tile(Icons.logout, 'Log out', onTap: () async {
                CartService.instance.clear();
                _u.reset();
                await Supabase.instance.client.auth.signOut();
              }),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: Text(t, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      );

  Widget _tile(IconData icon, String label,
      {String? subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: AppConfig.navy),
        title: Text(label),
        subtitle: subtitle == null
            ? null
            : Text(subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
