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
            height: 1.2,
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
            height: 1.2,
          ),
        );

  @override
  Widget build(BuildContext context) {
    final s = context.watch<ReportBloc>().state.data?.summary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: GlassContainer(
        // 👈 containerWidth: 400 حذف شد؛ حالا با عرض والد (Expanded) scale می‌شود
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _cell(_val(s?.paidCount), ScreenDictionary.paidText),
            _cell(_val(null), ScreenDictionary.paidInProgressText),
            _cell(_val(s?.unpaidCount), ScreenDictionary.notPaidText),
          ],
        ),
      ),
    );
  }

  Widget _cell(Widget value, String label) => Expanded(
    // 👈 Expanded به‌جای ستون آزاد: سه خانه مساوی، هیچ‌کدام overflow نمی‌دهد
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        value,
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'sans',
            fontSize: 10,
            color: Colors.white70,
            height: 1.2,
          ),
        ),
      ],
    ),
  );
}
