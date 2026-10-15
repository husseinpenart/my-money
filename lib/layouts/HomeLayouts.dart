import 'package:flutter/material.dart';
import 'package:money/widgets/MostImportant.dart';
import 'package:money/widgets/cardItems/card_item_layout.dart';
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
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 96, top: 8),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Header(),
            SizedBox(height: 12),
            Herocontainer(),
            SizedBox(height: 14),
            Quickaccess(),
            SizedBox(height: 14),
            Mostimportant(),
            SizedBox(height: 14),
            CardItemLayout(),
          ],
        ),
      ),
    );
  }
}
