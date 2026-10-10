import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/widgets/drawer/drawer_scope.dart';

class DrawerMenuButton extends StatelessWidget {
  const DrawerMenuButton({super.key, this.color, this.compact = false});

  final Color? color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'منو',
      visualDensity: compact ? VisualDensity.compact : null,
      padding: compact ? const EdgeInsets.all(6) : null,
      constraints: compact
          ? const BoxConstraints(minWidth: 36, minHeight: 36)
          : null,
      onPressed: () {
        HapticFeedback.selectionClick();
        DrawerScope.open(context); // 👈 امن، بدون کرش
      },
      icon: Icon(Icons.menu_rounded, color: color ?? Colors.black87),
    );
  }
}
