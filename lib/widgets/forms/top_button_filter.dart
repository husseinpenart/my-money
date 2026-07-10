import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';

class TopButtonFilter extends StatelessWidget {
  final bool isDemand;
  final bool isDebt;
  final VoidCallback onDemandTap;
  final VoidCallback onDebtTap;

  const TopButtonFilter({
    super.key,
    required this.isDemand,
    required this.isDebt,
    required this.onDemandTap,
    required this.onDebtTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GestureDetector(
            key: const Key('DemandSection'),
            onTap: onDemandTap,
            child: Container(
              margin: const EdgeInsets.all(13),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: isDemand
                    ? const Color.fromRGBO(37, 99, 235, 1)
                    : const Color.fromRGBO(232, 236, 244, 1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                ScreenDictionary.ownedTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'sans',
                  fontSize: 13,
                  color: isDemand ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            key: const Key('DebtSection'),
            onTap: onDebtTap,
            child: Container(
              margin: const EdgeInsets.all(13),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: isDebt
                    ? const Color.fromRGBO(239, 68, 68, 1)
                    : const Color.fromRGBO(232, 236, 244, 1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                ScreenDictionary.ownDebtTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'sans',
                  fontSize: 13,
                  color: isDebt ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
