import 'package:flutter/material.dart';

class TextIconButton extends StatelessWidget {
  final VoidCallback onPress;
  final String buttonText;
  final IconData buttonIcon;
  final Color? buttonBackground;
  final Color? textColor;
  final Color? iconColor;

  const TextIconButton({
    super.key,
    this.buttonBackground,
    required this.buttonIcon,
    required this.buttonText,
    this.iconColor,
    required this.onPress,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPress,
      label: Text(
        buttonText,
        style: TextStyle(
          fontFamily: 'sans',
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),

      icon: Icon(
        buttonIcon,
        size: 14,
        color: iconColor,
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(buttonBackground),
      ),
    );
  }
}
