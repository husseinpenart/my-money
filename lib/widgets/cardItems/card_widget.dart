import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/bus/debt_change_bus.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/auth/presentation/pages/debt/debt_details_sheet.dart';
import 'package:money/feature/data/dataResource/debt_remote_data_source.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/helper/utils/input_utils.dart';
import 'package:money/layouts/confirm_demand_layout.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/report/report_format.dart';

enum _CardAction { none, delete, star, pay }

enum _DueState { paid, overdue, today, soon, normal, unknown }

class CardWidget extends StatefulWidget {
  const CardWidget({super.key, required this.d, this.onChanged});

  final SearchDebt d;
  final VoidCallback? onChanged;

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);
  static const _amber = Color(0xFFF59E0B);
  static const _blue = Color(0xFF3B82F6);

  final DebtRemoteDataSource _ds = GetIt.I<DebtRemoteDataSource>();
  _CardAction _action = _CardAction.none;

  SearchDebt get d => widget.d;

  // ───────────── مقادیر محاسبه‌شده ─────────────
  double get _price => parseAmount(d.wholePrice) ?? 0;
  bool get _isDebt => d.isDebt;
  bool get _unpaid => !d.payStatus;
  double get _remaining => _unpaid ? _price : 0;
  Color get _typeColor => _isDebt ? _red : _green;

  /// تعداد روز تا سررسید (منفی = معوق)؛ فقط بر اساس تاریخ، نه ساعت
  int? get _daysLeft {
    final e = d.endedDate;
    if (e == null) return null;
    final u = e.toUtc();
    final n = DateTime.now().toUtc();
    return DateTime.utc(
      u.year,
      u.month,
      u.day,
    ).difference(DateTime.utc(n.year, n.month, n.day)).inDays;
  }

  _DueState get _due {
    if (!_unpaid) return _DueState.paid;
    final days = _daysLeft;
    if (days == null) return _DueState.unknown;
    if (days < 0) return _DueState.overdue;
    if (days == 0) return _DueState.today;
    if (days <= 3) return _DueState.soon;
    return _DueState.normal;
  }

  Color get _dueColor => switch (_due) {
    _DueState.paid => _green,
    _DueState.overdue => _red,
    _DueState.today => const Color(0xFFF97316),
    _DueState.soon => _amber,
    _DueState.normal => _blue,
    _DueState.unknown => Colors.blueGrey,
  };

  String get _dueText {
    final days = _daysLeft;
    return switch (_due) {
      _DueState.paid => 'تسویه شده',
      _DueState.overdue => '${fa('${days!.abs()}')} روز معوق',
      _DueState.today => 'امروز سررسید است',
      _DueState.soon || _DueState.normal => '${fa('$days')} روز تا سررسید',
      _DueState.unknown => 'بدون سررسید',
    };
  }

  IconData get _dueIcon => switch (_due) {
    _DueState.paid => Icons.check_circle_rounded,
    _DueState.overdue => Icons.warning_amber_rounded,
    _DueState.today => Icons.alarm_rounded,
    _DueState.soon => Icons.schedule_rounded,
    _DueState.normal => Icons.hourglass_bottom_rounded,
    _DueState.unknown => Icons.help_outline_rounded,
  };

  /// پیشرفت زمانی: از تاریخ ثبت تا سررسید (۰ تا ۱)
  double get _timeProgress {
    if (!_unpaid) return 1;
    final s = d.registerdDate, e = d.endedDate;
    if (s == null || e == null) return 0;
    final total = e.difference(s).inMinutes;
    if (total <= 0) return _due == _DueState.overdue ? 1 : 0;
    final elapsed = DateTime.now().difference(s).inMinutes;
    return (elapsed / total).clamp(0.0, 1.0).toDouble();
  }

  // ───────────── عملیات ─────────────
  void _snack(String m, bool err) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: err ? Colors.red.shade600 : Colors.green.shade600,
          content: Text(m, style: sans(size: 13, color: Colors.white)),
        ),
      );
  }

  Future<void> _run(
    _CardAction a,
    Future<void> Function() op,
    String okMsg,
  ) async {
    if (_action != _CardAction.none) return;
    setState(() => _action = a);
    try {
      await op();
      widget.onChanged?.call();
      DebtChangeBus.instance.notifyChanged();
      _snack(okMsg, false);
    } catch (e) {
      _snack(backendMessage(e), true);
    } finally {
      if (mounted) setState(() => _action = _CardAction.none);
    }
  }

  Future<void> _details() async {
    final changed = await showDebtDetails(context, d);
    if (changed == true) widget.onChanged?.call();
  }

  Future<void> _edit() async {
    final ok = await showDebtFormSheet(context, initial: d);
    if (ok == true) widget.onChanged?.call();
  }

  Future<void> _toggleStar() {
    final next = !d.isStarred;
    return _run(
      _CardAction.star,
      () => _ds.toggleStar(d.payId, next),
      next ? 'ستاره‌دار شد' : 'ستاره برداشته شد',
    );
  }

  Future<void> _togglePaid() {
    final paid = _unpaid; // اگر پرداخت‌نشده است، تسویه کن
    return _run(
      _CardAction.pay,
      () => _ds.setPaid(d, paid: paid),
      paid ? 'به‌عنوان تسویه‌شده ثبت شد' : 'به پرداخت‌نشده برگشت',
    );
  }

  Future<void> _delete() async {
    final name = d.contactName.trim();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'حذف رکورد',
          style: sans(size: 15, weight: FontWeight.bold),
        ),
        content: Text(
          'آیا از حذف رکورد «${name.isEmpty ? 'این مورد' : name}» مطمئن هستی؟\nتصاویر پیوست‌شده هم حذف می‌شوند.',
          style: sans(size: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('انصراف', style: sans(size: 13)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'حذف',
              style: sans(size: 13, color: Colors.red.shade400),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _run(_CardAction.delete, () => _ds.delete(d.payId), 'رکورد حذف شد');
    }
  }

  // ───────────── UI ─────────────
  @override
  Widget build(BuildContext context) {
    final busy = _action != _CardAction.none;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEF0F4)),
        boxShadow: [
          BoxShadow(
            color: _typeColor.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: busy ? null : _details,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // نوار رنگی نوع رکورد
                  Container(
                    width: 5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _typeColor,
                          _typeColor.withValues(alpha: 0.45),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _header(busy),
                          const SizedBox(height: 14),
                          _amountBox(),
                          if ((d.description ?? '').trim().isNotEmpty ||
                              d.covers.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _noteRow(),
                          ],
                          const SizedBox(height: 14),
                          _timeline(),
                          const SizedBox(height: 14),
                          _payButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───── سربرگ: آواتار + نام + ستاره + منو ─────
  Widget _header(bool busy) {
    final name = d.contactName.trim();
    final starred = d.isStarred;

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
              colors: _isDebt
                  ? const [Color(0xFFEF4444), Color(0xFFF97316)]
                  : const [Color(0xFF059669), Color(0xFF34D399)],
            ),
          ),
          child: Text(
            name.isEmpty ? '؟' : name.characters.first,
            style: sans(size: 18, weight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? '—' : name,
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
                  Flexible(
                    child: Text(
                      d.contactPhoneNumber.isEmpty
                          ? '—'
                          : fa(d.contactPhoneNumber),
                      overflow: TextOverflow.ellipsis,
                      style: sans(size: 11, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _starButton(starred),
        PopupMenuButton<String>(
          enabled: !busy,
          tooltip: 'گزینه‌ها',
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.more_vert_rounded,
            color: Colors.grey.shade600,
            size: 22,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onSelected: (v) {
            if (v == 'details') _details();
            if (v == 'edit') _edit();
            if (v == 'delete') _delete();
          },
          itemBuilder: (_) => [
            _menuItem(
              'details',
              Icons.visibility_outlined,
              'مشاهده جزئیات',
              Colors.black87,
            ),
            _menuItem(
              'edit',
              Icons.edit_outlined,
              'ویرایش',
              const Color(0xFF4F6EF7),
            ),
            const PopupMenuDivider(height: 4),
            _menuItem('delete', Icons.delete_outline_rounded, 'حذف', _red),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(String v, IconData i, String t, Color c) =>
      PopupMenuItem<String>(
        value: v,
        height: 42,
        child: Row(
          children: [
            Icon(i, size: 19, color: c),
            const SizedBox(width: 10),
            Text(t, style: sans(size: 13, color: c)),
          ],
        ),
      );

  Widget _starButton(bool starred) {
    if (_action == _CardAction.star) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.amber,
            ),
          ),
        ),
      );
    }
    return IconButton(
      tooltip: starred ? 'برداشتن ستاره' : 'ستاره‌دار کردن',
      visualDensity: VisualDensity.compact,
      onPressed: _action != _CardAction.none ? null : _toggleStar,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
        child: Icon(
          starred ? Icons.star_rounded : Icons.star_border_rounded,
          key: ValueKey(starred),
          color: starred ? Colors.amber : Colors.grey.shade400,
          size: 24,
        ),
      ),
    );
  }

  // ───── باکس مبلغ و مانده ─────
  Widget _amountBox() {
    final remainingColor = _remaining == 0 ? _green : _red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _typeColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _typeColor.withValues(alpha: 0.14)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _typeChip(),
                      const SizedBox(width: 6),
                      Text(
                        'کل مبلغ',
                        style: sans(size: 11, color: Colors.blueGrey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      money(_price),
                      style: sans(
                        size: 20,
                        weight: FontWeight.bold,
                        color: _typeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            VerticalDivider(
              width: 24,
              thickness: 1,
              color: _typeColor.withValues(alpha: 0.18),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('مانده', style: sans(size: 11, color: Colors.blueGrey)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (_remaining == 0)
                      const Padding(
                        padding: EdgeInsetsDirectional.only(end: 4),
                        child: Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: _green,
                        ),
                      ),
                    Text(
                      _remaining == 0 ? 'تسویه' : money(_remaining),
                      style: sans(
                        size: 14,
                        weight: FontWeight.bold,
                        color: remainingColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: _typeColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      _isDebt ? 'بدهی' : 'طلب',
      style: sans(size: 10, weight: FontWeight.bold, color: Colors.white),
    ),
  );

  // ───── توضیحات + تعداد تصاویر ─────
  Widget _noteRow() {
    final desc = (d.description ?? '').trim();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (desc.isNotEmpty)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notes_rounded,
                    size: 15,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: sans(size: 12, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          const Spacer(),
        if (d.covers.isNotEmpty) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.photo_library_outlined,
                  size: 15,
                  color: Color(0xFF4F6EF7),
                ),
                const SizedBox(width: 5),
                Text(
                  fa('${d.covers.length}'),
                  style: sans(
                    size: 12,
                    weight: FontWeight.bold,
                    color: const Color(0xFF4F6EF7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ───── خط زمانی سررسید ─────
  Widget _timeline() {
    final c = _dueColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.event_rounded, size: 15, color: Colors.grey.shade500),
            const SizedBox(width: 5),
            Text(
              'سررسید: ${d.endedDate == null ? '—' : jalaliDate(d.endedDate!)}',
              style: sans(size: 12, color: Colors.grey.shade700),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_dueIcon, size: 13, color: c),
                  const SizedBox(width: 4),
                  Text(
                    _dueText,
                    style: sans(size: 11, weight: FontWeight.bold, color: c),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: _timeProgress),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: v,
              minHeight: 7,
              backgroundColor: c.withValues(alpha: 0.14),
              valueColor: AlwaysStoppedAnimation(c),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              d.registerdDate == null
                  ? ''
                  : 'ثبت: ${jalaliDate(d.registerdDate!)}',
              style: sans(size: 10, color: Colors.grey.shade500),
            ),
            Text(
              _unpaid
                  ? 'زمان سپری‌شده ${fa('${(_timeProgress * 100).round()}٪')}'
                  : 'پرداخت کامل شد',
              style: sans(size: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      ],
    );
  }

  // ───── دکمه‌ی اصلی تسویه ─────
  Widget _payButton() {
    final paying = _action == _CardAction.pay;
    final deleting = _action == _CardAction.delete;
    final busy = _action != _CardAction.none;

    final Widget icon = (paying || deleting)
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _unpaid ? Colors.white : Colors.grey.shade700,
            ),
          )
        : Icon(_unpaid ? Icons.task_alt_rounded : Icons.undo_rounded, size: 18);

    final label = Text(
      deleting
          ? 'در حال حذف...'
          : (_unpaid
                ? (_isDebt ? 'ثبت پرداخت بدهی' : 'ثبت دریافت طلب')
                : 'بازگشت به پرداخت‌نشده'),
      style: sans(size: 13, weight: FontWeight.bold),
    );

    return SizedBox(
      height: 44,
      child: _unpaid
          ? ElevatedButton.icon(
              onPressed: busy ? null : _togglePaid,
              icon: icon,
              label: label,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _green.withValues(alpha: 0.6),
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: busy ? null : _togglePaid,
              icon: icon,
              label: label,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
    );
  }
}
