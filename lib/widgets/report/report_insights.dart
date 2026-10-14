import 'package:flutter/material.dart';
import 'package:money/feature/model/budget/budget_models.dart';
import 'package:money/feature/model/report/report_models.dart';
import 'package:money/widgets/report/report_format.dart';

const _red = Color(0xFFEF4444);
const _amber = Color(0xFFF59E0B);
const _blue = Color(0xFF3B82F6);
const _green = Color(0xFF16A34A);

(IconData, String, Color) insightView(ReportInsight i) {
  final color = switch (i.severity) {
    'danger' => _red,
    'warn' => _amber,
    'good' => _green,
    _ => _blue,
  };
  final a = money(i.amount ?? 0);
  final n = fa('${i.count ?? 0}');
  final p = pct(i.percent ?? 0);
  final name = i.name ?? '';
  final cat = BudgetCategory.of(name).label;

  return switch (i.code) {
    'overdue_share' => (
      Icons.warning_amber_rounded,
      'حدود $p از مانده‌ی پرداخت‌نشده‌ات ($a در $n مورد) سررسیدش گذشته است. پیگیری یا تمدید تاریخ را در اولویت بگذار.',
      color,
    ),
    'old_overdue' => (
      Icons.history_toggle_off,
      '$n مورد بیش از ۹۰ روز معوق مانده ($a). هرچه بیشتر بماند، وصول یا تسویه‌اش سخت‌تر می‌شود.',
      color,
    ),
    'low_collection' => (
      Icons.trending_down,
      'فقط $p از مجموع طلب‌هایت وصول شده است. شاید لازم باشد پیگیری را جدی‌تر کنی.',
      color,
    ),
    'contact_concentration' => (
      Icons.pie_chart_outline,
      '$p از کل مانده‌ها فقط به «$name» مربوط است؛ یعنی ریسک تمرکز روی یک نفر بالاست.',
      color,
    ),
    'net_negative' => (
      Icons.balance,
      'بدهی‌های باقی‌مانده‌ات $a از طلب‌های باقی‌مانده بیشتر است. تراز مطالباتت منفی است.',
      color,
    ),
    'net_positive' => (
      Icons.verified_outlined,
      'تراز مطالباتت به نفع توست ($a) و موردی معوق نداری.',
      color,
    ),
    'due_soon_debt' => (
      Icons.event_busy_outlined,
      '$a بدهی ($n مورد) تا ۳۰ روز آینده سررسید می‌شود. از حالا پولش را کنار بگذار.',
      color,
    ),
    'due_soon_receivable' => (
      Icons.event_available_outlined,
      'تا ۳۰ روز آینده انتظار دریافت $a ($n مورد) را داری. قبل از سررسید یادآوری کن.',
      color,
    ),
    'debt_to_income' => (
      Icons.account_balance_outlined,
      'بدهی باقی‌مانده‌ات ($a) حدود $n برابر درآمد ماهانه‌ات است. بازپرداخت زمان‌بر خواهد بود.',
      color,
    ),
    'overspent' => (
      Icons.error_outline,
      'در این بازه $a بیشتر از درآمدت خرج کرده‌ای. این کسری از پس‌انداز یا بدهی جبران می‌شود.',
      color,
    ),
    'savings_good' => (
      Icons.savings_outlined,
      'نرخ پس‌اندازت $p است ($a). عملکرد خیلی خوبی است.',
      color,
    ),
    'savings_low' => (
      Icons.savings_outlined,
      'نرخ پس‌اندازت فقط $p است. یک اتفاق غیرمنتظره می‌تواند بودجه را به هم بزند.',
      color,
    ),
    'top_category' => (
      Icons.category_outlined,
      '$p از کل هزینه‌هایت ($a) فقط صرف «$cat» شده است. اگر قابل کاهش است، همین‌جا شروع کن.',
      color,
    ),
    'estimated_income' => (
      Icons.info_outline,
      'برای $n دوره، حقوق واقعی ثبت نشده و حقوق ثابت جایگزین شده؛ پس درآمد و پس‌انداز این گزارش تخمینی است.',
      color,
    ),
    'no_salary' => (
      Icons.payments_outlined,
      'برای دیدن گزارش درآمد، هزینه و پس‌انداز، ابتدا در بخش «حقوق و هزینه‌ها» حقوق را تنظیم کن.',
      color,
    ),
    'invalid_amounts' => (
      Icons.rule,
      '$n رکورد مبلغ قابل‌خواندن نداشت و در جمع‌ها نیامده است. مبلغ آن‌ها را اصلاح کن.',
      color,
    ),
    _ => (Icons.info_outline, i.code, color),
  };
}
