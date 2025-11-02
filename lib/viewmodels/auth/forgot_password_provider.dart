import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ForgotStage { email, otp, reset, done }

class ForgotState {
  final ForgotStage stage;
  final String email;
  final bool loading;
  final String? error;
  final String _serverOtp; // stored server-side simulated

  const ForgotState({
    required this.stage,
    required this.email,
    required this.loading,
    required this.error,
    required String serverOtp,
  }) : _serverOtp = serverOtp;

  String get serverOtp => _serverOtp;

  ForgotState copyWith({ForgotStage? stage, String? email, bool? loading, String? error, String? serverOtp}) => ForgotState(
        stage: stage ?? this.stage,
        email: email ?? this.email,
        loading: loading ?? this.loading,
        error: error,
        serverOtp: serverOtp ?? _serverOtp,
      );
}

class ForgotPasswordController extends Notifier<ForgotState> {
  @override
  ForgotState build() => const ForgotState(stage: ForgotStage.email, email: '', loading: false, error: null, serverOtp: '');

  Future<void> sendOtp(String email) async {
    state = state.copyWith(loading: true, error: null);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    // Dummy OTP for development/testing
    const code = '123456';
    // In a real app, send email here
    state = state.copyWith(stage: ForgotStage.otp, email: email, loading: false, serverOtp: code);
  }

  Future<void> verifyOtp(String input) async {
    state = state.copyWith(loading: true, error: null);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (input == state.serverOtp) {
      state = state.copyWith(stage: ForgotStage.reset, loading: false);
    } else {
      state = state.copyWith(loading: false, error: 'Invalid OTP');
    }
  }

  Future<void> resetPassword(String newPassword) async {
    state = state.copyWith(loading: true, error: null);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    // In a real app, update password for state.email
    state = state.copyWith(stage: ForgotStage.done, loading: false);
  }

  void restart() {
    state = const ForgotState(stage: ForgotStage.email, email: '', loading: false, error: null, serverOtp: '');
  }
}

final forgotPasswordProvider = NotifierProvider<ForgotPasswordController, ForgotState>(ForgotPasswordController.new);
