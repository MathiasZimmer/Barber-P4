// theme/app_theme.dart

// Put AppColors in its own file: theme/app_colors.dart
// class AppColors {
//   static const black = Colors.black;
//   static const darkGrey = Color(0xFF1A1A1A);
//   static const grey = Color(0xFF333333);
//   static const gold = Color(0xFFD4AF37);
//   static const darkGold = Color(0xFFB4941E);
// }

import 'package:flutter/material.dart';
import 'app_colors.dart'; // Assuming AppColors is now in a separate file

class AppTheme {
  // Button Styles
  static ButtonStyle get goldButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.gold,
    foregroundColor: AppColors.black, // Text color on gold button
    padding: const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 14,
    ), // Slightly more padding
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: buttonTextStyle.copyWith(
      fontWeight: FontWeight.bold,
    ), // Apply button text style
  );

  static ButtonStyle get timeSlotButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.grey, // Darker than black for better contrast
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );

  static ButtonStyle get selectedTimeSlotButtonStyle =>
      ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );

  // Container Decorations
  static BoxDecoration get goldBorderContainer => BoxDecoration(
    color: AppColors.darkGrey.withAlpha(
      217,
    ), // Slightly less opaque than pure black for depth
    borderRadius: BorderRadius.circular(12), // Softer radius
    border: Border.all(
      color: AppColors.gold.withAlpha(217),
      width: 1.5,
    ), // Slightly less opaque border
    boxShadow: [
      // Subtle shadow for depth
      BoxShadow(
        color: AppColors.black.withAlpha(50),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get selectedBarberContainer => BoxDecoration(
    border: Border.all(color: AppColors.gold, width: 2.5), // Thicker border
    borderRadius: BorderRadius.circular(45), // Keep if you like this radius
    // Add a subtle glow or background change for selected
    boxShadow: [
      BoxShadow(
        color: AppColors.gold.withAlpha(50),
        blurRadius: 8,
        spreadRadius: 1,
      ),
    ],
  );

  static BoxDecoration get unselectedBarberContainer => BoxDecoration(
    border: Border.all(color: Colors.transparent, width: 2.5),
    borderRadius: BorderRadius.circular(45),
  );

  // Text Styles
  static TextStyle get titleStyle => const TextStyle(
    // General purpose title for sections
    fontSize: 18, // Slightly larger for section titles
    fontWeight: FontWeight.w600,
    color: Colors.white, // Assuming dark background
    letterSpacing: 0.5,
  );

  static TextStyle get selectedBarberNameStyle => const TextStyle(
    color: AppColors.gold,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  static TextStyle get unselectedBarberNameStyle => const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.normal, // Less emphasis than selected
    fontSize: 14,
  );

  static TextStyle get barberSpecialtyStyle => TextStyle(
    color: Colors.white.withOpacity(0.7),
    fontSize: 12,
  ); // Increased alpha

  static TextStyle get dialogTitleStyle => const TextStyle(
    color: AppColors.gold, // Use gold for dialog titles
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  static TextStyle get dialogContentStyle =>
      const TextStyle(color: Colors.white70, fontSize: 15); // Slightly larger

  static TextStyle
  get bodyTextStyle => // For general text on light backgrounds (if any)
      const TextStyle(color: AppColors.black, fontSize: 14);

  static TextStyle
  get lightBodyTextStyle => // For general text on dark backgrounds
      const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4);

  static TextStyle get appBarTitleStyle => const TextStyle(
    // More prominent AppBar title
    letterSpacing: 1,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.gold, // Gold for AppBar titles
  );

  static TextStyle get buttonTextStyle => const TextStyle(
    color: AppColors.black, // Default text color for buttons
    fontSize: 14,
    fontWeight: FontWeight.w500, // Or FontWeight.bold
    letterSpacing: 0.5,
  );

  // Helper for InputDecoration used in TextFormFields
  static InputDecoration inputDecoration(
    String labelText, {
    String? hintText,
    IconData? prefixIcon,
  }) => InputDecoration(
    labelText: labelText,
    hintText: hintText,
    labelStyle: const TextStyle(color: Colors.white70),
    hintStyle: const TextStyle(color: Colors.white54),
    prefixIcon:
        prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.gold.withAlpha(179))
            : null,
    contentPadding: const EdgeInsets.symmetric(
      vertical: 12.0,
      horizontal: 10.0,
    ), // Adjust padding
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Colors.white.withAlpha(128),
      ), // 0.5 * 255 ≈ 128
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.gold, width: 2.0),
    ),
    errorBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
    ),
    focusedErrorBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
    ),
    errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
    floatingLabelBehavior: FloatingLabelBehavior.auto, // Or .always
  );

  // Dialog Theme
  static DialogTheme get dialogTheme => DialogTheme(
    backgroundColor: AppColors.darkGrey, // Use darkGrey for dialog background
    titleTextStyle: dialogTitleStyle,
    contentTextStyle: dialogContentStyle,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ), // Softer radius
  );

  // App Bar Theme
  static AppBarTheme get appBarTheme => AppBarTheme(
    backgroundColor: AppColors.black, // Pure black for AppBar
    elevation: 0, // Flat AppBar
    centerTitle: true, // Center title by default
    iconTheme: IconThemeData(
      color: AppColors.gold.withAlpha(204), // 0.8 * 255 ≈ 204
    ), // Theming for back buttons etc.
    actionsIconTheme: IconThemeData(
      color: AppColors.gold.withOpacity(0.8),
    ), // Theming for action icons
    titleTextStyle: appBarTitleStyle, // Use the custom appBarTitleStyle
  );

  // Input Decoration Theme (NEW)
  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    labelStyle: const TextStyle(color: Colors.white70),
    hintStyle: const TextStyle(color: Colors.white54),
    prefixIconColor: AppColors.gold.withOpacity(0.7),
    contentPadding: const EdgeInsets.symmetric(
      vertical: 12.0,
      horizontal: 10.0,
    ),
    border: UnderlineInputBorder(
      // Default border for all states
      borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.gold, width: 2.0),
    ),
    errorBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
    ),
    focusedErrorBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
    ),
    errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
  );

  // Global Theme
  static ThemeData get theme => ThemeData(
    brightness:
        Brightness.dark, // Set brightness to dark for overall dark theme
    primaryColor: AppColors.gold, // Gold as the primary accent color
    colorScheme: ColorScheme.dark(
      // Define a dark color scheme
      primary: AppColors.gold,
      secondary: AppColors.darkGold,
      surface: AppColors.darkGrey, // Main app background
      error: Colors.redAccent,
      onPrimary:
          AppColors.black, // Text on primary color (e.g. on gold buttons)
      onSecondary: AppColors.black,
      onSurface: Colors.white, // Text on main background
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.black, // Main background for Scaffold
    fontFamily:
        'Roboto', // Example: Using Roboto font (add to pubspec.yaml and assets)
    appBarTheme: appBarTheme,
    dialogTheme: dialogTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: goldButtonStyle,
    ), // Default ElevatedButton style
    cardTheme: CardTheme(
      color: AppColors.darkGrey.withAlpha(204), // Cards on dark theme
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Default card margin
    ),
    inputDecorationTheme: inputDecorationTheme, // Apply global input decoration
    textTheme: TextTheme(
      // Display styles (large, prominent text)
      displayLarge: TextStyle(
        color: Colors.white.withAlpha(230),
        fontWeight: FontWeight.w300,
        fontSize: 57,
      ),
      displayMedium: TextStyle(
        color: Colors.white.withAlpha(230),
        fontWeight: FontWeight.w400,
        fontSize: 45,
      ),
      displaySmall: TextStyle(
        color: Colors.white.withAlpha(230),
        fontWeight: FontWeight.w400,
        fontSize: 36,
      ),

      // Headline styles (for headings)
      headlineLarge: TextStyle(
        color: AppColors.gold,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      headlineMedium: titleStyle.copyWith(
        fontSize: 28,
      ), // Use your custom titleStyle
      headlineSmall: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 24,
      ),

      // Title styles (smaller than headlines, for subheadings)
      titleLarge: titleStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ), // Your titleStyle
      titleMedium: TextStyle(
        color: Colors.white.withAlpha(217),
        fontWeight: FontWeight.w500,
        fontSize: 16,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        color: Colors.white.withAlpha(204),
        fontWeight: FontWeight.w500,
        fontSize: 14,
        letterSpacing: 0.1,
      ),

      // Body styles (for main text content)
      bodyLarge: lightBodyTextStyle.copyWith(
        fontSize: 16,
        letterSpacing: 0.5,
      ), // Your lightBodyTextStyle
      bodyMedium: lightBodyTextStyle.copyWith(
        fontSize: 14,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        color: Colors.white.withAlpha(130),
        fontSize: 12,
        letterSpacing: 0.4,
      ),

      // Label styles (for button text, captions, overlines)
      labelLarge: buttonTextStyle.copyWith(
        color: AppColors.gold,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ), // For prominent buttons
      labelMedium: TextStyle(
        color: Colors.white70,
        fontSize: 12,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        color: Colors.white.withAlpha(128),
        fontSize: 11,
        letterSpacing: 0.5,
      ),
    ).apply(
      // Apply base color for text on dark theme
      bodyColor: Colors.white.withAlpha(217),
      displayColor: Colors.white.withAlpha(217),
    ),
    // Define a text selection theme for consistent text selection handles
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.gold,
      selectionColor: AppColors.gold.withAlpha(102),
      selectionHandleColor: AppColors.darkGold,
    ),
    // Icon Theme
    iconTheme: IconThemeData(
      color: AppColors.gold.withAlpha(204), // 0.8 * 255 ≈ 204
      size: 24.0,
    ),
    // TabBar Theme
    tabBarTheme: TabBarTheme(
      labelColor: AppColors.gold,
      unselectedLabelColor: Colors.white70,
      indicatorSize: TabBarIndicatorSize.tab, // or .label
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.gold, width: 3.0),
      ),
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
    ),
  );
}
