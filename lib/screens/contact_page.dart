import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';
import 'dart:math' as math;
import 'package:money/helper/list/contact_counter.dart';
import 'package:money/widgets/contact/animted_size_layout.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});
  @override
  State<StatefulWidget> createState() => _ContactPage();
}

class _ContactPage extends State<ContactPage> {
  bool _isExpanded = false;

  final List<ContactCounter> counterItem = [
    ContactCounter(
      backgroundColor: const Color.fromRGBO(239, 246, 255, 1),
      borderColor: const Color.fromRGBO(231, 236, 243, 1),
      number: '8',
      numberColor: const Color.fromRGBO(57, 110, 236, 1),
      textString: BottomNavigations.contacts,
      textStringColor: const Color.fromRGBO(57, 110, 236, 1),
    ),
    ContactCounter(
      backgroundColor: const Color.fromRGBO(240, 253, 244, 1),
      borderColor: const Color.fromRGBO(234, 241, 239, 1),
      number: '5',
      numberColor: const Color.fromRGBO(49, 190, 145, 1),
      textString: ScreenDictionary.demander,
      textStringColor: const Color.fromRGBO(49, 190, 145, 1),
    ),
    ContactCounter(
      backgroundColor: const Color.fromRGBO(254, 242, 242, 1),
      borderColor: const Color.fromRGBO(241, 233, 235, 1),
      number: '12',
      numberColor: const Color.fromRGBO(239, 68, 68, 1),
      textString: ScreenDictionary.debtor,
      textStringColor: const Color.fromRGBO(239, 68, 68, 1),
    ),
  ];

  void handleISExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          spacing: 20.0,
          children: [
            Text(
              BottomNavigations.contacts,
              style: const TextStyle(
                fontFamily: 'sans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            // بخش شمارنده‌های بالا
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: counterItem.map((item) {
                return Expanded(
                  // استفاده از Expanded برای توزیع بهتر در عرض
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.backgroundColor,
                      border: Border.all(width: 1, color: item.borderColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          item.number,
                          style: TextStyle(
                            fontFamily: 'sans',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: item.numberColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.textString,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'sans',
                            fontSize: 11,
                            color: item.textStringColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.purple,
                        ),
                        child: const Center(
                          child: Text(
                            'ح',
                            style: TextStyle(
                              fontFamily: 'sans',
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'حسین اسدی',
                              style: TextStyle(
                                fontFamily: 'sans',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '09039414838',
                              style: TextStyle(
                                fontFamily: 'sans',
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // مبلغ
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 5.0,
                        children: [
                          const Text(
                            '45,000,000',
                            style: TextStyle(
                              fontFamily: 'sans',
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(254, 243, 199, 1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              'پرداخت جزئی',
                              style: TextStyle(
                                fontFamily: 'sans',
                                fontSize: 12,
                                color: Color.fromRGBO(169, 121, 72, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      // دکمه بازشو (InkWell)
                      InkWell(
                        onTap: handleISExpanded,
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: Transform.rotate(
                            angle: _isExpanded ? (90 * math.pi / 180) : 0,
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 14,
                              color: Color(0xFFA9AEBC),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(236, 236, 238, 0.345),
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: AnimatedSizeLayout(isExpanded: _isExpanded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
