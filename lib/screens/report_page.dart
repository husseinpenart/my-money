import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/widgets/report/linear_indicator.dart';
import 'package:money/widgets/report/pie_chart_widget.dart';
import 'package:money/widgets/report/report_grid_card.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Center(
              child: Text(
                ScreenDictionary.dataReports,
                style: TextStyle(
                  fontFamily: 'sans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            /// financial report section
            ReportGridCard(),
            /// financial report section
            //  Pie chart card
            Center(
              child: Container(
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 3,
                      color: Colors.black.withValues(alpha: 0.30),
                      spreadRadius: 0,
                      offset: Offset(3, 2),
                      blurStyle: BlurStyle.normal,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      ScreenDictionary.debtRatio,
                      style: TextStyle(
                        fontFamily: 'sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    PieChartWidget(),
                  ],
                ),
              ),
            ),
            //  Pie chart card
            // Progrees bar item cards
            LinearIndicator()
            // Progrees bar item cards
          ],
        ),
      ),
    );
  }
}
