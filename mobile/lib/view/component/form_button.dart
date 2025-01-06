import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../style.dart';

class FormButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final IconData? leadingIcon;

  const FormButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = isPrimary
        ? AppStyle.primaryButtonStyle.copyWith(
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          )
        : AppStyle.secondaryButtonStyle;

    final textStyle = isPrimary
        ? AppStyle.buttonTextStyle
        : AppStyle.secondaryButtonTextStyle;

    Widget buttonChild = isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(
                  leadingIcon,
                  color: isPrimary ? Colors.white : AppStyle.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
              ],
              Text(text, style: textStyle),
            ],
          );

    if (isPrimary) {
      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: buttonChild,
      );
    } else {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: buttonChild,
      );
    }
  }
}
