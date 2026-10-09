import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/auth/presentation/bloc/report/report_bloc.dart';
import 'package:money/widgets/report/report_format.dart';

class Heroinfo extends StatelessWidget {
  const Heroinfo({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<ReportBloc>().state.data?.summary;

    return Column(
      children: [
        Center(
          child: Text(
            ScreenDictionary.pureIncomeText,
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'sans',
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            s == null ? '—' : money(s.net), // 👈 خالص طلب واقعی
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'sans',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
