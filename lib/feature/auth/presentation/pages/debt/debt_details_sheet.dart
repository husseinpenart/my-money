import 'package:flutter/material.dart';
import 'package:money/feature/model/DebtReceviable/cover_image.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/layouts/confirm_demand_layout.dart';
import 'package:money/widgets/DebtReceviable/cover_image_view.dart';
// 👇 اگر نام فایل CoverViewerPage فرق داشت، فقط این import را عوض کن
import 'package:money/widgets/DebtReceviable/cover_viewer.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/report/report_format.dart';

/// جزئیات یک رکورد (طلب/بدهی) + تصاویر با زوم/اسلاید + دکمه‌ی ویرایش.
/// خروجی: true یعنی رکورد ویرایش شد (تا صفحه‌ی فراخوان refresh کند).
Future<bool> showDebtDetails(BuildContext context, SearchDebt d) async {
  final res = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => _DebtDetailsSheet(d: d),
  );
  return res == true;
}

class _DebtDetailsSheet extends StatefulWidget {
  const _DebtDetailsSheet({required this.d});
  final SearchDebt d;

  @override
  State<_DebtDetailsSheet> createState() => _DebtDetailsSheetState();
}

class _DebtDetailsSheetState extends State<_DebtDetailsSheet> {
  late final CoverController _covers;

  @override
  void initState() {
    super.initState();
    final paths = widget.d.covers;
    _covers = CoverController([
      for (var i = 0; i < paths.length; i++)
        CoverImage(
          id: '${widget.d.payId}_$i',
          name: paths[i].split('/').last,
          url: paths[i],
        ),
    ]);
  }

  @override
  void dispose() {
    _covers.dispose();
    super.dispose();
  }

  Future<void> _edit() async {
    final ok = await showDebtFormSheet(context, initial: widget.d);
    if (ok == true && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.d;
    final isDebt = d.isDebt;
    final color = isDebt
        ? const Color.fromRGBO(239, 68, 68, 1)
        : const Color.fromRGBO(49, 190, 145, 1);
    final icon = isDebt ? Icons.north_east : Icons.south_west;
    final price = int.tryParse(d.wholePrice) ?? 0;
    final desc = (d.description ?? '').trim();
    final imgs = _covers.value;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
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
          const SizedBox(height: 12),

          // ───── هدر: نوع + مبلغ + ویرایش ─────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isDebt ? 'بدهی' : 'طلب',
                            style: sans(
                              size: 15,
                              weight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          if (d.isStarred) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Colors.amber,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        money(price),
                        style: sans(size: 13, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'ویرایش',
                  onPressed: _edit,
                  icon: const Icon(Icons.edit_outlined, color: kAccent),
                ),
                IconButton(
                  tooltip: 'بستن',
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(thickness: 0.5, height: 1),

          // ───── بدنه ─────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row(
                    Icons.person_outline,
                    'طرف حساب',
                    d.contactName.isEmpty ? '—' : d.contactName,
                  ),
                  _row(
                    Icons.phone_outlined,
                    'شماره',
                    d.contactPhoneNumber.isEmpty
                        ? '—'
                        : fa(d.contactPhoneNumber),
                  ),
                  _row(
                    Icons.calendar_today_outlined,
                    'تاریخ ثبت',
                    d.registerdDate == null
                        ? '—'
                        : jalaliDate(d.registerdDate!),
                  ),
                  _row(
                    Icons.event_busy_outlined,
                    'سررسید',
                    d.endedDate == null ? '—' : jalaliDate(d.endedDate!),
                  ),
                  _row(
                    Icons.check_circle_outline,
                    'وضعیت',
                    d.payStatus ? 'پرداخت‌شده' : 'پرداخت‌نشده',
                  ),

                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      'توضیحات',
                      style: sans(size: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          desc,
                          style: sans(size: 13, color: Colors.grey.shade800),
                        ),
                      ),
                    ),
                  ],

                  if (imgs.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'تصاویر (${fa('${imgs.length}')})',
                      style: sans(size: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var i = 0; i < imgs.length; i++)
                          GestureDetector(
                            onTap: () => showCoverViewer(
                              context,
                              controller: _covers,
                              initialIndex: i,
                              editable: false, // فقط نمایش/زوم/اسلاید
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 84,
                                height: 84,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CoverImageView(
                                      image: imgs[i],
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      right: 4,
                                      bottom: 4,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.zoom_out_map,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _edit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(
                        'ویرایش این رکورد',
                        style: sans(size: 13, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData ic, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(ic, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: sans(size: 12, color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: sans(size: 13, weight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
