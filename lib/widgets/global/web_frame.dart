import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class WebFrame extends StatelessWidget {
  const WebFrame({super.key, required this.child, this.maxWidth = 480});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    final size = MediaQuery.sizeOf(context);

    if (size.width <= maxWidth) return child;

    final mq = MediaQuery.of(context);
    final frameSize = Size(maxWidth, size.height);

    return ColoredBox(
      color: const Color(0xFFE9EBF0),
      child: Center(
        child: SizedBox(
          width: frameSize.width,
          height: frameSize.height,
          child: MediaQuery(
            data: mq.copyWith(size: frameSize),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              // ✅ ClipRect به جای Material(transparency) — از hit-test روی widget بدون سایز جلوگیری می‌کند
              child: ClipRect(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
