import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/widgets/cardItems/card_items.dart';
import 'package:money/widgets/cardItems/filter_buttons.dart';

class CardItemLayout extends StatefulWidget {
  const CardItemLayout({super.key});

  @override
  State<CardItemLayout> createState() => _CardItemLayoutState();
}

class _CardItemLayoutState extends State<CardItemLayout> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final items = [
      ButtonsDictionary.allButton,
      ScreenDictionary.demandText,
      ScreenDictionary.debtsText,
      ButtonsDictionary.open,
      ButtonsDictionary.minor,
      ButtonsDictionary.important,
      ButtonsDictionary.settlement,
    ];
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(
              items.length,
              (index) => FilterButtons(
                title: items[index],
                isSelected: selectedIndex == index,
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            ),
          ),
          //  next Row
          CardItems(),
        ],
      ),
    );
  }
}
