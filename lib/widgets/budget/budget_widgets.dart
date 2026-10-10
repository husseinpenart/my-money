import 'package:flutter/material.dart';
import 'package:money/widgets/contact/contact_style.dart';

const kGreen = Color(0xFF10B981);
const kRed = Color(0xFFEF4444);
const kAmber = Color(0xFFF59E0B);

BoxDecoration cardDeco() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: const Color(0xFFEEF0F4)),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ],
);

(String, Color) statusInfo(String s) => switch (s) {
  'paid' => ('پرداخت‌شده', kGreen),
  'partial' => ('نیمه‌پرداخت', kAmber),
  'overdue' => ('معوق', kRed),
  'over' => ('بیش از بودجه', kRed),
  _ => ('در انتظار', Colors.blueGrey),
};

class StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  const StatusChip(this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: sans(size: 10, weight: FontWeight.bold, color: color),
    ),
  );
}

class EmptyBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? action;
  final VoidCallback? onAction;
  const EmptyBox({
    super.key,
    required this.icon,
    required this.text,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 46, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: sans(size: 12, color: Colors.grey.shade600),
          ),
          if (action != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onAction,
              child: Text(action!, style: sans(size: 12)),
            ),
          ],
        ],
      ),
    ),
  );
}
