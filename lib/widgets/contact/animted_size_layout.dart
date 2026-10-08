import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/layouts/approve_payment.dart';
import 'package:money/layouts/confirm_demand_layout.dart';
import 'package:money/widgets/contact/grid_row_table.dart';
import 'package:money/widgets/contact/note_section.dart';
import 'package:money/widgets/contact/paid_progress.dart';
import 'package:money/widgets/global/text_icon_button.dart';

class AnimatedSizeLayout extends StatefulWidget {
  const AnimatedSizeLayout({
    super.key,
    required bool isExpanded,
    this.record, // 👈 اختیاری: برای پر شدن واقعی فرم ویرایش
  }) : _isExpanded = isExpanded;

  final bool _isExpanded;
  final SearchDebt? record;

  @override
  State<AnimatedSizeLayout> createState() => _AnimatedSizeLayoutState();
}

class _AnimatedSizeLayoutState extends State<AnimatedSizeLayout> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: widget._isExpanded
          // 👈 به‌جای Expanded(...) : داخل AnimatedSize باید Column با min باشد
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
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
                      onPress: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          // 👈 showDebtFormSheet = پارامترهای درست + BlocProvider
                          showDebtFormSheet(
                            context,
                            hasDebt: true,
                            editTitle: true,
                            initial: widget.record,
                          );
                        });
                      },
                      buttonBackground: const Color.fromRGBO(229, 236, 251, 1),
                      textColor: const Color.fromRGBO(73, 120, 236, 1),
                      iconColor: const Color.fromRGBO(73, 120, 236, 1),
                    ),
                    TextIconButton(
                      buttonIcon: Icons.wallet,
                      buttonText: ButtonsDictionary.approvePayment,
                      onPress: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext sheetContext) {
                              return RecordPayment();
                            },
                          );
                        });
                      },
                      buttonBackground: const Color.fromRGBO(236, 253, 245, 1),
                      textColor: const Color.fromRGBO(4, 127, 119, 1),
                      iconColor: const Color.fromRGBO(4, 127, 119, 1),
                    ),
                    TextIconButton(
                      buttonIcon: Icons.star_border_rounded,
                      buttonText: ButtonsDictionary.deleteStars,
                      onPress: () {},
                      buttonBackground: const Color.fromRGBO(255, 251, 235, 1),
                      textColor: const Color.fromRGBO(193, 114, 41, 1),
                      iconColor: const Color.fromRGBO(193, 114, 41, 1),
                    ),
                    TextIconButton(
                      buttonIcon: Icons.delete_outline,
                      buttonText: ButtonsDictionary.deleteItem,
                      onPress: () {},
                      buttonBackground: const Color.fromRGBO(254, 242, 242, 1),
                      textColor: const Color.fromRGBO(252, 120, 126, 1),
                      iconColor: const Color.fromRGBO(252, 120, 126, 1),
                    ),
                  ],
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}
