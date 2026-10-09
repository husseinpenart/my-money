import 'package:flutter/material.dart';

/// عدد را با انیمیشن شمارش نمایش می‌دهد. روی هر تغییر value خودش
/// از مقدار فعلی به مقدار جدید tween می‌کند (بدون controller دستی).
class AnimatedNumberText extends StatelessWidget {
  const AnimatedNumberText({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.duration = const Duration(milliseconds: 750),
  });

  final num value;
  final String Function(num) format;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<num>(
      tween: Tween<num>(end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => Text(format(animated), style: style),
    );
  }
}
