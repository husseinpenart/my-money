import 'package:flutter/material.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/widgets/cardItems/card_widget.dart';
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
    return Container(
      padding: const EdgeInsets.all(1),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${fa('${items.length}')} رکورد', // 👈 تعداد واقعی
                  style: const TextStyle(
                    fontFamily: 'sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: onSortTap, // 👈 مرتب‌سازی واقعی
                  child: const Row(
                    children: [
                      Icon(Icons.filter_alt_outlined, size: 20, color: Color.fromRGBO(111, 151, 241, 1)),
                      SizedBox(width: 4),
                      Text(
                        'مرتب سازی',
                        style: TextStyle(
                          fontFamily: 'sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(111, 151, 241, 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'موردی برای نمایش وجود ندارد',
                  style: TextStyle(fontFamily: 'sans', fontSize: 12, color: Colors.grey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,                 // سازگار با SingleChildScrollView بیرونی
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, i) => CardWidget(
                d: items[i],
                onChanged: onChanged,
              ),
            ),
        ],
      ),
    );
  }
}