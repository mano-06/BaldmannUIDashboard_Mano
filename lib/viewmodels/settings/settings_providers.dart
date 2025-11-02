import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final textScaleProvider = StateProvider<double>((ref) => 1.0);
final primaryColorProvider = StateProvider<Color>((ref) => Colors.blue);
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
final languageProvider = StateProvider<String>((ref) => 'en');

class ProfileData {
  final String name;
  final String email;
  const ProfileData({required this.name, required this.email});

  ProfileData copyWith({String? name, String? email}) =>
      ProfileData(name: name ?? this.name, email: email ?? this.email);
}

final profileProvider = StateProvider<ProfileData>((ref) => const ProfileData(name: 'Admin', email: 'admin@baldmann.com'));
