import 'package:flutter/material.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/widgets/cardItems/card_widget.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/report/report_format.dart';

class CardItems extends StatelessWidget {
  const CardItems({
    super.key,
    required this.items,
    required this.onSortTap,
    this.onChanged,
  });

  final List<SearchDebt> items;
  final VoidCallback onSortTap;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${fa('${items.length}')} رکورد',
                  style: sans(
                    size: 12,
                    weight: FontWeight.w600,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
              ),
              InkWell(
                onTap: onSortTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.swap_vert_rounded,
                        size: 18,
                        color: kAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'مرتب‌سازی',
                        style: sans(
                          size: 12,
                          weight: FontWeight.w600,
                          color: kAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 10),
                Text(
                  'موردی برای نمایش وجود ندارد',
                  style: sans(size: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            // فضای پایین برای دکمه‌ی شناور (+)
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: items.length,
            itemBuilder: (context, i) => TweenAnimationBuilder<double>(
              key: ValueKey(items[i].payId),
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 300 + (i.clamp(0, 6) * 60)),
              curve: Curves.easeOut,
              builder: (_, v, child) => Opacity(
                opacity: v,
                child: Transform.translate(
                  offset: Offset(0, 16 * (1 - v)),
                  child: child,
                ),
              ),
              child: CardWidget(d: items[i], onChanged: onChanged),
            ),
          ),
      ],
    );
  }
}
  