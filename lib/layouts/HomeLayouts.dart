import 'package:flutter/material.dart';
import 'package:money/widgets/header.dart';
import 'package:money/widgets/Hero/heroContainer.dart';
import 'package:money/widgets/quickAccess.dart';

class Homelayouts extends StatefulWidget {
  const Homelayouts({super.key});

  @override
  State<Homelayouts> createState() => _MyHomePageLayouts();
}

class _MyHomePageLayouts extends State<Homelayouts> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3),
      child: Column(
        children: [
          Header(),
          Herocontainer(),
          SizedBox(height: 10),
          Quickaccess(),
        ],
      ),
    );
  }
}
