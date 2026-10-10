import 'package:flutter/material.dart';

/// راه‌ای امن برای بازکردن درازِ بیرونی از هر عمقی از tree.
/// اگر `DrawerScope` دور body پیچیده شده باشد از `scaffoldKey` استفاده می‌کند؛
/// در غیر این صورت به‌صورت fallback نزدیک‌ترین `Scaffold` بالایی را پیدا می‌کند.
/// به همین دلیل هرگز روی null کرش نمی‌کند.
class DrawerScope extends InheritedWidget {
  const DrawerScope({super.key, this.scaffoldKey, required super.child});

  final GlobalKey<ScaffoldState>? scaffoldKey;

  static void open(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DrawerScope>();
    final key = scope?.scaffoldKey;
    if (key != null) {
      key.currentState?.openDrawer();
      return;
    }
    // fallback: بدون GlobalKey هم کار می‌کند
    Scaffold.maybeOf(context)?.openDrawer();
  }

  @override
  bool updateShouldNotify(DrawerScope old) => old.scaffoldKey != scaffoldKey;
}
