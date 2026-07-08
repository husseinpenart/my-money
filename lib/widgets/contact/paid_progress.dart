import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';

class PaidProgrees extends StatelessWidget {
  const PaidProgrees({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ButtonsDictionary.paymentProgress,
                style: TextStyle(
                  fontFamily: 'sans',
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                '44%',
                style: TextStyle(
                  fontFamily: 'sans',
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
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
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'پرداخت شده : 20,000,000 ت',
                style: TextStyle(
                  fontFamily: 'sans',
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                'مانده کل :  10,000,000 ت',
                style: TextStyle(
                  fontFamily: 'sans',
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
