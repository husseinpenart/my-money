import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/feature/auth/presentation/pages/debt/debt_details_sheet.dart';
import 'package:money/helper/utils/input_utils.dart';
import 'package:money/layouts/confirm_demand_layout.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/report/report_format.dart';

/// خروجی true یعنی چیزی تغییر کرد (فراخوان باید رفرش کند)
Future<bool> showContactDetails(BuildContext context, SearchContact c) async {
  final res = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => _ContactDetailsSheet(contact: c),
  );
  return res == true;
}

class _ContactDetailsSheet extends StatelessWidget {
  final SearchContact contact;
  const _ContactDetailsSheet({required this.contact});

  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: contact.phoneNumber));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade600,
          content: Text(
            'شماره کپی شد',
            style: sans(size: 13, color: Colors.white),
          ),
        ),
      );
  }

  Future<void> _openDebt(BuildContext context, SearchDebt d) async {
    final changed = await showDebtDetails(context, d);
    if (changed && context.mounted) Navigator.of(context).pop(true);
  }

  Future<void> _create(BuildContext context, {required bool debt}) async {
    final ok = await showDebtFormSheet(
      context,
      hasDebt: debt,
      initialContact: contact,
    );
    if (ok == true && context.mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final debts = [...contact.debts]
      ..sort((a, b) {
        if (a.payStatus != b.payStatus) return a.payStatus ? 1 : -1;
        final ea = a.endedDate ?? DateTime(9999);
        final eb = b.endedDate ?? DateTime(9999);
        return ea.compareTo(eb);
      });

    double unpaidRecv = 0, unpaidDebt = 0;
    var unpaidCount = 0;
    for (final d in debts) {
      if (d.payStatus) continue;
      unpaidCount++;
      final v = parseAmount(d.wholePrice) ?? 0;
      d.isDebt ? unpaidDebt += v : unpaidRecv += v;
    }
    final net = unpaidRecv - unpaidDebt;
    final netColor = unpaidCount == 0
        ? Colors.grey
        : (net >= 0 ? _green : _red);

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
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close),
                ),
                Expanded(
                  child: Text(
                    'جزئیات مخاطب',
                    textAlign: TextAlign.center,
                    style: sans(size: 16, weight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ───── آواتار + نام + شماره ─────
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [Color(0xFF4F28DF), Color(0xFF947BEE)],
                          ),
                        ),
                        child: Text(
                          contact.name.isEmpty
                              ? '؟'
                              : contact.name.characters.first,
                          style: sans(
                            size: 22,
                            weight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: sans(size: 17, weight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_outlined,
                                  size: 14,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  fa(contact.phoneNumber),
                                  style: sans(
                                    size: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: () => _copy(context),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.copy_rounded,
                                      size: 15,
                                      color: kAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ───── خلاصه مالی ─────
                  Row(
                    children: [
                      _stat('طلب باقی‌مانده', money(unpaidRecv), _green),
                      const SizedBox(width: 8),
                      _stat('بدهی باقی‌مانده', money(unpaidDebt), _red),
                      const SizedBox(width: 8),
                      _stat(
                        'تراز',
                        unpaidCount == 0 ? '—' : money(net),
                        netColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ───── دکمه‌های ثبت ─────
                  Row(
                    children: [
                      Expanded(
                        child: _action(
                          context,
                          'ثبت طلب',
                          Icons.south_west,
                          _green,
                          false,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _action(
                          context,
                          'ثبت بدهی',
                          Icons.north_east,
                          _red,
                          true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Text(
                        'بدهی و طلب‌ها',
                        style: sans(size: 13, weight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${fa('${debts.length}')})',
                        style: sans(size: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (debts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'هنوز بدهی یا طلبی برای این مخاطب ثبت نشده',
                          style: sans(size: 12, color: Colors.grey.shade600),
                        ),
                      ),
                    )
                  else
                    for (final d in debts)
                      _DebtRow(d: d, onTap: () => _openDebt(context, d)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color c) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: sans(size: 10, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: sans(size: 14, weight: FontWeight.bold, color: c),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _action(
    BuildContext context,
    String t,
    IconData i,
    Color c,
    bool debt,
  ) => SizedBox(
    height: 44,
    child: OutlinedButton.icon(
      onPressed: () => _create(context, debt: debt),
      icon: Icon(i, size: 18, color: c),
      label: Text(
        t,
        style: sans(size: 13, weight: FontWeight.bold, color: c),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: c.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

class _DebtRow extends StatelessWidget {
  final SearchDebt d;
  final VoidCallback onTap;
  const _DebtRow({required this.d, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = d.isDebt ? const Color(0xFFEF4444) : const Color(0xFF10B981);
    final amount = parseAmount(d.wholePrice);
    final desc = (d.description ?? '').trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEF0F4)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  d.isDebt ? Icons.north_east : Icons.south_west,
                  size: 16,
                  color: color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          d.isDebt ? 'بدهی' : 'طلب',
                          style: sans(size: 13, weight: FontWeight.bold),
                        ),
                        if (d.isStarred)
                          const Padding(
                            padding: EdgeInsetsDirectional.only(start: 4),
                            child: Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Colors.amber,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      desc.isNotEmpty
                          ? desc
                          : (d.endedDate == null
                                ? '—'
                                : 'سررسید: ${jalaliDate(d.endedDate!)}'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sans(size: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount == null ? d.wholePrice : money(amount),
                    style: sans(
                      size: 13,
                      weight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    d.payStatus ? 'تسویه‌شده' : 'پرداخت‌نشده',
                    style: sans(
                      size: 10,
                      color: d.payStatus
                          ? Colors.green.shade600
                          : Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
              Icon(Icons.chevron_left, size: 18, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
