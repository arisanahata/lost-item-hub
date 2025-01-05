import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../style.dart';

class FormButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;

  const FormButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = isPrimary
        ? AppStyle.primaryButtonStyle
        : AppStyle.secondaryButtonStyle;

    final textStyle = GoogleFonts.notoSans(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: isPrimary ? Colors.white : AppStyle.primaryColor,
    );

    if (isPrimary) {
      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(text, style: textStyle),
      );
    } else {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Text(text, style: textStyle),
      );
    }
  }
}
