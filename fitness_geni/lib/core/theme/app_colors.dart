import 'package:flutter/material.dart';

/// App color palette - Clean light theme with vibrant accents
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors - Vibrant teal/cyan
  static const Color primary = Color(0xFF06B6D4); // Cyan
  static const Color primaryLight = Color(0xFF22D3EE);
  static const Color primaryDark = Color(0xFF0891B2);

  // Accent Colors
  static const Color accent = Color(0xFF8B5CF6); // Purple
  static const Color accentLight = Color(0xFFA78BFA);

  // Background Colors - Clean white
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Border & Divider Colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Disabled State
  static const Color disabled = Color(0xFFD1D5DB);
  static const Color disabledText = Color(0xFF9CA3AF);
}
