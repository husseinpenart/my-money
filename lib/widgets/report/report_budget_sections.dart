import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:money/feature/model/budget/budget_models.dart';
import 'package:money/feature/model/report/report_models.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/report/report_format.dart';
import 'package:money/widgets/report/report_insights.dart';
import 'package:money/widgets/report/report_sections.dart';

const _green = Color(0xFF16A34A);
const _red = Color(0xFFEF4444);

// ───────────────────── نکات و پیامدها ─────────────────────
class InsightsCard extends StatelessWidget {
  final List<ReportInsight> items;
  const InsightsCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ReportCard(
      title: 'نکات مهم و پیامدها',
      subtitle: 'تحلیل خودکار داده‌های همین بازه',
      child: items.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'نکته‌ی خاصی برای هشدار وجود ندارد',
                  style: sans(size: 12, color: Colors.grey.shade600),
                ),
              ),
            )
          : Column(
              children: [
                for (final i in items)
                  Builder(
                    builder: (_) {
                      final (icon, text, color) = insightView(i);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: color.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(icon, size: 18, color: color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                text,
                                style: sans(
                                  size: 12,
                                  color: Colors.black87,
                                ).copyWith(height: 1.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
    );
  }
}

// ───────────────────── جریان نقدی ۳۰ روز آینده ─────────────────────
class CashflowCard extends StatelessWidget {
  final ReportSummary s;
  const CashflowCard({super.key, required this.s});

  @override
  Widget build(BuildContext context) {
    final maxV = math.max(s.dueSoonReceivable, s.dueSoonDebt);

    Widget row(String label, String sub, double v, Color c) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: sans(size: 12))),
              Text(
                money(v),
                style: sans(size: 13, weight: FontWeight.bold, color: c),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: maxV <= 0 ? 0 : v / maxV,
              minHeight: 8,
              backgroundColor: c.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(c),
            ),
          ),
          const SizedBox(height: 3),
          Text(sub, style: sans(size: 10, color: Colors.grey.shade600)),
        ],
      ),
    );

    final net = s.dueSoonNet;
    return ReportCard(
      title: 'پیش‌بینی ۳۰ روز آینده',
      subtitle: 'سررسیدهای پرداخت‌نشده‌ی همین بازه',
      child: (s.dueSoonDebt <= 0 && s.dueSoonReceivable <= 0)
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'سررسیدی در ۳۰ روز آینده نداری',
                  style: sans(size: 12, color: Colors.grey.shade600),
                ),
              ),
            )
          : Column(
              children: [
                row(
                  'دریافتی مورد انتظار',
                  '${fa('${s.dueSoonReceivableCount}')} مورد',
                  s.dueSoonReceivable,
                  _green,
                ),
                row(
                  'پرداختی مورد نیاز',
                  '${fa('${s.dueSoonDebtCount}')} مورد',
                  s.dueSoonDebt,
                  _red,
                ),
                const Divider(height: 18),
                Row(
                  children: [
                    Text('خالص ۳۰ روز آینده', style: sans(size: 12)),
                    const Spacer(),
                    Text(
                      money(net),
                      style: sans(
                        size: 14,
                        weight: FontWeight.bold,
                        color: net >= 0 ? _green : _red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

// ───────────────────── خلاصه‌ی حقوق و هزینه ─────────────────────
class BudgetSummaryCard extends StatelessWidget {
  final ReportBudget b;
  const BudgetSummaryCard({super.key, required this.b});

  @override
  Widget build(BuildContext context) {
    final rate = b.savingsRate;
    final over = b.saved < 0;

    Widget mini(String l, String v, Color c) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l, style: sans(size: 10, color: Colors.white70)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                v,
                style: sans(size: 13, weight: FontWeight.bold, color: c),
              ),
            ),
          ],
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF1E3A8A), Color(0xFF3B5BDB)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${over ? 'کسری' : 'پس‌انداز'} این بازه',
            style: sans(size: 12, color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Text(
            money(b.saved.abs()),
            style: sans(
              size: 26,
              weight: FontWeight.bold,
              color: over ? const Color(0xFFFCA5A5) : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rate == null
                ? '—'
                : 'نرخ پس‌انداز: ${pct(rate)}  ·  ${fa('${b.cycleCount}')} دوره‌ی مالی',
            style: sans(size: 11, color: Colors.white70),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              mini('درآمد', money(b.income), const Color(0xFF86EFAC)),
              const SizedBox(width: 8),
              mini('هزینه', money(b.expense), const Color(0xFFFCA5A5)),
              const SizedBox(width: 8),
              mini(
                'میانگین هزینه‌ی ماهانه',
                money(b.avgMonthlyExpense),
                Colors.white,
              ),
            ],
          ),
          if (b.estimatedCycles > 0)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '${fa('${b.estimatedCycles}')} دوره با حقوق ثابت (تخمینی) محاسبه شده',
                style: sans(size: 10.5, color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────── درآمد در برابر هزینه به تفکیک دوره ─────────────────────
class BudgetCyclesChart extends StatelessWidget {
  final List<ReportBudgetCycle> cycles;
  const BudgetCyclesChart({super.key, required this.cycles});

  @override
  Widget build(BuildContext context) {
    final maxV = cycles.fold<double>(
      0,
      (m, c) => math.max(m, math.max(c.salary, c.spent)),
    );

    Widget bar(double f, Color c) => Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: f <= 0 ? 0 : f.clamp(0.03, 1.0).toDouble(),
        widthFactor: 1,
        child: Container(
          decoration: BoxDecoration(
            color: c,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
      ),
    );

    return ReportCard(
      title: 'درآمد و هزینه‌ی هر دوره',
      subtitle: 'دوره‌ی مالی از روز دریافت حقوق شروع می‌شود',
      child: maxV <= 0
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'داده‌ای برای نمایش وجود ندارد',
                  style: sans(size: 12, color: Colors.grey.shade600),
                ),
              ),
            )
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _dot(_green, 'درآمد'),
                    const SizedBox(width: 12),
                    _dot(_red, 'هزینه'),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 180,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final c in cycles)
                        Expanded(
                          child: Tooltip(
                            triggerMode: TooltipTriggerMode.tap,
                            message:
                                '${cycleLabel(c.cycleKey)}\nدرآمد${c.estimated ? ' (تخمینی)' : ''}: ${money(c.salary)}\nهزینه: ${money(c.spent)}\nتعداد هزینه: ${fa('${c.count}')}',
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: bar(
                                            c.salary / maxV,
                                            _green.withValues(
                                              alpha: c.estimated ? 0.45 : 1,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: bar(c.spent / maxV, _red),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    kMonthNames[c.cycleKey % 12].substring(
                                      0,
                                      math.min(
                                        3,
                                        kMonthNames[c.cycleKey % 12].length,
                                      ),
                                    ),
                                    style: sans(
                                      size: 9,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (cycles.any((c) => c.estimated))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'ستون روشن‌تر یعنی درآمد آن دوره تخمینی است',
                      style: sans(size: 10, color: Colors.grey.shade600),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _dot(Color c, String t) => Row(
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(t, style: sans(size: 10, color: Colors.grey.shade700)),
    ],
  );
}

// ───────────────────── هزینه به تفکیک دسته ─────────────────────
class ExpenseCategoriesCard extends StatelessWidget {
  final List<ReportCategoryAmount> cats;
  const ExpenseCategoriesCard({super.key, required this.cats});

  @override
  Widget build(BuildContext context) {
    return ReportCard(
      title: 'هزینه به تفکیک دسته',
      child: cats.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'هزینه‌ای ثبت نشده است',
                  style: sans(size: 12, color: Colors.grey.shade600),
                ),
              ),
            )
          : Column(
              children: [
                for (final c in cats)
                  Builder(
                    builder: (_) {
                      final cat = BudgetCategory.of(c.category);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(cat.icon, size: 16, color: cat.color),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${cat.label}  ·  ${fa('${c.count}')} مورد',
                                    style: sans(size: 12),
                                  ),
                                ),
                                Text(
                                  pct(c.share),
                                  style: sans(
                                    size: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  money(c.amount),
                                  style: sans(
                                    size: 12,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: c.share.clamp(0.0, 1.0).toDouble(),
                                minHeight: 7,
                                backgroundColor: cat.color.withValues(
                                  alpha: 0.12,
                                ),
                                valueColor: AlwaysStoppedAnimation(cat.color),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
    );
  }
}

// ───────────────────── بزرگ‌ترین هزینه‌ها ─────────────────────
class TopExpensesCard extends StatelessWidget {
  final List<ReportTopExpense> items;
  const TopExpensesCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return ReportCard(
      title: 'بزرگ‌ترین هزینه‌ها',
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 14),
            Builder(
              builder: (_) {
                final e = items[i];
                final cat = BudgetCategory.of(e.category);
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: cat.color.withValues(alpha: 0.12),
                      child: Icon(cat.icon, size: 16, color: cat.color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: sans(size: 13),
                          ),
                          Text(
                            '${cat.label}${e.date != null ? '  ·  ${jalaliDate(e.date!)}' : ''}',
                            style: sans(size: 10, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      money(e.amount),
                      style: sans(
                        size: 13,
                        weight: FontWeight.bold,
                        color: _red,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class BudgetEmptyCard extends StatelessWidget {
  const BudgetEmptyCard({super.key});
  @override
  Widget build(BuildContext context) => ReportCard(
    title: 'حقوق و هزینه',
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        'حقوق هنوز تنظیم نشده است. از بخش «حقوق و هزینه‌ها» مبلغ و روز دریافت حقوق را وارد کن تا درآمد، هزینه و پس‌انداز این‌جا گزارش شود.',
        style: sans(
          size: 12,
          color: Colors.grey.shade700,
        ).copyWith(height: 1.8),
      ),
    ),
  );
}
