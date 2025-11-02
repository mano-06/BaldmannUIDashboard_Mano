import 'package:flutter/material.dart';

class AppTheme {
  static const _seed = Color(0xFF2A7DE1);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light),
        typography: Typography.material2021(platform: TargetPlatform.android),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark),
        typography: Typography.material2021(platform: TargetPlatform.android),
      );
}
