import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/helper/list/financial_card.dart';

class ReportGridCard extends StatefulWidget {
  const ReportGridCard({super.key});

  @override
  State<StatefulWidget> createState() => _ReportGridCard();
}

class _ReportGridCard extends State<ReportGridCard> {
  final List<FinancialCard> finanaceItems = [
    FinancialCard(
      icon: Icons.arrow_outward,
      title: ScreenDictionary.wholeDemand,
      iconColor: Color.fromRGBO(56, 113, 237, 1),
      iconBackColor: Color.fromRGBO(239, 246, 255, 1),
      price: '13,000,000',
    ),
    FinancialCard(
      icon: Icons.arrow_outward,
      title: ScreenDictionary.wholeDebt,
      iconColor: Color.fromRGBO(242, 101, 101, 1),
      iconBackColor: Color.fromRGBO(254, 242, 242, 1),
      price: '1,000,000',
    ),
    FinancialCard(
      icon: Icons.check_circle_outlined,
      title: ScreenDictionary.paidDebt,
      iconColor: Color.fromRGBO(86, 207, 165, 1),
      iconBackColor: Color.fromRGBO(240, 253, 244, 1),
      price: '4,000,000',
    ),
    FinancialCard(
      icon: Icons.watch_later_outlined,
      title: ScreenDictionary.wholeReminded,
      iconColor: Color.fromRGBO(248, 182, 69, 1),
      iconBackColor: Color.fromRGBO(255, 251, 235, 1),
      price: '15,000,000',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2, // 2 columns
      crossAxisSpacing: 2,
      mainAxisSpacing: 0,
      childAspectRatio: 1.4,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: finanaceItems.map((item) {
        return Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3,
                        color: Colors.black.withValues(alpha: 0.30),
                        spreadRadius: 0,
                        offset: Offset(3, 2),
                        blurStyle: BlurStyle.normal,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 5),
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: item.iconBackColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(item.icon, color: item.iconColor, size: 20),
                      ),
                      //  Icons part
                      Text(
                        item.title,
                        style: TextStyle(
                          fontFamily: 'sans',
                          fontSize: 10,
                          color: Colors.grey[400],
                        ),
                      ),
                      Text(
                        item.price,
                        style: TextStyle(fontFamily: 'sans', fontSize: 15),
                      ),
                      Text(
                        ScreenDictionary.moenyUnit,
                        style: TextStyle(
                          fontFamily: 'sans',
                          fontSize: 10,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
