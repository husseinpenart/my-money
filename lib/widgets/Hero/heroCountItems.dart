import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/auth/presentation/bloc/report/report_bloc.dart';
import 'package:money/widgets/Hero/animated_number_text.dart';
import 'package:money/widgets/global/GlassContainer.dart';
import 'package:money/widgets/report/report_format.dart';

class Herocountitems extends StatelessWidget {
  const Herocountitems({super.key});

  String _fmt(num v) => fa(v.round().toString());

  Widget _val(int? n) => n == null
      ? const Text(
          '—',
          style: TextStyle(
            fontFamily: 'sans',
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )
      : AnimatedNumberText(
          value: n,
          format: _fmt,
          style: const TextStyle(
            fontFamily: 'sans',
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );

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
                _cell(_val(s?.paidCount), ScreenDictionary.paidText),
                _cell(_val(null), ScreenDictionary.paidInProgressText),
                _cell(_val(s?.unpaidCount), ScreenDictionary.notPaidText),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cell(Widget value, String label) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      value,
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
