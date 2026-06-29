import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';

class CardItems extends StatelessWidget {
  const CardItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(23),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بخش هدر (تعداد رکورد و مرتب سازی)
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
          Center(
            child: Card(
              elevation: 5,
              shadowColor: Colors.black.withOpacity(0.08),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. برچسب زرد (در بالای کارت)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 12,
                      right: 12,
                      left: 12,
                    ),
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
                    padding: const EdgeInsets.only(
                      bottom: 12,
                      right: 12,
                      left: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // آواتار
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

                        // اطلاعات کاربر (استفاده از Expanded برای جلوگیری از overflow)
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
                                Icon(
                                  Icons.trending_up,
                                  size: 14,
                                  color: Colors.teal,
                                ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
