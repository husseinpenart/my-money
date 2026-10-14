import 'package:flutter/material.dart';
import 'package:money/widgets/contact/contact_style.dart';

const _grey700 = Color(0xFF616161);

/// متن با بخش‌های پررنگ: هر قسمت بین ** ** بولد می‌شود
class RichLine extends StatelessWidget {
  const RichLine(
    this.text, {
    super.key,
    this.size = 12.5,
    this.color = _grey700,
    this.boldColor,
    this.height = 1.8,
  });

  final String text;
  final double size, height;
  final Color color;
  final Color? boldColor;

  @override
  Widget build(BuildContext context) {
    final parts = text.split('**');
    final base = sans(size: size, color: color).copyWith(height: height);
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          for (var i = 0; i < parts.length; i++)
            if (parts[i].isNotEmpty)
              TextSpan(
                text: parts[i],
                style: i.isOdd
                    ? TextStyle(
                        fontWeight: FontWeight.bold,
                        color: boldColor ?? Colors.black87,
                      )
                    : null,
              ),
        ],
      ),
    );
  }
}
