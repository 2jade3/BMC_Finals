import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../services/user_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _signUp = false;
  bool _busy = false;
  bool _hide = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _msg(String t, {Color? color}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(t), backgroundColor: color));
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final pass = _pass.text;
    if (!email.contains('@') || pass.length < 6) {
      _msg('Enter a valid email and a password of at least 6 characters.');
      return;
    }
    setState(() => _busy = true);
    try {
      final auth = Supabase.instance.client.auth;
      if (_signUp) {
        final res = await auth.signUp(
          email: email,
          password: pass,
          data: {'full_name': _name.text.trim()},
        );
        if (res.session == null) {
          // Email confirmation is ON in Supabase
          _msg('Account created. Check your email to confirm, then sign in.',
              color: Colors.green);
          if (mounted) setState(() => _signUp = false);
        } else {
          UserService.instance.loadFromSession();
        }
      } else {
        await auth.signInWithPassword(email: email, password: pass);
        UserService.instance.loadFromSession();
      }
    } on AuthException catch (e) {
      _msg(e.message, color: Colors.red);
    } catch (e) {
      _msg('Error: $e', color: Colors.red);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  InputDecoration _dec(String hint, IconData icon, {Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppConfig.bg,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(children: [
                            ClipOval(
                child: Image.asset('assets/images/logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Kicks & Co.',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppConfig.navy)),
              const SizedBox(height: 4),
              Text(
                  _signUp
                      ? 'Create your account'
                      : 'Welcome back, sign in to continue',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              if (_signUp) ...[
                TextField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: _dec('Full name', Icons.person_outline)),
                const SizedBox(height: 12),
              ],
              TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _dec('Email', Icons.mail_outline)),
              const SizedBox(height: 12),
              TextField(
                controller: _pass,
                obscureText: _hide,
                onSubmitted: (_) => _busy ? null : _submit(),
                decoration: _dec(
                  'Password (min. 6 characters)',
                  Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                        _hide ? Icons.visibility_off : Icons.visibility,
                        size: 20),
                    onPressed: () => setState(() => _hide = !_hide),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: AppConfig.navy,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(_signUp ? 'Sign up' : 'Sign in'),
                ),
              ),
            
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(_signUp
                    ? 'Already have an account? '
                    : "Don't have an account? "),
                GestureDetector(
                  onTap: () => setState(() => _signUp = !_signUp),
                  child: Text(_signUp ? 'Sign in' : 'Sign up',
                      style: const TextStyle(
                          color: AppConfig.navy,
                          fontWeight: FontWeight.bold)),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
