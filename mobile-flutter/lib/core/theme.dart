import 'package:flutter/material.dart';

/// BantAI design system.
///
/// Palette (as specified):
///   - Primary:   0xFFF5F5DC  (beige — backgrounds, cards)
///   - Secondary: 0xFFF4A460  (sandy brown — secondary actions, highlights)
///   - Accent:    0xFFE35336  (terracotta red — primary actions, alerts, "Pending"/urgent)
///   - Deep:      0xFFA0522D  (sienna — headings, borders, high-emphasis text)
///
/// Composition rules used throughout the app (kept consistent everywhere,
/// not just declared here):
///   1. Beige is the canvas — it's never used for small text or icons at
///      body-copy size (fails contrast); it's backgrounds and large surfaces.
///   2. Sienna (A0522D) is the primary text/heading color on beige, not pure
///      black — it keeps the palette cohesive instead of looking bolted-on.
///   3. Terracotta (E35336) is reserved for one thing at a time: the single
///      primary action on a screen, or a genuine alert/urgent state. It is
///      never used decoratively — if everything is urgent, nothing is.
///   4. Sandy brown (F4A460) is for secondary emphasis: selected tabs,
///      secondary buttons, badges that aren't alerts.
///   5. Spacing follows an 8px scale (AppSpacing) — no ad-hoc padding values.
///   6. Corners are consistently rounded at 12px (cards) / 8px (inputs,
///      chips) — never mixed within the same screen.
class AppColors {
  static const primary = Color(0xFFF5F5DC); // beige
  static const secondary = Color(0xFFF4A460); // sandy brown
  static const accent = Color(0xFFE35336); // terracotta red
  static const deep = Color(0xFFA0522D); // sienna

  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFFAF9F0); // slightly lifted off primary
  static const textPrimary = Color(0xFF3A2A1E); // near-sienna, warm dark
  static const textMuted = Color(0xFF8A7863);
  static const border = Color(0xFFE6E0C8);

  static const success = Color(0xFF4C8B5A);
  static const warning = Color(0xFFD8A73D);
  static const danger = accent;

  // Severity scale — deliberately distinct from the status-workflow colors
  // so a report's AI-assessed severity is never confused with its
  // Pending/Verified/etc. status at a glance.
  static const severityLow = Color(0xFF7C9473);
  static const severityModerate = Color(0xFFD8A73D);
  static const severityHigh = Color(0xFFE07B39);
  static const severityCritical = Color(0xFFC0392B);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class AppRadius {
  static const card = 12.0;
  static const input = 8.0;
  static const chip = 999.0; // pill
}

/// Minimal, consistent motion — durations only, no bespoke curves per
/// screen. Used for status-change transitions, list-item entrances, and
/// the offline-queue sync indicator. Nothing in the app animates longer
/// than 300ms; nothing bounces or overshoots.
class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 300);
  static const curve = Curves.easeOut;
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.primary,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.accent,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: base.textTheme
          .apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.deep)
          .copyWith(
            headlineSmall: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.deep),
            titleLarge: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.deep),
            titleMedium: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.deep),
            bodyMedium: const TextStyle(color: AppColors.textPrimary, height: 1.4),
            bodySmall: const TextStyle(color: AppColors.textMuted),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.deep,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(color: AppColors.deep, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.input)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.deep,
          side: const BorderSide(color: AppColors.deep),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.input)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.accent),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surfaceAlt,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.deep,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.input)),
      ),
    );
  }
}
