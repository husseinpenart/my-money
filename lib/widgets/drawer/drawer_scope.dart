import 'package:flutter/material.dart';

/// با پیچیدن دور body‌ی اسکفولدِ بیرونی، هر descendant (حتی داخل Scaffoldهای
/// تودرتو) می‌تواند درازِ بیرونی را باز کند.
class DrawerScope extends InheritedWidget {
  const DrawerScope({
    super.key,
    required this.scaffoldKey,
    required super.child,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;

  static DrawerScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DrawerScope>();

  static DrawerScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(
      scope != null,
      'DrawerScope not found — آیا body را در آن پیچیده‌ای؟',
    );
    return scope!;
  }

  void open() => scaffoldKey.currentState?.openDrawer();

  @override
  bool updateShouldNotify(DrawerScope old) => false;
}
