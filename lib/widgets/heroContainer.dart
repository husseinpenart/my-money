import 'package:flutter/material.dart';
import 'package:money/widgets/heroLayer.dart';

class Herocontainer extends StatelessWidget {
  const Herocontainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(children: [Herolayer()]),
    );
  }
}
