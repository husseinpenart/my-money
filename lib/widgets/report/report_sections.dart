import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:money/feature/model/report/report_models.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/report/report_format.dart';


const _green = Color(0xFF16A34A);
const _red = Color(0xFFEF4444);
const _blue = Color.fromRGBO(37, 99, 235, 1);

// ───────────────────── کارت پایه ─────────────────────
class ReportCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  const ReportCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: sans(size: 14, weight: FontWeight.w600),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: sans(size: 11, color: Colors.grey.shade600)),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ───────────────────── انتخاب بازه ─────────────────────
class ReportPeriodBar extends StatelessWidget {
  final ReportPeriod selected;
  final ValueChanged<ReportPeriod> onChanged;
  const ReportPeriodBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final p in ReportPeriod.values)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(p.label, style: sans(size: 12)),
                selected: selected == p,
                showCheckmark: false,
                selectedColor: kAccent.withValues(alpha: 0.15),
                onSelected: (_) => onChanged(p),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────── کارت‌های شاخص ─────────────────────
class _Kpi {
  final String title, value, caption;
  final Color color;
  final IconData icon;
  const _Kpi(this.title, this.value, this.caption, this.color, this.icon);
}

class ReportKpiGrid extends StatelessWidget {
  final ReportSummary s;
  const ReportKpiGrid({super.key, required this.s});

  @override
  Widget build(BuildContext context) {
    final net = s.net;
    final items = <_Kpi>[
      _Kpi(
        'طلب باقی‌مانده',
        money(s.unpaidReceivable),
        'از مجموع ${money(s.totalReceivable)}',
        _green,
        Icons.south_west,
      ),
      _Kpi(
        'بدهی باقی‌مانده',
        money(s.unpaidDebt),
        'از مجموع ${money(s.totalDebt)}',
        _red,
        Icons.north_east,
      ),
      _Kpi(
        'تراز خالص',
        money(net),
        net >= 0 ? 'به نفع شما' : 'به ضرر شما',
        net >= 0 ? _green : _red,
        Icons.balance,
      ),
      _Kpi(
        'تعداد رکورد',
        fa('${s.recordCount}'),
        '${fa('${s.debtCount}')} بدهی · ${fa('${s.receivableCount}')} طلب',
        _blue,
        Icons.receipt_long_outlined,
      ),
      _Kpi(
        'طلب معوق',
        money(s.overdueReceivable),
        'سررسید گذشته و وصول‌نشده',
        Colors.orange.shade700,
        Icons.schedule,
      ),
      _Kpi(
        'بدهی معوق',
        money(s.overdueDebt),
        'سررسید گذشته و پرداخت‌نشده',
        Colors.deepOrange.shade700,
        Icons.warning_amber_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 640 ? 3 : 2;
        const gap = 10.0;
        final w = (c.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final k in items) SizedBox(width: w, child: _KpiTile(k)),
          ],
        );
      },
    );
  }
}

class _KpiTile extends StatelessWidget {
  final _Kpi k;
  const _KpiTile(this.k);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: k.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: k.color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(k.icon, size: 16, color: k.color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  k.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sans(size: 11, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                k.value,
                style: sans(size: 17, weight: FontWeight.bold, color: k.color),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            k.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: sans(size: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ───────────────────── دونات: ترکیب مانده‌ها ─────────────────────
class OutstandingDonutCard extends StatelessWidget {
  final ReportSummary s;
  const OutstandingDonutCard({super.key, required this.s});

  @override
  Widget build(BuildContext context) {
    final total = s.unpaidDebt + s.unpaidReceivable;
    final debtShare = total <= 0 ? 0.0 : s.unpaidDebt / total;
    final recvShare = total <= 0 ? 0.0 : s.unpaidReceivable / total;

    Widget legend(
      String label,
      double amount,
      double share,
      Color color,
    ) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: sans(size: 12)),
                Text(
                  money(amount),
                  style: sans(size: 12, weight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
          Text(pct(share), style: sans(size: 12, color: Colors.grey.shade700)),
        ],
      ),
    );

    return ReportCard(
      title: 'ترکیب مانده‌ها',
      subtitle: 'فقط رکوردهای پرداخت‌نشده',
      child: total <= 0
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'مانده‌ی پرداخت‌نشده‌ای وجود ندارد 🎉',
                  style: sans(size: 12, color: Colors.grey.shade600),
                ),
              ),
            )
          : Row(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(140, 140),
                        painter: _DonutPainter(
                          values: [s.unpaidReceivable, s.unpaidDebt],
                          colors: const [_green, _red],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'تراز',
                            style: sans(size: 10, color: Colors.grey.shade600),
                          ),
                          Text(
                            compact(s.net),
                            style: sans(
                              size: 13,
                              weight: FontWeight.bold,
                              color: s.net >= 0 ? _green : _red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      legend(
                        'طلب باقی‌مانده',
                        s.unpaidReceivable,
                        recvShare,
                        _green,
                      ),
                      legend('بدهی باقی‌مانده', s.unpaidDebt, debtShare, _red),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  _DonutPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 18.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final total = values.fold<double>(0, (a, b) => a + b);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    if (total <= 0) {
      paint.color = Colors.grey.shade200;
      canvas.drawArc(rect, 0, math.pi * 2, false, paint);
      return;
    }

    final nonZero = values.where((v) => v > 0).length;
    final gap = nonZero > 1 ? 0.05 : 0.0;
    var start = -math.pi / 2;

    for (var i = 0; i < values.length; i++) {
      if (values[i] <= 0) continue;
      final sweep = values[i] / total * math.pi * 2;
      paint.color = colors[i];
      canvas.drawArc(
        rect,
        start + gap / 2,
        math.max(0.001, sweep - gap),
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.values != values || old.colors != colors;
}

// ───────────────────── نرخ‌ها ─────────────────────
class RatesCard extends StatelessWidget {
  final ReportSummary s;
  const RatesCard({super.key, required this.s});

  Widget _row(String label, double? rate, String detail, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: sans(size: 12))),
              Text(
                rate == null ? '—' : pct(rate),
                style: sans(size: 13, weight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (rate ?? 0).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 4),
          Text(detail, style: sans(size: 10, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReportCard(
      title: 'نرخ تسویه',
      subtitle: 'بر اساس مبلغ، نه تعداد',
      child: Column(
        children: [
          _row(
            'وصول طلب‌ها',
            s.collectionRate,
            s.totalReceivable <= 0
                ? 'طلبی ثبت نشده است'
                : '${money(s.paidReceivable)} از ${money(s.totalReceivable)}',
            _green,
          ),
          _row(
            'بازپرداخت بدهی‌ها',
            s.repaymentRate,
            s.totalDebt <= 0
                ? 'بدهی‌ای ثبت نشده است'
                : '${money(s.paidDebt)} از ${money(s.totalDebt)}',
            _blue,
          ),
        ],
      ),
    );
  }
}

// ───────────────────── روند ماهانه ─────────────────────
class MonthlyChartCard extends StatelessWidget {
  final List<ReportMonth> months;
  const MonthlyChartCard({super.key, required this.months});

  @override
  Widget build(BuildContext context) {
    final maxV = months.fold<double>(
      0,
      (m, e) => math.max(m, math.max(e.debt, e.receivable)),
    );

    return ReportCard(
      title: 'روند ماهانه',
      subtitle: 'بر اساس تاریخ ثبت (ماه شمسی، حداکثر ۱۲ ماه آخر)',
      trailing: maxV > 0
          ? Text(
              'حداکثر: ${compact(maxV)}',
              style: sans(size: 10, color: Colors.grey.shade600),
            )
          : null,
      child: months.isEmpty || maxV <= 0
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
                    _dot(_green, 'طلب'),
                    const SizedBox(width: 12),
                    _dot(_red, 'بدهی'),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 190,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final m in months) Expanded(child: _col(m, maxV)),
                    ],
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

  Widget _col(ReportMonth m, double maxV) {
    final name = kMonthNames[(m.month - 1).clamp(0, 11)];
    final tip =
        '$name ${fa('${m.year}')}\nطلب: ${money(m.receivable)}\nبدهی: ${money(m.debt)}\nتعداد: ${fa('${m.count}')}';

    return Tooltip(
      message: tip,
      triggerMode: TooltipTriggerMode.tap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _Bar(frac: m.receivable / maxV, color: _green),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: _Bar(frac: m.debt / maxV, color: _red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name.length > 4 ? name.substring(0, 3) : name,
              maxLines: 1,
              style: sans(size: 9, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double frac;
  final Color color;
  const _Bar({required this.frac, required this.color});

  @override
  Widget build(BuildContext context) {
    final f = frac <= 0 ? 0.0 : frac.clamp(0.03, 1.0).toDouble();
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: f,
        widthFactor: 1,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
      ),
    );
  }
}

// ───────────────────── سالمندی (معوقات) ─────────────────────
class AgingCard extends StatelessWidget {
  final List<ReportAging> buckets;
  const AgingCard({super.key, required this.buckets});

  static const _colors = [
    Color(0xFF64748B),
    Color(0xFFF59E0B),
    Color(0xFFF97316),
    Color(0xFFEA580C),
    Color(0xFFDC2626),
  ];

  @override
  Widget build(BuildContext context) {
    final maxT = buckets.fold<double>(0, (m, e) => math.max(m, e.total));

    return ReportCard(
      title: 'سن مطالبات و بدهی‌ها',
      subtitle: 'پرداخت‌نشده‌ها بر اساس مدت گذشتن از تاریخ پایان',
      child: maxT <= 0
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'مورد پرداخت‌نشده‌ای وجود ندارد',
                  style: sans(size: 12, color: Colors.grey.shade600),
                ),
              ),
            )
          : Column(
              children: [
                for (var i = 0; i < buckets.length; i++)
                  _row(buckets[i], _colors[i % _colors.length], maxT),
              ],
            ),
    );
  }

  Widget _row(ReportAging b, Color color, double maxT) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${agingLabel(b.key)}  (${fa('${b.count}')} مورد)',
                  style: sans(size: 12),
                ),
              ),
              Text(
                money(b.total),
                style: sans(size: 12, weight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: maxT <= 0 ? 0 : b.total / maxT,
              minHeight: 7,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'طلب: ${money(b.receivable)}   |   بدهی: ${money(b.debt)}',
            style: sans(size: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ───────────────────── مهم‌ترین مخاطبین ─────────────────────
class TopContactsCard extends StatelessWidget {
  final List<ReportContact> contacts;
  const TopContactsCard({super.key, required this.contacts});

  @override
  Widget build(BuildContext context) {
    return ReportCard(
      title: 'بیشترین مانده‌ها به تفکیک مخاطب',
      subtitle: 'مرتب‌شده بر اساس قدر مطلق تراز پرداخت‌نشده',
      child: contacts.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'موردی وجود ندارد',
                  style: sans(size: 12, color: Colors.grey.shade600),
                ),
              ),
            )
          : Column(
              children: [
                for (var i = 0; i < contacts.length; i++) ...[
                  if (i > 0) const Divider(height: 14),
                  _tile(contacts[i]),
                ],
              ],
            ),
    );
  }

  Widget _tile(ReportContact c) {
    final color = c.net >= 0 ? _green : _red;
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Text(
            c.name.isEmpty ? '?' : c.name.characters.first,
            style: sans(size: 14, weight: FontWeight.bold, color: color),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: sans(size: 13),
              ),
              Text(
                fa(c.phoneNumber),
                style: sans(size: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              money(c.net.abs()),
              style: sans(size: 13, weight: FontWeight.bold, color: color),
            ),
            Text(
              '${c.net >= 0 ? 'طلبکار' : 'بدهکار'} · ${fa('${c.unpaidCount}')} مورد',
              style: sans(size: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }
}

// ───────────────────── مشخصات و روش محاسبه (قابل استناد) ─────────────────────
class ReportFooter extends StatelessWidget {
  final ReportData data;
  final ReportPeriod period;
  const ReportFooter({super.key, required this.data, required this.period});

  @override
  Widget build(BuildContext context) {
    final s = data.summary;

    Widget line(IconData icon, String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: sans(size: 11, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('مشخصات گزارش', style: sans(size: 12, weight: FontWeight.bold)),
          const SizedBox(height: 6),
          line(Icons.date_range, 'بازه: ${periodText(data, period)}'),
          line(
            Icons.access_time,
            'زمان تولید: ${data.generatedAt != null ? jalaliDateTime(data.generatedAt!) : '—'}',
          ),
          line(
            Icons.dataset_outlined,
            '${fa('${s.recordCount}')} رکورد از ${fa('${s.contactCount}')} مخاطب',
          ),
          line(
            Icons.rule,
            'معوق: رکورد پرداخت‌نشده‌ای که تاریخ پایانش گذشته است. بازه روی تاریخ ثبت اعمال می‌شود.',
          ),
          line(
            Icons.lock_outline,
            'محاسبه در سرور و فقط روی داده‌های حساب شما انجام شده است.',
          ),
          if (s.invalidAmountCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Colors.orange.shade800,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${fa('${s.invalidAmountCount}')} رکورد مبلغ قابل‌خواندن نداشت و در جمع‌های مالی لحاظ نشده است. تعداد رکوردها شامل آن‌هاست.',
                      style: sans(size: 11, color: Colors.orange.shade900),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
