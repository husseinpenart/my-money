import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// روی دسکتاپِ وب، اپ را در یک «قاب موبایل» مرکزی با عرض محدود نشان می‌دهد
/// و دو طرفش پس‌زمینه‌ی خنثی می‌ماند. روی موبایل واقعی و روی وب با عرض
/// باریک‌تر از [maxWidth]، هیچ تغییری ایجاد نمی‌کند (child عیناً پاس می‌شود).
///
/// ⚠️ باید داخل MaterialApp.builder استفاده شود، نه دور home؛ وگرنه
/// showDialog / showModalBottomSheet / SnackBar از کادر بیرون می‌زنند.
class WebFrame extends StatelessWidget {
  const WebFrame({super.key, required this.child, this.maxWidth = 480});

  final Widget? child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final c = child;
    if (c == null) return const SizedBox.shrink();
    if (!kIsWeb) return c; // موبایل/دسکتاپ نیتیو: دست‌نخورده

    return LayoutBuilder(
      builder: (context, cons) {
        // اگر خود پنجره باریک است (موبایل مرورگر)، قاب لازم نیست
        if (cons.maxWidth <= maxWidth) return c;

        final mq = MediaQuery.of(context);
        return ColoredBox(
          color: const Color(0xFFE9EBF0), // پس‌زمینه‌ی دو طرف
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              // 👈 حیاتی: عرض داخل app را محدود کن تا Navigator و همه‌ی
              //    route ها (دیالوگ/شیت/توست) هم داخل کادر بمانند.
              //    ارتفاع و padding/viewInsets دست‌نخورده می‌مانند.
              child: MediaQuery(
                data: mq.copyWith(size: Size(maxWidth, mq.size.height)),
                child: Material(
                  color: Colors.white,
                  elevation: 6,
                  shadowColor: Colors.black26,
                  child: c,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
