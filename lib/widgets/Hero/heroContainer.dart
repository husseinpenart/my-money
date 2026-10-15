import 'package:flutter/material.dart';
import 'package:money/widgets/Hero/heroLayer.dart';

class Herocontainer extends StatelessWidget {
  const Herocontainer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(10),
      child: Herolayer(),
    );
  }
}
