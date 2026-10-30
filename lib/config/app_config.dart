import 'package:flutter/material.dart';

class AppConfig {
  // Bare project URL ONLY, e.g. https://abcdxyz.supabase.co  (no /rest/v1, no trailing /)
  static const String supabaseUrl = 'https://woaconpgthwrsmlmlqmc.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndvYWNvbnBndGh3cnNtbG1scW1jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTMyNjAxNzEsImV4cCI6MjEwODgzNjE3MX0.YvlolmoQD3or7_nXE29KAmjHyaUbzmsiD5ZlPZPULPk';
  

  static const Color navy = Color(0xFF1F1B6B);
  static const Color navyLight = Color(0xFF2D2A85);
  static const Color bg = Color(0xFFF4F5FA);
  static const Color star = Color(0xFFFFC107);
}

String formatPeso(num v) {
  final s = v.toStringAsFixed(2);
  final parts = s.split('.');
  final whole = parts[0]
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return '₱$whole.${parts[1]}';
}

IconData categoryIcon(String c) {
  switch (c) {
    case 'Men Shoes':
    case 'Women Shoes':
      return Icons.directions_walk;
    case 'Women Dress':
      return Icons.woman;
    case 'Men Clothes':
      return Icons.checkroom;
    default:
      return Icons.local_offer;
  }
}

Color colorFromName(String n) {
  switch (n.toLowerCase()) {
    case 'black':
      return Colors.black;
    case 'grey':
    case 'gray':
      return Colors.blueGrey.shade200;
    case 'pink':
      return Colors.pink.shade200;
    case 'white':
      return Colors.white;
    case 'blue':
      return Colors.blue.shade700;
    case 'red':
      return Colors.red.shade600;
    default:
      return Colors.brown.shade300;
  }
}