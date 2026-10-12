import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/auth/presentation/bloc/report/report_bloc.dart';
import 'package:money/helper/utils/currency_scope.dart';
import 'package:money/widgets/Hero/animated_number_text.dart';
import 'package:money/widgets/global/GlassContainer.dart';

class Herocontainergrid extends StatelessWidget {
  const Herocontainergrid({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<ReportBloc>().state.data?.summary;
    final cur = CurrencyScope.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          Expanded(
            child: _tile(
              icon: Icons
                  .south_west_rounded, // طلب = ورودی (بدون Transform.rotate)
              iconBg: Colors.lightGreen,
              iconFg: const Color(0xFF15803D),
              label: ScreenDictionary.demandText,
              value: s?.unpaidReceivable,
              unitColor: const Color(0xFF40FF27),
              cur: cur,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _tile(
              icon: Icons.north_east_rounded, // بدهی = خروجی
              iconBg: const Color(0xFFFF7B71),
              iconFg: const Color(0xFF9E2118),
              label: ScreenDictionary.debtsText,
              value: s?.unpaidDebt,
              unitColor: const Color(0xFFFF7B71),
              cur: cur,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required String label,
    required num? value,
    required Color unitColor,
    required CurrencyScope cur,
  }) {
    return GlassContainer(
      // 👈 FittedBox دور کل محتوا: اگر ۰.۷۶px (یا بیشتر) اضافه آمد، scale می‌کند
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center, // 👈 به‌جای start
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(icon, color: iconFg, size: 13),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min, // 👈 فقط به اندازه‌ی محتوا
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'sans',
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    height: 1.2, // 👈 line-height کنترل‌شده تا overflow ندهد
                  ),
                ),
                const SizedBox(height: 3), // 👈 width:8 غلط → height:3
                AnimatedNumberText(
                  value: value ?? 0,
                  format: cur.format,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'sans',
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    height: 1.15,
                  ),
                ),
                if (value == null)
                  const Text(
                    '—',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'sans',
                      fontSize: 18,
                      height: 1.15,
                    ),
                  ),
                Text(
                  cur.label,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    color: unitColor,
                    fontFamily: 'sans',
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
