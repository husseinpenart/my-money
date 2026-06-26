import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/widgets/global/CustomIconButton.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2),
      width: double.maxFinite,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Titles.hello,
                  style: TextStyle(fontSize: 12, fontFamily: 'sans'),
                ),
                Text(
                  'حسین اسدی 👋',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    wordSpacing: 2,
                    color: Colors.black,
                    fontFamily: 'sans',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                CustomIconButton(
                  onPressed: () {
                    print('bell pressed');
                  },
                  icon: Icons.search,
                ),
                SizedBox(width: 15),
                CustomIconButton(
                  onPressed: () {
                    print('bell pressed');
                  },
                  icon: Icons.doorbell,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
