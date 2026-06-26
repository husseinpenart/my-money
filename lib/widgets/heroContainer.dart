import 'package:flutter/material.dart';

class Herocontainer extends StatelessWidget {
  const Herocontainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: 450,
      height: 350, 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomRight,
          transform: GradientRotation(BorderSide.strokeAlignCenter),
          tileMode: TileMode.clamp,
          colors: [
            Color.fromRGBO(30, 70, 184, 10),
            Color.fromRGBO(30, 80, 217, 10),
            Color.fromRGBO(42, 101, 229, 10),
            Color.fromRGBO(51, 110, 232, 10),
          ],
        ),
      ),
    );
  }
}
