import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/widgets/global/Indicator.dart';

class PieChartWidget extends StatefulWidget {
  const PieChartWidget({super.key});

  @override
  State<PieChartWidget> createState() => _PieChartWidget();
}

class _PieChartWidget extends State<PieChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Row(
        children: <Widget>[
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 60,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Indicator(
                color: Color.fromRGBO(56, 113, 237, 1),
                text: ScreenDictionary.wholeDemand,
                isSquare: true,
              ),
              SizedBox(height: 4),
              Indicator(
                color: Color.fromRGBO(242, 101, 101, 1),
                text: ScreenDictionary.wholeDebt,
                isSquare: true,
              ),
              SizedBox(height: 4),
              Indicator(
                color: Color.fromRGBO(86, 207, 165, 1),
                text: ScreenDictionary.paidDebt,
                isSquare: true,
              ),
              SizedBox(height: 4),
              Indicator(
                color: Color.fromRGBO(248, 182, 69, 1),
                text: ScreenDictionary.wholeReminded,
                isSquare: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Color.fromRGBO(56, 113, 237, 1),
            value: 40,
            title: '40%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
              fontFamily: 'sans',
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Color.fromRGBO(242, 101, 101, 1),
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
              fontFamily: 'sans',
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Color.fromRGBO(86, 207, 165, 1),
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
              fontFamily: 'sans',
            ),
          );
        case 3:
          return PieChartSectionData(
            color: Color.fromRGBO(248, 182, 69, 1),
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
              fontFamily: 'sans',
            ),
          );
        default:
          throw Exception("Invalid section");
      }
    });
  }
}
