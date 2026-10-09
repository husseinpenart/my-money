import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/auth/presentation/bloc/report/report_bloc.dart';
import 'package:money/feature/model/report/report_models.dart';
import 'package:money/widgets/global/GlassContainer.dart';
import 'package:money/widgets/report/report_format.dart';

class Herocountitems extends StatelessWidget {
  const Herocountitems({super.key});

  String _v(int? n) => n == null ? '—' : fa('$n');

  // «در جریان» = پرداختِ جزئی. در ReportSummary فعلی فیلدی برای آن نیست،
  // پس فعلاً '—'. وقتی بک‌اند summary.inProgressCount را اضافه کرد،
  // این getter را به `s?.inProgressCount` تغییر بده (و فیلد اختیاری را
  // به ReportSummary اضافه کن).
  int? _inProgress(ReportSummary? s) => null;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<ReportBloc>().state.data?.summary;

    return Container(
      padding: const EdgeInsets.all(7),
      child: Center(
        child: GlassContainer(
          containerWidth: 400,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _cell(_v(s?.paidCount), ScreenDictionary.paidText),
                _cell(_v(_inProgress(s)), ScreenDictionary.paidInProgressText),
                _cell(_v(s?.unpaidCount), ScreenDictionary.notPaidText),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cell(String value, String label) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'sans',
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: TextStyle(
          fontFamily: 'sans',
          fontSize: 10,
          color: Colors.grey[400],
        ),
      ),
    ],
  );
}
