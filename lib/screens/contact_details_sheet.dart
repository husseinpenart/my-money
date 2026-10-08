import 'package:flutter/material.dart';
import 'package:money/feature/model/DebtReceviable/cover_image.dart';
import 'package:money/feature/model/contact/contact_model.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/helper/utils/number_helper.dart';
import 'package:money/widgets/DebtReceviable/cover_image_view.dart'; // 👈 برای تامبنیل
// 👇 اگر اسم فایل CoverViewerPage فرق داشت، فقط این import را اصلاح کن
import 'package:money/widgets/DebtReceviable/cover_viewer.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

Future<void> showContactDetails(BuildContext context, ContactModel contact) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => ContactDetailsSheet(contact: contact),
  );
}

// ───────── helpers ─────────
String _group(int v) {
  final neg = v < 0;
  final s = v.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '${neg ? '-' : ''}${b.toString()}';
}

String _money(int v) => '${NumberHelper.toPersianDigits(_group(v))} ت';

String _date(DateTime? dt) {
  if (dt == null) return '—';
  final j = Jalali.fromDateTime(dt);
  return NumberHelper.toPersianDigits(
    '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}',
  );
}

int _toInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;

class ContactDetailsSheet extends StatelessWidget {
  const ContactDetailsSheet({super.key, required this.contact});

  final ContactModel contact;

  // 👈 فیلد مدل = debts (نه debtReceivable)
  List<SearchDebt> get _tx => contact.debts;

  @override
  Widget build(BuildContext context) {
    final list = _tx;
    final receivable = list
        .where((d) => !d.isDebt)
        .fold<int>(0, (s, d) => s + _toInt(d.wholePrice));
    final debt = list
        .where((d) => d.isDebt)
        .fold<int>(0, (s, d) => s + _toInt(d.wholePrice));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
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
          const SizedBox(height: 14),

          // هدر مخاطب
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromRGBO(79, 40, 223, 1),
                        Color.fromRGBO(148, 123, 238, 1),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    contact.name.isNotEmpty
                        ? contact.name.characters.first
                        : '؟',
                    style: sans(
                      size: 18,
                      color: Colors.white,
                      weight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: sans(size: 16, weight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        NumberHelper.toPersianDigits(contact.phoneNumber),
                        style: sans(size: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(thickness: 0.5, height: 1),

          // جمع طلب / بدهی
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryBox(
                    label: 'جمع طلب',
                    value: _money(receivable),
                    color: const Color.fromRGBO(49, 190, 145, 1),
                    bg: const Color.fromRGBO(240, 253, 244, 1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryBox(
                    label: 'جمع بدهی',
                    value: _money(debt),
                    color: const Color.fromRGBO(239, 68, 68, 1),
                    bg: const Color.fromRGBO(254, 242, 242, 1),
                  ),
                ),
              ],
            ),
          ),

          // تراکنش‌ها
          Flexible(
            child: list.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'هنوز تراکنشی ثبت نشده',
                        style: TextStyle(fontFamily: 'sans', fontSize: 13),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _TransactionCard(d: list[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });
  final String label;
  final String value;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: sans(size: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          Text(
            value,
            style: sans(size: 15, weight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatefulWidget {
  const _TransactionCard({required this.d});
  final SearchDebt d;

  @override
  State<_TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<_TransactionCard> {
  late final CoverController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = CoverController(_toCovers(widget.d));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<CoverImage> _toCovers(SearchDebt d) {
    // covers الان List<String> غیر-null است → بدون ??
    return [
      for (var i = 0; i < d.covers.length; i++)
        CoverImage(
          id: '${d.payId}_$i',
          name: d.covers[i].split('/').last,
          url: d.covers[i],
        ),
    ];
  }

  void _openViewer(int index) {
    showCoverViewer(
      context,
      controller: _ctrl,
      initialIndex: index,
      editable: false, // فقط نمایش/زوم/اسلاید، بدون افزودن/حذف
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.d;
    final isDebt = d.isDebt;
    final color = isDebt
        ? const Color.fromRGBO(239, 68, 68, 1)
        : const Color.fromRGBO(49, 190, 145, 1);
    final icon = isDebt ? Icons.north_east : Icons.south_west;
    final title = isDebt ? 'بدهی' : 'طلب';
    final paid = d.payStatus;
    final starred = d.isStarred;
    final desc = (d.description ?? '').trim();
    final covers = _ctrl.value;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: sans(size: 13, weight: FontWeight.bold),
                        ),
                        if (starred) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_sharp,
                          size: 11,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ثبت: ${_date(d.registerdDate)}',
                          style: sans(size: 11, color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.event_busy_outlined,
                          size: 11,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'سررسید: ${_date(d.endedDate)}',
                          style: sans(size: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _money(_toInt(d.wholePrice)),
                    style: sans(
                      size: 14,
                      weight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: paid
                          ? const Color.fromRGBO(240, 253, 244, 1)
                          : const Color.fromRGBO(254, 243, 199, 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      paid ? 'پرداخت‌شده' : 'پرداخت‌نشده',
                      style: sans(
                        size: 10,
                        color: paid
                            ? const Color.fromRGBO(49, 190, 145, 1)
                            : const Color.fromRGBO(176, 123, 77, 1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (desc.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(desc, style: sans(size: 12, color: Colors.grey.shade700)),
          ],

          if (covers.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < covers.length; i++)
                  GestureDetector(
                    onTap: () => _openViewer(i),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // 👈 از CoverImageView موجود → resolveFileUrl اصلاح‌شده
                            CoverImageView(image: covers[i], fit: BoxFit.cover),
                            Positioned(
                              right: 4,
                              bottom: 4,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(6),
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
        ],
      ),
    );
  }
}
