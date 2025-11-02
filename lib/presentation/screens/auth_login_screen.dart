import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:baldmann_ui_dashboard/viewmodels/auth/auth_provider.dart';

class AuthLoginScreen extends ConsumerStatefulWidget {
  const AuthLoginScreen({super.key});

  @override
  ConsumerState<AuthLoginScreen> createState() => _AuthLoginScreenState();
}

class _AuthLoginScreenState extends ConsumerState<AuthLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'admin@baldmann.com');
  final _pwdCtrl = TextEditingController(text: 'Admin@123');
  bool _submitting = false;
  bool _error = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = false;
    });
    final ok = await ref.read(authProvider.notifier).loginWithCredentials(
          _emailCtrl.text,
          _pwdCtrl.text,
        );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _error = !ok;
    });
    if (ok) context.go('/dashboard');
  }

  Future<void> _biometric() async {
    setState(() {
      _submitting = true;
      _error = false;
    });
    final ok = await ref.read(authProvider.notifier).biometricLogin();
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Welcome back', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Use dummy credentials or biometric to continue', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pwdCtrl,
                    decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                    obscureText: true,
                    validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot'),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _error
                        ? Row(
                            key: const ValueKey('error'),
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 8),
                              Text('Invalid credentials', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red)),
                            ],
                          )
                        : const SizedBox.shrink(key: ValueKey('noerror')),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.login),
                    label: const Text('Sign in'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _submitting ? null : _biometric,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Use Biometric (demo)'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text("Don't have an account? Register"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
