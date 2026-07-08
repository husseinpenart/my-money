import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';

class NoteSection extends StatelessWidget {
  const NoteSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color.fromRGBO(230, 226, 226, 1)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  children: [
                    WidgetSpan(
                      child: Text(
                        ScreenDictionary.note,
                        style: TextStyle(
                          fontFamily: 'sans',
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                    const WidgetSpan(child: SizedBox(width: 6)),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        Icons.sticky_note_2_outlined,
                        size: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            'قرض شخصی برای اجاره خانه قرض شخصی برای اجاره خانه قرض شخصی برای اجاره خانهقرض شخصی برای اجاره خانهقرض شخصی برای اجاره خانهقرض شخصی برای اجاره خانهقرض شخصی برای اجاره خانهقرض شخصی برای اجاره خانهقرض',
            style: TextStyle(fontFamily: 'sans', fontSize: 12),
          ),
        ],
      ),
    );
  }
}


