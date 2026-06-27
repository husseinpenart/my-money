import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/widgets/global/GlassContainer.dart';
import 'package:money/widgets/heroContainerGrid.dart';
import 'package:money/widgets/heroCountItems.dart';
import 'package:money/widgets/heroInfo.dart';

class Herolayer extends StatelessWidget {
  const Herolayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(99, 48, 40, 39),
            blurRadius: 50,
            offset: Offset(15, 45),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.centerRight,
          colors: [
            Color.fromARGB(255, 4, 19, 58),
            Color.fromARGB(255, 22, 53, 139),
            Color.fromARGB(255, 62, 105, 197),
            Color.fromARGB(255, 77, 118, 199),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white54,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    ScreenDictionary.myWalllet,
                    style: TextStyle(
                      color: Colors.grey[200],
                      fontFamily: 'sans',
                    ),
                  ),
                ],
              ),
              GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                containerWidth: 80,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ScreenDictionary.moenyUnit,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'sans',
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_drop_down_sharp,
                      color: Colors.white,
                      size: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          /// Hero info
          const Heroinfo(),
          SizedBox(height: 20),
          Herocontainergrid(),
          SizedBox(height: 10),
          Herocountitems(),
        ],
      ),
    );
  }
}
