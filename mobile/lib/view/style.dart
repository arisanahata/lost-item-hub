import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyle {
  // Colors
  static const Color primaryColor = Color.fromARGB(255, 12, 51, 135);
  static const Color secondaryColor = Color.fromARGB(255, 223, 170, 36);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static final Color borderColor = Colors.grey[200]!;
  static final Color iconColor = Colors.grey[600]!;
  static const Color focusedBorderColor = Color(0xFF1a56db);

  // Text Styles
  static TextStyle get titleStyle => GoogleFonts.notoSans(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      );

  static TextStyle get sectionTitleStyle => GoogleFonts.notoSans(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      );

  // Input Decoration
  static InputDecoration getInputDecoration({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: GoogleFonts.notoSans(fontSize: 16),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: iconColor) : null,
      suffix: suffix,
      filled: true,
      fillColor: Colors.white,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: focusedBorderColor),
      ),
    );
  }

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );
}
