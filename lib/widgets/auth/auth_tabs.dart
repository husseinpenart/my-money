import 'package:flutter/material.dart';
import 'package:money/theme/app_colors.dart';

/// Two-tab switcher ("ثبت‌نام" / "ورود") shown at the top of the auth card.
/// [activeIndex] 0 = left tab, 1 = right tab.
class AuthTabs extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final int activeIndex;
  final Color activeColor;
  final ValueChanged<int> onChanged;

  const AuthTabs({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.activeIndex,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _tab(index: 0, label: leftLabel)),
        Expanded(child: _tab(index: 1, label: rightLabel)),
      ],
    );
  }

  Widget _tab({required int index, required String label}) {
    final active = index == activeIndex;
    return InkWell(
      onTap: () => onChanged(index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: active ? activeColor : AppColors.line, width: active ? 2.5 : 1.5),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: active ? activeColor : AppColors.muted,
          ),
        ),
      ),
    );
  }
}
