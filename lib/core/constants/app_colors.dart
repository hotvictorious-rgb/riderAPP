// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

/// FinTech Executive Obsidian Dark Palette (Moniepoint Business Standard)
/// Tailored for Courier & Rider Operations Terminal
class AppColors {
  // Master Surface Architecture (Moniepoint 3-Tier Obsidian Standard)
  static const Color background = Color(0xFF080D1A);
  static const Color obsidianBg = Color(0xFF080D1A);
  
  static const Color surface = Color(0xFF10192D);
  static const Color obsidianCard = Color(0xFF10192D);
  static const Color carbonSurface = Color(0xFF10192D);
  
  static const Color surfaceElevated = Color(0xFF16233E);
  static const Color obsidianCardElevated = Color(0xFF16233E);
  
  static const Color surfaceBorder = Color(0xFF1E2F52);
  static const Color obsidianBorder = Color(0xFF1E2F52);
  static const Color steelBorder = Color(0xFF1E2F52);
  static const Color borderMuted = Color(0xFF1E2F52);

  // Authority Moniepoint Gold Accents
  static const Color primaryGold = Color(0xFFFFD043);
  static const Color richGold = Color(0xFFFFD043);
  static const Color cyberGold = Color(0xFFFFD043);
  static const Color goldAccent = Color(0xFFD97706);
  static const Color goldLight = Color(0xFFFFE082);

  // Logistics & Verification Accents
  static const Color dispatchEmerald = Color(0xFF10B981);
  static const Color brandEmerald = Color(0xFF10B981);
  static const Color emeraldVerified = Color(0xFF10B981);
  static const Color emeraldBg = Color(0xFF064E3B);

  static const Color dispatchAmber = Color(0xFFFFD043);
  static const Color amberBg = Color(0xFF78350F);

  static const Color urgentRed = Color(0xFFEF4444);
  static const Color crimsonReject = Color(0xFFEF4444);
  static const Color crimsonBg = Color(0xFF7F1D1D);

  static const Color radarBlue = Color(0xFF3B82F6);
  static const Color infoBlueBg = Color(0xFF1E3A8A);

  // Optical Contrast Text Hierarchy
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color frostWhite = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E9BAE);
  static const Color textMuted = Color(0xFF5D6E87);
  static const Color slateMuted = Color(0xFF5D6E87);
  static const Color textDisabled = Color(0xFF3B4858);

  // Sovereign Purple Identity (Brand Anchor)
  static const Color primaryPurple = Color(0xFF5E17EB);
  static const Color darkPurple = Color(0xFF3B0B99);

  // Uyo Road Logistics Corridors
  static const Color oronRoad = Color(0xFFFFD043);
  static const Color ikotEkpeneRoad = Color(0xFF3B82F6);
  static const Color nwanibaRoad = Color(0xFF10B981);
  static const Color akaRoad = Color(0xFF8B5CF6);
  static const Color abakRoad = Color(0xFFEC4899);
  static const Color udoUdomaRoad = Color(0xFF14B8A6);

  // Executive Linear Gradients (Subtle Dark Depth)
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF16233E), Color(0xFF10192D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF16233E), Color(0xFF0D1527)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD043), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF5E17EB), Color(0xFF3B0B99)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
