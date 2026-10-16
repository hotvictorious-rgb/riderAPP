// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Brand Sovereign Identity
  static const Color primaryPurple = Color(0xFF5E17EB);
  static const Color darkPurple = Color(0xFF3B0B99);
  static const Color richGold = Color(0xFFFFD700);
  static const Color goldAccent = Color(0xFFFFA000);

  // Dispatch & Logistics Accents
  static const Color dispatchEmerald = Color(0xFF10B981);
  static const Color dispatchAmber = Color(0xFFF59E0B);
  static const Color urgentRed = Color(0xFFEF4444);
  static const Color radarBlue = Color(0xFF3B82F6);

  // FinTech Obsidian Dark Theme
  static const Color obsidianBg = Color(0xFF080414);
  static const Color obsidianCard = Color(0xFF13092A);
  static const Color obsidianCardElevated = Color(0xFF1B0E3B);
  static const Color obsidianBorder = Color(0xFF2A1654);

  // Surface & Text
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // Gradient Accents
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [primaryPurple, darkPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [dispatchEmerald, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [richGold, goldAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
