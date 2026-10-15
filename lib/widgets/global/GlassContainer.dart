import 'dart:ui';

import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(10),
    this.borderRadius = 20,
    this.blur = 15,
    this.opacity = 0.15,
    this.borderOpacity = 0.25,
    this.shadowOpacity = 0.1,
    this.containerWidth,
    // 👈 کلید فرار: اگر artifact سفید دیدی، این را false کن
    // (بدون BackdropFilter = بدون saveLayer = قطعی بدون fog)
    this.enableBlur = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final double opacity;
  final double borderOpacity;
  final double shadowOpacity;
  final double? containerWidth;
  final bool enableBlur;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    // لایه‌ی tint + border (همان container اصلی، با همان width)
    final glass = Container(
      width: containerWidth,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: radius,
        border: Border.all(
          color: Colors.white.withValues(alpha: borderOpacity),
        ),
      ),
      child: child,
    );

    // blur فقط وقتی enableBlur=true؛ و همیشه داخل ClipRRect با clip صریح
    final blurred = enableBlur
        ? ClipRRect(
            borderRadius: radius,
            clipBehavior: Clip.antiAlias, // 👈 صریح، نه پیش‌فرض مبهم
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: glass,
            ),
          )
        : glass;

    // 👈 سایه بیرون از لایه‌ی blur → دیگر halo سفید داخل saveLayer نمی‌سازد
    final shadowed = Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: shadowOpacity),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: blurred,
    );

    // 👈 ایزوله‌سازی saveLayer: نشت fog به کل صفحه بسته می‌شود
    return RepaintBoundary(child: shadowed);
  }
}
