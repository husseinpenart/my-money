import 'package:flutter/material.dart';

/// Central color palette for the auth flow (login / register / success).
class AppColors {
  AppColors._();

  static const Color blue1 = Color(0xFF1E3A8A);
  static const Color blue2 = Color(0xFF2563EB);
  static const Color blue3 = Color(0xFF3B82F6);

  static const Color purple1 = Color(0xFF3B0764);
  static const Color purple2 = Color(0xFF6D28D9);
  static const Color purple3 = Color(0xFF9333EA);

  static const Color green1 = Color(0xFF059669);
  static const Color green2 = Color(0xFF10B981);

  static const Color ink = Color(0xFF1F2430);
  static const Color muted = Color(0xFF8B93A7);
  static const Color line = Color(0xFFE7EAF1);
  static const Color fieldBg = Color(0xFFEEF1F6);
  static const Color fieldBgFocus = Color(0xFFE4E9F5);

  static const Color danger = Color(0xFFE0455F);
  static const Color warn = Color(0xFFF0A53D);
  static const Color ok = Color(0xFF20B876);

  static const List<Color> blueGradient = [blue1, blue2, blue3];
  static const List<Color> purpleGradient = [purple1, purple2, purple3];
  static const List<Color> greenGradient = [green1, green2];
}
