import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // Button Styles
  static ButtonStyle get goldButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.gold,
    foregroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static ButtonStyle get timeSlotButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.black,
    foregroundColor: Colors.white,
  );

  static ButtonStyle get selectedTimeSlotButtonStyle =>
      ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.black,
      );

  // Container Decorations
  static BoxDecoration get goldBorderContainer => BoxDecoration(
    color: AppColors.black.withAlpha(180),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.gold.withAlpha(150), width: 1.5),
  );

  static BoxDecoration get selectedBarberContainer => BoxDecoration(
    border: Border.all(color: AppColors.gold, width: 2),
    borderRadius: BorderRadius.circular(45),
  );

  static BoxDecoration get unselectedBarberContainer => BoxDecoration(
    border: Border.all(color: Colors.transparent, width: 2),
    borderRadius: BorderRadius.circular(45),
  );

  // Text Styles
  static TextStyle get titleStyle => const TextStyle(
    letterSpacing: 0.8,
    fontSize: 15,
    color: Color.fromARGB(153, 224, 224, 224),
  );

  static TextStyle get selectedBarberNameStyle => const TextStyle(
    color: AppColors.gold,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  static TextStyle get unselectedBarberNameStyle => const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  static TextStyle get barberSpecialtyStyle =>
      TextStyle(color: Colors.white.withAlpha(179), fontSize: 11);

  static TextStyle get dialogTitleStyle => const TextStyle(color: Colors.white);
  static TextStyle get dialogContentStyle =>
      const TextStyle(color: Colors.white70);

  static TextStyle get bodyTextStyle =>
      const TextStyle(color: AppColors.black, fontSize: 14);

  static TextStyle get greyBodyTextStyle =>
      const TextStyle(color: AppColors.grey, fontSize: 14);

  static TextStyle get appBarTitleStyle => const TextStyle(
    letterSpacing: 0.8,
    fontSize: 15,
    color: Color.fromARGB(153, 224, 224, 224),
  );

  static TextStyle get buttonTextStyle => const TextStyle(
    color: Colors.black,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // Dialog Theme
  static DialogTheme get dialogTheme => DialogTheme(
    backgroundColor: AppColors.black,
    titleTextStyle: dialogTitleStyle,
    contentTextStyle: dialogContentStyle,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  // App Bar Theme
  static AppBarTheme get appBarTheme => const AppBarTheme(
    backgroundColor: AppColors.black,
    elevation: 0,
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontFamily: 'sans-serif',
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  );

  // Global Theme
  static ThemeData get theme => ThemeData(
    primaryColor: AppColors.black,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'sans-serif',
    appBarTheme: appBarTheme,
    dialogTheme: dialogTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(style: goldButtonStyle),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    textTheme: TextTheme(
      titleLarge: const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: const TextStyle(
        color: AppColors.grey,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: bodyTextStyle,
      bodyMedium: greyBodyTextStyle,
    ),
  );
}
