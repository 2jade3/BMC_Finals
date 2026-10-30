import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';
import 'screens/auth_screen.dart';
import 'screens/main_shell.dart';
import 'services/user_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  UserService.instance.loadFromSession();
  runApp(const StudentShopApp());
}

class StudentShopApp extends StatelessWidget {
  const StudentShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppConfig.navy),
        scaffoldBackgroundColor: AppConfig.bg,
      ),
      // Keeps the app phone-sized when previewed in Chrome
      builder: (context, child) => Container(
        color: const Color(0xFFE8E8EE),
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: child,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

/// Shows the login page until the user is signed in.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snap) {
        final session = snap.data?.session ??
            Supabase.instance.client.auth.currentSession;
        return session != null ? const MainShell() : const AuthScreen();
      },
    );
  }
}
