import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/widgets/contact/grid_row_table.dart';
import 'package:money/widgets/contact/note_section.dart';
import 'package:money/widgets/contact/paid_progress.dart';
import 'package:money/widgets/global/text_icon_button.dart';

class AnimatedSizeLayout extends StatelessWidget {
  const AnimatedSizeLayout({super.key, required bool isExpanded})
    : _isExpanded = isExpanded;

  final bool _isExpanded;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,

      alignment: Alignment.topCenter,
      child: _isExpanded
          ? Expanded(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  gridRowTable(),
                  const SizedBox(height: 12),
                  NoteSection(),
                  PaidProgrees(),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      TextIconButton(
                        buttonIcon: Icons.create_outlined,
                        buttonText: ButtonsDictionary.editItem,
                        onPress: () {},
                        buttonBackground: Color.fromRGBO(229, 236, 251, 1),
                        textColor: Color.fromRGBO(73, 120, 236, 1),
                        iconColor: Color.fromRGBO(73, 120, 236, 1),
                      ),
                      TextIconButton(
                        buttonIcon: Icons.wallet,
                        buttonText: ButtonsDictionary.approvePayment,
                        onPress: () {},
                        buttonBackground: Color.fromRGBO(236, 253, 245, 1),
                        textColor: Color.fromRGBO(4, 127, 119, 1),
                        iconColor: Color.fromRGBO(4, 127, 119, 1),
                      ),
                      TextIconButton(
                        buttonIcon: Icons.star_border_rounded,
                        buttonText: ButtonsDictionary.deleteStars,
                        onPress: () {},
                        buttonBackground: Color.fromRGBO(255, 251, 235, 1),
                        textColor: Color.fromRGBO(193, 114, 41, 1),
                        iconColor: Color.fromRGBO(193, 114, 41, 1),
                      ),
                      TextIconButton(
                        buttonIcon: Icons.delete_outline,
                        buttonText: ButtonsDictionary.deleteItem,
                        onPress: () {},
                        buttonBackground: Color.fromRGBO(254, 242, 242, 1),
                        textColor: Color.fromRGBO(252, 120, 126, 1),
                        iconColor: Color.fromRGBO(252, 120, 126, 1),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
