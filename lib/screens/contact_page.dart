import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';
import 'dart:math' as math;

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});
  @override
  State<StatefulWidget> createState() => _ContactPage();
}

class _ContactPage extends State<ContactPage> {
  bool _isExpanded = false;
  void handleISExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Column(
          spacing: 20.0,
          children: [
            Text(
              BottomNavigations.contacts,
              style: TextStyle(
                fontFamily: 'sans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 2,
                    blurStyle: BlurStyle.normal,
                    color: Colors.black.withValues(alpha: 0.55),
                    offset: Offset(4, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10.0,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.purple,
                    ),
                    child: Center(
                      child: Text(
                        'ح',
                        style: TextStyle(
                          fontFamily: 'sans',
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10.0,
                    children: [
                      Text(
                        'حسین اسدی',
                        style: TextStyle(fontFamily: 'sans', fontSize: 14),
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Icon(
                                Icons.phone_enabled_outlined,
                                size: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                            TextSpan(
                              text: '09039414838',
                              style: TextStyle(
                                fontFamily: 'sans',
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text(
                        '45,000,000',
                        style: TextStyle(fontFamily: 'sans', fontSize: 14),
                      ),
                      Text(
                        ScreenDictionary.demand,
                        style: TextStyle(
                          fontFamily: 'sans',
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      handleISExpanded();
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 250),

                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Color.fromRGBO(238, 242, 255, 1),
                      ),
                      child: AnimatedRotation(
                        turns: _isExpanded ? 0.25 : 0.0,
                        duration: Duration(microseconds: 250),
                        child: Transform.rotate(
                          angle: 180 * math.pi / 180,
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 15,
                            color: Color.fromRGBO(169, 174, 188, 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: Duration(microseconds: 250),
              curve: Curves.elasticInOut,
              child: _isExpanded
                  ? Column(
                      children: [const Divider(), const SizedBox(height: 10)],
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
