import 'package:flutter/material.dart';

/// App color palette - Calm, health-focused aesthetics
/// Soft greens and neutral tones for a trustworthy, simple feel
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors - Soft Greens
  static const Color primary = Color(0xFF6BCF8E);
  static const Color primaryLight = Color(0xFFA8E6B8);
  static const Color primaryDark = Color(0xFF4CAF6E);

  // Neutral Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F4);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textTertiary = Color(0xFFA0AEC0);

  // Semantic Colors (subtle, not aggressive)
  static const Color success = Color(0xFF6BCF8E);
  static const Color error = Color(0xFFE57373);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF64B5F6);

  // Border & Divider Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEDF2F7);

  // Disabled State
  static const Color disabled = Color(0xFFCBD5E0);
  static const Color disabledText = Color(0xFFA0AEC0);
}
