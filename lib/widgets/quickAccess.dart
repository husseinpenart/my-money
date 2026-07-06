import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';

import 'package:money/helper/list/menu_item.dart';

class Quickaccess extends StatefulWidget {
  const Quickaccess({super.key});

  @override
  State<Quickaccess> createState() => _QuickaccessState();
}

class _QuickaccessState extends State<Quickaccess> {
  final List<MenuItemModel> menuItem = [
    MenuItemModel(
      icon: Icons.compare_arrows_sharp,
      label: ScreenDictionary.approveDemand,
      iconColor: Color.fromRGBO(77, 128, 239, 10),
      iconBackColor: const Color.fromRGBO(239, 246, 255, 10),
      onTap: () {
        print('1');
      },
    ),
    MenuItemModel(
      icon: Icons.arrow_outward,
      label: ScreenDictionary.approveDebt,
      iconColor: Color.fromRGBO(242, 102, 102, 10),
      iconBackColor: const Color.fromRGBO(254, 242, 242, 10),
      onTap: () {
        print('2');
      },
    ),
    MenuItemModel(
      icon: Icons.payment,
      label: ScreenDictionary.payment,
      iconColor: Color.fromRGBO(119, 216, 182, 10),
      iconBackColor: const Color.fromRGBO(240, 253, 244, 10),
      onTap: () {
        print('3');
      },
    ),
    MenuItemModel(
      icon: Icons.money_off,
      label: ScreenDictionary.fullsettlement,
      iconColor: Color.fromRGBO(245, 159, 13, 10),
      iconBackColor: const Color.fromRGBO(255, 251, 235, 10),
      onTap: () {
        print('4');
      },
    ),
    MenuItemModel(
      icon: Icons.dashboard_outlined,
      label: ScreenDictionary.report,
      iconColor: Color.fromRGBO(149, 106, 247, 10),
      iconBackColor: const Color.fromRGBO(239, 246, 255, 10),
      onTap: () {
        print('5');
      },
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.tryParse('470.70'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            color: Colors.black.withValues(alpha: 0.05),
            offset: Offset(0, 2),
            blurStyle: BlurStyle.normal,
            spreadRadius: BorderSide.strokeAlignOutside,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ScreenDictionary.quickAccess,
            style: TextStyle(fontFamily: 'sans'),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 10),
          Center(
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 15.0,
              runSpacing: 20.0,
              children: menuItem.map((item) {
                return Container(
                  padding: EdgeInsets.all(4),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: item.iconBackColor,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 7,
                              color: Colors.black.withValues(alpha: 0.08),
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(item.icon),
                          color: item.iconColor,
                          iconSize: 20,
                          onPressed: item.onTap,
                        ),
                      ),
                      const SizedBox(height: 10), // فاصله متن زیر دکمه
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'sans',
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(), // تبدیل خروجی مپ به لیست ویجت
            ),
          ),
        ],
      ),
    );
  }
}
