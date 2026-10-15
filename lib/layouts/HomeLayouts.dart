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
    return SafeArea(
      top: true,
      bottom: false,
      child: SingleChildScrollView(
        // عرض کامل تا فرزندان در Hit Test بدون سایز نمانند
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 96),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Header(),
              Herocontainer(),
              SizedBox(height: 10),
              Quickaccess(),
              SizedBox(height: 10),
              Mostimportant(),
              SizedBox(height: 10),
              CardItemLayout(),
            ],
          ),
        ),
      ),
    );
  }
}
