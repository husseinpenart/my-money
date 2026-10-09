import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/data/dataResource/debt_remote_data_source.dart';
import 'package:money/feature/model/DebtReceviable/cover_image.dart';
import 'package:money/feature/model/DebtReceviable/debt_form_data.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/helper/utils/input_utils.dart';
import 'package:money/layouts/confirm_demand_layout.dart';
import 'package:money/widgets/DebtReceviable/cover_image_view.dart';
import 'package:money/widgets/DebtReceviable/cover_viewer.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/report/report_format.dart';


/// خروجی true یعنی رکورد تغییر کرد (لیست را رفرش کن)
Future<bool?> showDebtDetailSheet(BuildContext context, String payId) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => _DebtDetailSheet(payId: payId),
  );
}

class _DebtDetailSheet extends StatefulWidget {
  final String payId;
  const _DebtDetailSheet({required this.payId});

  @override
  State<_DebtDetailSheet> createState() => _DebtDetailSheetState();
}

class _DebtDetailSheetState extends State<_DebtDetailSheet> {
  final _ds = GetIt.I<DebtRemoteDataSource>();

  SearchDebt? _debt;
  CoverController? _covers;
  bool _loading = true;
  bool _busy = false;
  bool _changed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _covers?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await _ds.getById(widget.payId);
      _covers?.dispose();
      _covers = CoverController([
        for (var i = 0; i < d.covers.length; i++)
          CoverImage(id: 'r$i', name: d.covers[i].split('/').last, url: d.covers[i]),
      ]);
      if (!mounted) return;
      setState(() {
        _debt = d;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e is DebtApiException ? e.message : backendMessage(e);
      });
    }
  }

  Future<void> _togglePaid() async {
    final d = _debt!;
    setState(() => _busy = true);
    try {
      await _ds.setPaid(d, paid: !d.payStatus);
      _changed = true;
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red.shade400,
          content: Text(e is DebtApiException ? e.message : backendMessage(e),
              style: sans(size: 13, color: Colors.white)),
        ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit() async {
    final ok = await showDebtFormSheet(context, initial: _debt);
    if (ok == true) {
      _changed = true;
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: Container(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.88),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(_changed),
                    icon: const Icon(Icons.close),
                  ),
                  Expanded(
                    child: Text('جزئیات',
                        textAlign: TextAlign.center,
                        style: sans(size: 16, weight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: CircularProgressIndicator(color: kAccent)),
      );
    }
    if (_error != null || _debt == null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error ?? 'رکورد پیدا نشد',
                textAlign: TextAlign.center,
                style: sans(size: 13, color: Colors.red.shade400)),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _load,
              child: Text('تلاش دوباره', style: sans(size: 12)),
            ),
          ],
        ),
      );
    }

    final d = _debt!;
    final color = d.isDebt ? Colors.red.shade400 : Colors.green.shade600;
    final amount = parseAmount(d.wholePrice);
    final days = _daysLeft(d);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ───── مبلغ ─────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(d.isDebt ? Icons.north_east : Icons.south_west,
                        size: 16, color: color),
                    const SizedBox(width: 6),
                    Text(d.isDebt ? 'بدهی' : 'طلب',
                        style: sans(size: 12, color: color)),
                    if (d.isStarred) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.star, size: 15, color: Colors.amber),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(amount == null ? d.wholePrice : money(amount),
                    style: sans(size: 24, weight: FontWeight.bold, color: color)),
                const SizedBox(height: 8),
                _statusChip(d, days),
              ],
            ),
          ),
          const SizedBox(height: 14),

          _row(Icons.person_outline, 'طرف حساب', d.contactName),
          _row(Icons.phone_outlined, 'شماره تماس', fa(d.contactPhoneNumber)),
          _row(Icons.event_available_outlined, 'تاریخ ثبت',
              d.registerdDate == null ? '—' : jalaliDate(d.registerdDate!)),
          _row(Icons.event_busy_outlined, 'تاریخ پایان پرداخت',
              d.endedDate == null ? '—' : jalaliDate(d.endedDate!)),
          if ((d.description ?? '').trim().isNotEmpty)
            _row(Icons.notes_outlined, 'توضیحات', d.description!.trim()),

          // ───── تصاویر ─────
          if (_covers != null && _covers!.value.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text('تصاویر و مدارک', style: sans(size: 12, color: Colors.grey[500])),
            const SizedBox(height: 8),
            SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _covers!.value.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => showCoverViewer(
                    context,
                    controller: _covers!,
                    initialIndex: i,
                    editable: false,
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 84,
                        height: 84,
                        child: CoverImageView(image: _covers!.value[i]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _busy ? null : _togglePaid,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: d.payStatus ? Colors.grey.shade700 : Colors.green.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(d.payStatus ? Icons.undo : Icons.check_circle_outline, size: 18),
                    label: Text(
                      d.payStatus ? 'برگرداندن به پرداخت‌نشده' : 'ثبت به‌عنوان تسویه‌شده',
                      style: sans(size: 12, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _edit,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18, color: kAccent),
                  label: Text('ویرایش', style: sans(size: 12, color: kAccent)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int? _daysLeft(SearchDebt d) {
    if (d.endedDate == null) return null;
    final e = d.endedDate!.toUtc();
    final now = DateTime.now().toUtc();
    return DateTime.utc(e.year, e.month, e.day)
        .difference(DateTime.utc(now.year, now.month, now.day))
        .inDays;
  }

  Widget _statusChip(SearchDebt d, int? days) {
    String text;
    Color c;
    if (d.payStatus) {
      text = 'تسویه‌شده';
      c = Colors.green.shade700;
    } else if (days == null) {
      text = 'پرداخت‌نشده';
      c = Colors.orange.shade800;
    } else if (days < 0) {
      text = '${fa('${days.abs()}')} روز معوق';
      c = Colors.red.shade600;
    } else if (days == 0) {
      text = 'سررسید امروز';
      c = Colors.orange.shade800;
    } else {
      text = '${fa('$days')} روز تا سررسید';
      c = days <= 3 ? Colors.orange.shade800 : Colors.blueGrey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: sans(size: 11, weight: FontWeight.w600, color: c)),
    );
  }

  Widget _row(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade500),
            const SizedBox(width: 10),
            SizedBox(
              width: 110,
              child: Text(label, style: sans(size: 12, color: Colors.grey.shade600)),
            ),
            Expanded(child: Text(value, style: sans(size: 13))),
          ],
        ),
      );
}