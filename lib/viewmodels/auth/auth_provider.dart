import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthController extends Notifier<AuthStatus> {
  @override
  AuthStatus build() {
    Future.microtask(() => state = AuthStatus.unauthenticated);
    return AuthStatus.unknown;
  }

  static const _dummyEmail = 'admin@baldmann.com';
  static const _dummyPassword = 'Admin@123';

  Future<bool> loginWithCredentials(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final ok = email.trim().toLowerCase() == _dummyEmail && password == _dummyPassword;
    if (ok) state = AuthStatus.authenticated; else state = AuthStatus.unauthenticated;
    return ok;
  }

  Future<bool> biometricLogin() async {
    await Future.delayed(const Duration(milliseconds: 700));
    state = AuthStatus.authenticated;
    return true;
  }

  Future<bool> registerUser(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    state = AuthStatus.authenticated;
    return true;
  }

  Future<void> logout() async {
    state = AuthStatus.unauthenticated;
  }
}

final authProvider = NotifierProvider<AuthController, AuthStatus>(AuthController.new);
