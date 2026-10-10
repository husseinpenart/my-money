import 'package:flutter/material.dart';
import 'package:money/widgets/contact/contact_style.dart';

// رنگ‌های ثابت (hex) تا در هر const context امن باشند
const _grey600 = Color(0xFF757575);
const _grey700 = Color(0xFF616161);
const _green500 = Color(0xFF10B981);
const _brand = Color(0xFF4E81EF);

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.icon,
    this.title,
    this.color = _brand,
  });

  final Widget child;
  final IconData? icon;
  final String? title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF0F4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null || title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  const SizedBox(width: 10),
                ],
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: sans(size: 14, weight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class BulletRow extends StatelessWidget {
  const BulletRow({
    super.key,
    required this.text,
    this.icon = Icons.check_circle_outline_rounded,
    this.color = _green500,
  });
  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 9),
          // 👈 height با copyWith (sans آن را ندارد)
          Expanded(
            child: Text(
              text,
              style: sans(size: 12.5, color: _grey700).copyWith(height: 1.7),
            ),
          ),
        ],
      ),
    );
  }
}
