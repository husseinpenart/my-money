import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/auth/presentation/bloc/report/report_bloc.dart';
import 'package:money/helper/utils/currency_scope.dart';
import 'package:money/widgets/Hero/animated_number_text.dart';

class Heroinfo extends StatelessWidget {
  const Heroinfo({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<ReportBloc>().state.data?.summary;
    final cur = CurrencyScope.of(context);

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
          child: s == null
              ? const Text(
                  '—',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'sans',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : AnimatedNumberText(
                  value: s.net,
                  format: cur.format, // 👈 با واحد فعلی تبدیل+فرمت
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