import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/helper/list/linear_list.dart';

class LinearIndicator extends StatefulWidget {
  const LinearIndicator({super.key});

  @override
  State<LinearIndicator> createState() => _LinearIndicatorState();
}

class _LinearIndicatorState extends State<LinearIndicator> {
  final List<LinearList> progressItem = [
    LinearList(
      backgroundColor: Color.fromRGBO(204, 205, 207, 1),
      colors: Color.fromRGBO(204, 205, 207, 1),
      valueItem: 0.44,
      trackGap: 44,
      valueColor: Color.fromRGBO(255, 239, 20, 1),
      colorDecoration: Color.fromRGBO(255, 239, 20, 1),
      progressText: ButtonsDictionary.settlement,
      progressValue: '44',
    ),
    LinearList(
      backgroundColor: Color.fromRGBO(204, 205, 207, 1),
      colors: Color.fromRGBO(204, 205, 207, 1),
      valueItem: 0.14,
      trackGap: 14,
      valueColor: Color.fromRGBO(255, 73, 73, 1),
      colorDecoration: Color.fromRGBO(255, 73, 73, 1),
      progressText: ButtonsDictionary.minor,
      progressValue: '14',
    ),
    LinearList(
      backgroundColor: Color.fromRGBO(204, 205, 207, 1),
      colors: Color.fromRGBO(204, 205, 207, 1),
      valueItem: 0.66,
      trackGap: 66,
      valueColor: Color.fromRGBO(92, 255, 133, 1),
      colorDecoration: Color.fromRGBO(92, 255, 133, 1),
      progressText: ButtonsDictionary.open,
      progressValue: '66',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(14)),
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
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              ScreenDictionary.paymentStatus,
              style: TextStyle(
                fontFamily: 'sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: progressItem.map((item) {
                return Container(
                  padding: EdgeInsets.all(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 10.0,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: item.colorDecoration,
                            ),
                          ),
                          Text(
                            item.progressText,
                            style: TextStyle(fontFamily: 'sans', fontSize: 12),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(14),
                            width: 300,
                            child: LinearProgressIndicator(
                              backgroundColor: item.backgroundColor,
                              color: item.colors,
                              borderRadius: BorderRadius.circular(100),
                              value: item.valueItem,
                              minHeight: 10,
                              trackGap: item.trackGap,
                              semanticsValue: 'label',
                              valueColor: AlwaysStoppedAnimation<Color>(
                                item.valueColor,
                              ),
                            ),
                          ),
                          Text(
                            item.progressValue,
                            style: TextStyle(
                              fontFamily: 'sans',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
