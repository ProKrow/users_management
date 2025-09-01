import 'package:flutter/material.dart';

class AppTheme {
  static const TextStyle tableColumnText = TextStyle(color: Color.fromARGB(255, 167, 166, 166), fontWeight: FontWeight.bold);
  static const TextStyle tableCellText = TextStyle(color: Colors.white);
  static const TextStyle buttonTextStyle = TextStyle(color: Colors.white);


  static ButtonStyle buttonStyle = ButtonStyle(backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 17, 135, 4)));

  static const Color iconsColor = Color.fromARGB(255, 255, 102, 7);

static const Color primaryColor = Color(0xFF6C63FF);      // Modern purple
  static const Color secondaryColor = Color(0xFF03DAC6);    // Teal accent
  static const Color accentColor = Color(0xFFFF6B35);       // Orange accent
  static const Color backgroundColor = Color(0xFF121212);    // Dark background
  static const Color surfaceColor = Color(0xFF1E1E1E);      // Card/surface color
  static const Color cardColor = Color(0xFF2D2D2D);         // Elevated card color
  static const Color textPrimary = Color(0xFFFFFFFF);       // White text
  static const Color textSecondary = Color(0xFFB3B3B3);     // Gray text
  static const Color textHint = Color(0xFF757575);          // Hint text
  static const Color borderColor = Color(0xFF404040);       // Border color
  static const Color successColor = Color(0xFF4CAF50);      // Success green
  static const Color errorColor = Color(0xFFFF5252);        // Error red

  // Text Styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static const TextStyle hintStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textHint,
  );

  // Input Decoration
  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: labelMedium,
      hintStyle: hintStyle,
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // Container Decoration for Date Pickers
  static BoxDecoration datePickerDecoration = BoxDecoration(
    color: surfaceColor,
    border: Border.all(color: borderColor, width: 1),
    borderRadius: BorderRadius.circular(12),
  );

  static BoxDecoration datePickerFocusedDecoration = BoxDecoration(
    color: surfaceColor,
    border: Border.all(color: primaryColor, width: 2),
    borderRadius: BorderRadius.circular(12),
  );

  // Button Styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: textPrimary,
    elevation: 2,
    shadowColor: primaryColor.withValues(alpha: .3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    textStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  static ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: textSecondary,
    textStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
  );

  // Dialog Theme
  static DialogTheme dialogTheme = DialogTheme(
    backgroundColor: cardColor,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    titleTextStyle: titleLarge,
    contentTextStyle: bodyMedium,
  );
}