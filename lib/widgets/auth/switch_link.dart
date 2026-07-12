import 'package:flutter/material.dart';

/// Tappable "plain text + colored link" line shown under the auth card,
/// e.g. "حساب ندارید؟ ثبت‌نام رایگان".
class SwitchLink extends StatelessWidget {
  final String plainText;
  final String linkText;
  final Color linkColor;
  final VoidCallback onTap;

  const SwitchLink({
    super.key,
    required this.plainText,
    required this.linkText,
    required this.linkColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
            children: [
              TextSpan(text: plainText),
              TextSpan(text: linkText, style: TextStyle(color: linkColor, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
