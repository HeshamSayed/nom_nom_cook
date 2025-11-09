import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Vibrant Orange (inspired by fresh ingredients)
  static const Color primary = Color(0xFFFF6B35); // Vibrant Orange
  static const Color primaryDark = Color(0xFFE55A2B);
  static const Color primaryLight = Color(0xFFFFE5DC);

  // Secondary Colors - Warm Red (appetite stimulating)
  static const Color secondary = Color(0xFFF7931E); // Warm Golden
  static const Color secondaryDark = Color(0xFFD67D1A);
  static const Color secondaryLight = Color(0xFFFFF4E6);

  // Accent Colors - Fresh Green (healthy and fresh)
  static const Color accent = Color(0xFF4ECDC4); // Turquoise
  static const Color accentDark = Color(0xFF3DB8AF);
  static const Color accentLight = Color(0xFFE0F7F6);

  // Success Color
  static const Color success = Color(0xFF5CB85C);
  static const Color successLight = Color(0xFFE8F5E8);

  // Error Color
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFFFE6E6);

  // Warning Color
  static const Color warning = Color(0xFFF39C12);
  static const Color warningLight = Color(0xFFFFF3E0);

  // Info Color
  static const Color info = Color(0xFF3498DB);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textHint = Color(0xFFBDC3C7);
  static const Color textDisabled = Color(0xFFECF0F1);

  // Border and Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Other UI Elements
  static const Color disabled = Color(0xFFE0E0E0);
  static const Color inputBackground = Color(0xFFFAFAFA);
  static const Color overlay = Color(0x66000000);

  // Status Colors
  static const Color online = Color(0xFF2ECC71);
  static const Color offline = Color(0xFF95A5A6);

  // Premium Gold
  static const Color premium = Color(0xFFFFD700);
  static const Color premiumLight = Color(0xFFFFF9E6);

  // Social Colors
  static const Color facebook = Color(0xFF1877F2);
  static const Color google = Color(0xFFDB4437);
  static const Color twitter = Color(0xFF1DA1F2);

  // Food Category Colors
  static const Color breakfast = Color(0xFFFFB347); // Orange
  static const Color lunch = Color(0xFFFF6B6B); // Red
  static const Color dinner = Color(0xFF9B59B6); // Purple
  static const Color snack = Color(0xFF3498DB); // Blue
  static const Color dessert = Color(0xFFE91E63); // Pink
  static const Color suhoor = Color(0xFF1ABC9C); // Teal
  static const Color iftar = Color(0xFFE67E22); // Dark Orange

  // Difficulty Colors
  static const Color easy = Color(0xFF2ECC71); // Green
  static const Color medium = Color(0xFFF39C12); // Orange
  static const Color hard = Color(0xFFE74C3C); // Red

  // Rating Colors
  static const Color rating = Color(0xFFFFC107); // Amber

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF27AE60)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient challengeGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFF7931E), Color(0xFFFFD166)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Definitions
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
