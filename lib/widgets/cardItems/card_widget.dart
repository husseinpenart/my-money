import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/bus/debt_change_bus.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/auth/presentation/pages/debt/debt_details_sheet.dart';
import 'package:money/feature/data/dataResource/debt_remote_data_source.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/layouts/confirm_demand_layout.dart';
import 'package:money/widgets/contact/contact_style.dart';

import 'package:money/widgets/report/report_format.dart';

enum _CardAction { none, delete, star }

class CardWidget extends StatefulWidget {
  const CardWidget({super.key, required this.d, this.onChanged});

  final SearchDebt d;
  final VoidCallback? onChanged;

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  final DebtRemoteDataSource _ds = GetIt.I<DebtRemoteDataSource>();
  _CardAction _action = _CardAction.none;

  SearchDebt get d => widget.d;

  int get _price => int.tryParse(d.wholePrice) ?? 0;
  bool get _isDebt => d.isDebt;
  bool get _unpaid => !d.payStatus;
  int get _remaining => _unpaid ? _price : 0;
  bool get _overdue =>
      _unpaid && d.endedDate != null && d.endedDate!.isBefore(DateTime.now());

  Color get _typeColor => _isDebt
      ? const Color.fromRGBO(239, 68, 68, 1)
      : const Color.fromRGBO(49, 190, 145, 1);

  (String, Color, Color) get _badge {
    if (!_unpaid) {
      return (
        'تسویه شده',
        const Color.fromRGBO(49, 190, 145, 1),
        const Color.fromRGBO(240, 253, 244, 1),
      );
    }
    if (_overdue) {
      return (
        'معوق',
        const Color.fromRGBO(176, 123, 77, 1),
        const Color.fromRGBO(254, 243, 199, 1),
      );
    }
    return (
      'باز',
      const Color.fromRGBO(73, 120, 236, 1),
      const Color.fromRGBO(239, 246, 255, 1),
    );
  }

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
      DebtChangeBus.instance.notifyChanged(); // 👈 همین یک خط کم بود
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

  Future<void> _delete() async {
    final name = d.contactName.trim();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'حذف رکورد',
          style: sans(size: 15, weight: FontWeight.bold),
        ),
        content: Text(
          'آیا از حذف رکورد «${name.isEmpty ? 'این مورد' : name}» مطمئن هستی؟',
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

  @override
  Widget build(BuildContext context) {
    final (badgeText, badgeFg, badgeBg) = _badge;
    final name = d.contactName.trim();
    final desc = (d.description ?? '').trim();
    final progress = _unpaid ? 0.0 : 1.0;
    final starred = d.isStarred;

    return Card(
      elevation: 5,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ), // 👈 فاصله
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _details, // 👈 tap = جزئیات
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, right: 12, left: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _unpaid
                              ? Icons.hourglass_bottom
                              : Icons.check_circle_outline,
                          size: 12,
                          color: badgeFg,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          badgeText,
                          style: TextStyle(
                            fontFamily: 'sans',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: badgeFg,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 12, right: 12, left: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 32, 3, 136),
                            Color.fromARGB(255, 79, 40, 223),
                            Color.fromARGB(255, 107, 76, 219),
                            Color.fromARGB(255, 148, 123, 238),
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        name.isEmpty ? '؟' : name.substring(0, 1),
                        style: const TextStyle(
                          fontFamily: 'sans',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name.isEmpty ? '—' : name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'sans',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (starred) ...[
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Colors.amber,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          desc.isEmpty ? (_isDebt ? 'بدهی' : 'طلب') : desc,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'sans',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_sharp,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'سررسید: ${d.endedDate == null ? '—' : jalaliDate(d.endedDate!)}',
                              style: const TextStyle(
                                fontFamily: 'sans',
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        ScreenDictionary.wholePrice,
                        style: TextStyle(
                          fontFamily: 'sans',
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            _isDebt ? Icons.trending_down : Icons.trending_up,
                            size: 14,
                            color: _typeColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            money(_price),
                            style: TextStyle(
                              fontFamily: 'sans',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _typeColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        ScreenDictionary.reminded,
                        style: TextStyle(
                          fontFamily: 'sans',
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _remaining == 0 ? 'تسویه' : money(_remaining),
                        style: TextStyle(
                          fontFamily: 'sans',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _remaining == 0
                              ? const Color.fromRGBO(49, 190, 145, 1)
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        ButtonsDictionary.paymentProgress,
                        style: TextStyle(fontFamily: 'sans', fontSize: 13),
                      ),
                      Text(
                        fa('${(progress * 100).round()}%'),
                        style: const TextStyle(
                          fontFamily: 'sans',
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(
                    backgroundColor: const Color.fromRGBO(232, 236, 244, 1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color.fromRGBO(249, 186, 46, 1),
                    ),
                    borderRadius: BorderRadius.circular(100),
                    value: progress,
                    minHeight: 10,
                  ),
                ],
              ),
            ),

            Center(
              child: SizedBox(
                height: 1,
                child: const Divider(
                  height: 1,
                  color: Color.fromARGB(255, 177, 174, 174),
                  thickness: 1,
                  endIndent: 1,
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Center(
                    child: SizedBox(
                      height: 1,
                      child: VerticalDivider(
                        width: 1,
                        color: Color.fromARGB(255, 177, 174, 174),
                        thickness: 1,
                        endIndent: 1,
                      ),
                    ),
                  ),
                  _bottomBtn(
                    icon: starred
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    iconColor: Colors.amber,
                    label: starred
                        ? ButtonsDictionary.deleteStars
                        : 'ستاره‌دار کردن',
                    textColor: Colors.black,
                    busy: _action == _CardAction.star,
                    onTap: _toggleStar,
                  ),
                  _bottomBtn(
                    icon: Icons.create_outlined,
                    iconColor: const Color.fromRGBO(153, 198, 243, 1),
                    label: ButtonsDictionary.editItem,
                    textColor: const Color.fromRGBO(114, 146, 238, 1),
                    busy: false,
                    onTap: _edit,
                  ),
                  _bottomBtn(
                    icon: Icons.delete_outline_rounded,
                    iconColor: Colors.red,
                    label: ButtonsDictionary.deleteItem,
                    textColor: const Color.fromRGBO(248, 67, 67, 1),
                    busy: _action == _CardAction.delete,
                    onTap: _delete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBtn({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color textColor,
    required bool busy,
    required VoidCallback onTap,
  }) {
    return TextButton(
      onPressed: busy ? null : onTap,
      child: Row(
        children: [
          busy
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: iconColor,
                  ),
                )
              : Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'sans',
              color: textColor,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
