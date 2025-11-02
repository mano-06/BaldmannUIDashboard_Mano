import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baldmann_ui_dashboard/viewmodels/auth/forgot_password_provider.dart';
import 'package:go_router/go_router.dart';

class AuthForgotPasswordScreen extends ConsumerStatefulWidget {
  const AuthForgotPasswordScreen({super.key});

  @override
  ConsumerState<AuthForgotPasswordScreen> createState() => _AuthForgotPasswordScreenState();
}

class _AuthForgotPasswordScreenState extends ConsumerState<AuthForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordProvider);
    final notifier = ref.read(forgotPasswordProvider.notifier);
    ref.listen(forgotPasswordProvider, (prev, next) {
      if (next.stage == ForgotStage.done) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(const SnackBar(content: Text('Password changed successfully'), behavior: SnackBarBehavior.floating));
        context.go('/login');
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(next.error!), behavior: SnackBarBehavior.floating));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: switch (state.stage) {
                ForgotStage.email => _EmailStage(
                    key: const ValueKey('email'),
                    controller: _emailCtrl,
                    loading: state.loading,
                    onSend: () async => notifier.sendOtp(_emailCtrl.text),
                  ),
                ForgotStage.otp => _OtpStage(
                    key: const ValueKey('otp'),
                    emailMasked: state.email,
                    controller: _otpCtrl,
                    loading: state.loading,
                    onVerify: () async => notifier.verifyOtp(_otpCtrl.text),
                    onBack: notifier.restart,
                  ),
                ForgotStage.reset => _ResetStage(
                    key: const ValueKey('reset'),
                    controller: _passCtrl,
                    loading: state.loading,
                    onReset: () async => notifier.resetPassword(_passCtrl.text),
                  ),
                ForgotStage.done => const SizedBox.shrink(),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailStage extends StatelessWidget {
  const _EmailStage({super.key, required this.controller, required this.loading, required this.onSend});
  final TextEditingController controller;
  final bool loading;
  final VoidCallback onSend;
  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enter your email to receive an OTP', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.email_outlined), labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: loading ? null : onSend,
          icon: const Icon(Icons.send_outlined),
          label: loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Send OTP'),
        ),
      ],
    );
  }
}

class _OtpStage extends StatelessWidget {
  const _OtpStage({super.key, required this.emailMasked, required this.controller, required this.loading, required this.onVerify, required this.onBack});
  final String emailMasked;
  final TextEditingController controller;
  final bool loading;
  final VoidCallback onVerify;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('OTP sent to $emailMasked', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.numbers), labelText: '6-digit OTP'),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton.icon(onPressed: loading ? null : onBack, icon: const Icon(Icons.arrow_back), label: const Text('Back')),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: loading ? null : onVerify,
              icon: const Icon(Icons.verified),
              label: loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Verify'),
            ),
          ],
        )
      ],
    );
  }
}

class _ResetStage extends StatelessWidget {
  const _ResetStage({super.key, required this.controller, required this.loading, required this.onReset});
  final TextEditingController controller;
  final bool loading;
  final VoidCallback onReset;
  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Set a new password', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline), labelText: 'New password'),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: loading ? null : onReset,
          icon: const Icon(Icons.save_outlined),
          label: loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Change Password'),
        ),
      ],
    );
  }
}
