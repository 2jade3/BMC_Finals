import 'package:flutter/material.dart';
import '../config/app_config.dart';
import 'orders_screen.dart';
import 'product_list_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    // Pages are rebuilt on tab change so Orders always reloads fresh data.
    final pages = [
      const ProductListScreen(),
      const OrdersScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: pages[_i],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _i,
        onTap: (v) => setState(() => _i = v),
        selectedItemColor: AppConfig.navy,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
