import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';

class Heroinfo extends StatelessWidget {
  const Heroinfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            ScreenDictionary.pureIncomeText,
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'sans',
              fontSize: 14,
            ),
          ),
        ),

        const SizedBox(height: 12),

        Center(
          child: Text(
            '13,750,000',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'sans',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
