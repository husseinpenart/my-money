import 'package:flutter/material.dart';
import 'package:money/feature/model/contact/contact_model.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/helper/utils/input_utils.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/report/report_format.dart';

const _green = Color(0xFF10B981);
const _red = Color(0xFFEF4444);
const _amber = Color(0xFFF59E0B);
const _grey = Color(0xFF64748B);

/// خلاصه‌ی مالی یک مخاطب (فقط موارد پرداخت‌نشده)
class _Metrics {
  final double receivable, debt;
  final int open, overdue;
  final DateTime? nextDue;
  const _Metrics(
    this.receivable,
    this.debt,
    this.open,
    this.overdue,
    this.nextDue,
  );

  double get net => receivable - debt;

  factory _Metrics.of(ContactModel c) {
    double r = 0, d = 0;
    var open = 0, overdue = 0;
    DateTime? next;
    final today = _day(DateTime.now());
    for (final x in c.debts) {
      if (x.payStatus) continue;
      open++;
      final v = parseAmount(x.wholePrice) ?? 0;
      x.isDebt ? d += v : r += v;
      final e = x.endedDate;
      if (e != null) {
        final ed = _day(e);
        if (ed.isBefore(today)) overdue++;
        if (next == null || ed.isBefore(next)) next = ed;
      }
    }
    return _Metrics(r, d, open, overdue, next);
  }

  static DateTime _day(DateTime d) {
    final u = d.toUtc();
    return DateTime.utc(u.year, u.month, u.day);
  }
}

int _daysTo(DateTime d) {
  final u = d.toUtc();
  final n = DateTime.now().toUtc();
  return DateTime.utc(
    u.year,
    u.month,
    u.day,
  ).difference(DateTime.utc(n.year, n.month, n.day)).inDays;
}

class ContactCard extends StatefulWidget {
  final ContactModel contact;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
  bool _expanded = false;

  (String, Color) _status(ContactModel c, _Metrics m) {
    if (c.debts.isEmpty) return ('بدون سابقه', _grey);
    if (m.open == 0) return ('تسویه‌شده', _green);
    return m.net >= 0 ? ('طلبکار', _green) : ('بدهکار', _red);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.contact;
    final m = _Metrics.of(c);
    final (label, color) = _status(c, m);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEF0F4)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: widget.onOpen,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(c, m, label, color),
                  const SizedBox(height: 12),
                  _stats(m),
                  if (m.nextDue != null) ...[
                    const SizedBox(height: 10),
                    _nextDue(m.nextDue!),
                  ],
                  if (c.debts.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _toggle(c),
                  ],
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: _expanded
                        ? _details(c)
                        : const SizedBox(width: double.infinity),
                  ),
                  if (c.debts.isEmpty || _expanded) _actions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───── سربرگ ─────
  Widget _header(ContactModel c, _Metrics m, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [color, color.withValues(alpha: 0.6)],
            ),
          ),
          child: Text(
            c.name.isEmpty ? '؟' : c.name.characters.first,
            style: sans(size: 18, weight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: sans(size: 15, weight: FontWeight.bold),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 12,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    fa(c.phoneNumber),
                    style: sans(size: 11.5, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              m.open == 0 ? '—' : money(m.net.abs()),
              style: sans(size: 15, weight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                label,
                style: sans(size: 10.5, weight: FontWeight.bold, color: color),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ───── آمار ─────
  Widget _stats(_Metrics m) {
    Widget cell(String title, String value, Color c, {String? badge}) =>
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: sans(size: 10, color: Colors.grey.shade600)),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  value,
                  style: sans(size: 13, weight: FontWeight.bold, color: c),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(height: 3),
                Text(
                  badge,
                  style: sans(size: 10, weight: FontWeight.bold, color: _red),
                ),
              ],
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            cell('طلب باقی‌مانده', money(m.receivable), _green),
            VerticalDivider(width: 18, color: Colors.grey.shade300),
            cell('بدهی باقی‌مانده', money(m.debt), _red),
            VerticalDivider(width: 18, color: Colors.grey.shade300),
            cell(
              'موارد باز',
              fa('${m.open}'),
              Colors.black87,
              badge: m.overdue > 0 ? '${fa('${m.overdue}')} معوق' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _nextDue(DateTime d) {
    final days = _daysTo(d);
    final (text, c) = days < 0
        ? ('${fa('${days.abs()}')} روز معوق', _red)
        : days == 0
        ? ('امروز', const Color(0xFFF97316))
        : ('${fa('$days')} روز دیگر', days <= 3 ? _amber : _grey);
    return Row(
      children: [
        Icon(Icons.event_rounded, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 5),
        Text(
          'نزدیک‌ترین سررسید: ${jalaliDate(d)}',
          style: sans(size: 11, color: Colors.grey.shade700),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: sans(size: 10.5, weight: FontWeight.bold, color: c),
          ),
        ),
      ],
    );
  }

  Widget _toggle(ContactModel c) => InkWell(
    onTap: () => setState(() => _expanded = !_expanded),
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _expanded ? 'بستن' : 'مشاهده ${fa('${c.debts.length}')} رکورد',
            style: sans(size: 12, weight: FontWeight.w600, color: kAccent),
          ),
          const SizedBox(width: 4),
          AnimatedRotation(
            turns: _expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: kAccent,
            ),
          ),
        ],
      ),
    ),
  );

  // ───── رکوردها ─────
  Widget _details(ContactModel c) {
    final list = [...c.debts]
      ..sort((a, b) {
        if (a.payStatus != b.payStatus) return a.payStatus ? 1 : -1;
        final ea = a.endedDate ?? DateTime(9999);
        final eb = b.endedDate ?? DateTime(9999);
        return ea.compareTo(eb);
      });
    const maxShown = 5;
    final shown = list.take(maxShown).toList();

    return Column(
      children: [
        const SizedBox(height: 4),
        for (final d in shown) _DebtRow(debt: d),
        if (list.length > maxShown)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextButton(
              onPressed: widget.onOpen,
              child: Text(
                'و ${fa('${list.length - maxShown}')} مورد دیگر… مشاهده‌ی همه',
                style: sans(size: 12, color: kAccent),
              ),
            ),
          ),
      ],
    );
  }

  Widget _actions() => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        Expanded(
          child: _btn(
            'جزئیات',
            Icons.visibility_outlined,
            kAccent,
            widget.onOpen,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _btn('ویرایش', Icons.edit_outlined, _grey, widget.onEdit),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _btn(
            'حذف',
            Icons.delete_outline_rounded,
            _red,
            widget.onDelete,
          ),
        ),
      ],
    ),
  );

  Widget _btn(String t, IconData i, Color c, VoidCallback f) =>
      OutlinedButton.icon(
        onPressed: f,
        icon: Icon(i, size: 16, color: c),
        label: Text(
          t,
          style: sans(size: 11.5, weight: FontWeight.w600, color: c),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          side: BorderSide(color: c.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
}

class _DebtRow extends StatelessWidget {
  final SearchDebt debt;
  const _DebtRow({required this.debt});

  @override
  Widget build(BuildContext context) {
    final color = debt.isDebt ? _red : _green;
    final desc = (debt.description ?? '').trim();
    final amount = parseAmount(debt.wholePrice);

    String status;
    Color sc;
    if (debt.payStatus) {
      status = 'تسویه‌شده';
      sc = _green;
    } else if (debt.endedDate == null) {
      status = 'پرداخت‌نشده';
      sc = _amber;
    } else {
      final d = _daysTo(debt.endedDate!);
      if (d < 0) {
        status = '${fa('${d.abs()}')} روز معوق';
        sc = _red;
      } else if (d == 0) {
        status = 'امروز';
        sc = const Color(0xFFF97316);
      } else {
        status = '${fa('$d')} روز مانده';
        sc = d <= 3 ? _amber : _grey;
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Icon(
            debt.isDebt ? Icons.north_east : Icons.south_west,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  desc.isEmpty ? (debt.isDebt ? 'بدهی' : 'طلب') : desc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sans(size: 12, weight: FontWeight.w600),
                ),
                if (debt.endedDate != null)
                  Text(
                    'سررسید: ${jalaliDate(debt.endedDate!)}',
                    style: sans(size: 10, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount == null ? debt.wholePrice : money(amount),
                style: sans(size: 12, weight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: sans(size: 10, weight: FontWeight.w600, color: sc),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
