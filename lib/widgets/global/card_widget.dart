import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
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
                    color: const Color.fromRGBO(254, 243, 199, 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.hourglass_bottom,
                        size: 12,
                        color: Color.fromRGBO(176, 123, 77, 1),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'پرداخت جزئی',
                        style: TextStyle(
                          fontFamily: 'sans',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(176, 123, 77, 1),
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
                    child: const Text(
                      'ح',
                      style: TextStyle(
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
                          const Text(
                            'علی رضایی',
                            style: TextStyle(
                              fontFamily: 'sans',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'قرض شخصی برای اجاره خانه',
                        style: TextStyle(
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
                          const Text(
                            'سررسید: ۱۴۰۳/۰۴/۰۱',
                            style: TextStyle(
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
            padding: EdgeInsetsGeometry.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ScreenDictionary.wholePrice,
                      style: TextStyle(
                        fontFamily: 'sans',
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.trending_up, size: 14, color: Colors.teal),
                        Text(
                          '۴,۵۰۰,۰۰۰ ت',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.teal,
                          ),
                        ),
                        SizedBox(width: 4),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,

                  children: [
                    Text(
                      ScreenDictionary.reminded,
                      style: TextStyle(
                        fontFamily: 'sans',
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '۲,۵۰۰,۰۰۰ ت',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(width: 4),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ButtonsDictionary.paymentProgress,
                      style: TextStyle(fontFamily: 'sans', fontSize: 13),
                    ),
                    Text(
                      '44%',
                      style: TextStyle(fontFamily: 'sans', fontSize: 13),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                LinearProgressIndicator(
                  backgroundColor: Color.fromRGBO(232, 236, 244, 1),
                  color: Color.fromRGBO(232, 236, 244, 1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color.fromRGBO(249, 186, 46, 1),
                  ),
                  borderRadius: BorderRadius.circular(100),
                  value: 0.44,
                  minHeight: 10,
                  trackGap: 44,
                ),
              ],
            ),
          ),
          Center(
            child: SizedBox(
              height: 1,
              // width: 300,
              child: Divider(
                height: 1,
                color: const Color.fromARGB(255, 177, 174, 174),
                thickness: 1,
                endIndent: 1,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: SizedBox(
                    height: 1,
                    child: VerticalDivider(
                      width: 1,
                      color: const Color.fromARGB(255, 177, 174, 174),
                      thickness: 1,
                      endIndent: 1,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: null,
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                      SizedBox(width: 5),
                      Text(
                        ButtonsDictionary.deleteStars,
                        style: TextStyle(
                          fontFamily: 'sans',
                          color: Colors.black,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: null,
                  child: Row(
                    children: [
                      Icon(
                        Icons.create_outlined,
                        color: const Color.fromRGBO(153, 198, 243, 1),
                        size: 20,
                      ),
                      SizedBox(width: 5),
                      Text(
                        ButtonsDictionary.editItem,
                        style: TextStyle(
                          fontFamily: 'sans',
                          color: Color.fromRGBO(114, 146, 238, 1),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: null,
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                        size: 20,
                      ),

                      SizedBox(width: 5),
                      Text(
                        ButtonsDictionary.deleteItem,
                        style: TextStyle(
                          fontFamily: 'sans',
                          color: Color.fromRGBO(248, 67, 67, 1),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
