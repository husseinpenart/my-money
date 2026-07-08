import 'package:flutter/material.dart';
import 'package:money/widgets/global/card_widget.dart';

class CardItems extends StatelessWidget {
  const CardItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1),
      child: Column(
        children: [
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '۸ رکورد',
                  style: TextStyle(
                    fontFamily: 'sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.filter_alt_outlined,
                      size: 20,
                      color: Color.fromRGBO(111, 151, 241, 1),
                    ),
                    const SizedBox(width: 4),
                    const Text(
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
              ],
            ),
          ),

          const SizedBox(height: 10),

          // بدنه کارت
          CardWidget(),
        ],
      ),
    );
  }
}
