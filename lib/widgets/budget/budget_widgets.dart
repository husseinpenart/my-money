import 'package:flutter/material.dart';
import 'package:money/feature/model/budget/budget_models.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/report/report_format.dart';

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
(IconData, String, Color) warningView(PlanWarning w) {
  final color = switch (w.severity) {
    'danger' => kRed,
    'warn' => kAmber,
    _ => const Color(0xFF3B82F6),
  };
  final n = fa('${w.count ?? 0}');
  final a = money(w.amount ?? 0);

  return switch (w.code) {
    'salary_late' => (
      Icons.hourglass_top_rounded,
      'حقوق $n روز از موعد دیرتر شده. تا واریز آن، برنامه‌ی دوره‌ی قبل ادامه دارد. وقتی رسید، مبلغ و تاریخ واقعی را ثبت کن.',
      color,
    ),
    'carry_deficit' => (
      Icons.history_toggle_off,
      'دوره‌ی قبل $a کسری داشت و از حقوق این دوره کم شده است.',
      color,
    ),
    'over_income' => (
      Icons.error_outline,
      'خرجت $a از درآمد این دوره بیشتر شده است.',
      color,
    ),
    'committed_over' => (
      Icons.error_outline,
      'تعهدات و خرج‌های این دوره $a از حقوق بیشتر است.',
      color,
    ),
    'projected_deficit' => (
      Icons.trending_down,
      'با روند فعلی، پایان دوره حدود $a کسری خواهی داشت.',
      color,
    ),
    'runs_out' => (
      Icons.battery_alert_rounded,
      'با این نرخ خرج، پولت حدود $n روز دیگر تمام می‌شود.',
      color,
    ),
    'overdue_items' => (
      Icons.warning_amber_rounded,
      '$n مورد سررسیدگذشته هنوز پرداخت نشده است.',
      color,
    ),
    'unplanned_high' => (
      Icons.shopping_bag_outlined,
      'خرج‌های خارج از برنامه $a شده؛ بیش از ۳۰٪ حقوق.',
      color,
    ),
    'large_expense' => (
      Icons.priority_high_rounded,
      'هزینه‌ی «${w.name ?? ''}» به مبلغ $a بیش از نصف حقوق است. درست ثبت شده؟',
      color,
    ),
    'duplicate_expenses' => (
      Icons.copy_all_outlined,
      '$n هزینه‌ی تکراری مشکوک (هم‌عنوان، هم‌مبلغ، هم‌روز) دیده شد.',
      color,
    ),
    'payday_drift' => (
      Icons.event_repeat,
      'چند ماه پیاپی حقوق حدود $n روز دیرتر رسیده. شاید بهتر باشد روز حقوق را در تنظیمات عوض کنی.',
      color,
    ),
    _ => (Icons.info_outline, w.code, color),
  };
}

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
