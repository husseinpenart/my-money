import 'package:flutter/material.dart';
import 'package:money/widgets/contact/contact_style.dart';

const _grey400 = Color(0xFFBDBDBD);
const _grey500 = Color(0xFF9E9E9E);
const _brand = Color(0xFF4E81EF);

class DrawerTile extends StatelessWidget {
  const DrawerTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = _brand,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 19, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: sans(size: 13.5, weight: FontWeight.w600)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: sans(size: 11, color: _grey500)),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_left_rounded, size: 20, color: _grey400),
          ],
        ),
      ),
    );
  }
}
