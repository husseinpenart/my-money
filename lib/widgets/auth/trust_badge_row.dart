import 'package:flutter/material.dart';
import 'package:money/theme/app_colors.dart';

/// Row of small trust badges shown below the login button.
class TrustBadgeRow extends StatelessWidget {
  const TrustBadgeRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 22),
      padding: const EdgeInsets.only(top: 18),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TrustItem(icon: Icons.groups_outlined, label: '۱۰۰٪ خصوصی'),
          _TrustItem(icon: Icons.lock_outline_rounded, label: 'رمزگذاری شده'),
          _TrustItem(icon: Icons.verified_outlined, label: 'امن'),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FB),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 16, color: AppColors.blue2),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
