import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/budget/budget_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/budget/budget_event.dart';
import 'package:money/feature/auth/presentation/bloc/budget/budget_state.dart';
import 'package:money/feature/model/budget/budget_models.dart';
import 'package:money/widgets/budget/budget_widgets.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/report/report_format.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      buildWhen: (p, c) => p.history != c.history || p.status != c.status,
      builder: (context, s) {
        if (s.plan == null)
          return const Center(child: CircularProgressIndicator(color: kAccent));
        if (s.history.isEmpty) {
          return const EmptyBox(
            icon: Icons.history_rounded,
            text:
                'بعد از تنظیم حقوق و ثبت اولین هزینه‌ها، تاریخچه‌ی هر دوره اینجا ساخته می‌شود.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          itemCount: s.history.length,
          itemBuilder: (context, i) =>
              _CycleCard(c: s.history[i], isCurrent: i == 0),
        );
      },
    );
  }
}

class _CycleCard extends StatelessWidget {
  final CycleSummary c;
  final bool isCurrent;
  const _CycleCard({required this.c, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final ratio = c.salary <= 0
        ? 0.0
        : (c.spent / c.salary).clamp(0.0, 1.0).toDouble();
    final over = c.saved < 0;
    final color = over ? kRed : (ratio > 0.85 ? kAmber : kGreen);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: cardDeco(),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.read<BudgetBloc>().add(
            BudgetCycleSelected(isCurrent ? null : c.cycleKey),
          );
          DefaultTabController.of(context).animateTo(0);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    cycleLabel(c.cycleKey),
                    style: sans(size: 14, weight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  if (isCurrent) const StatusChip('جاری', kAccent),
                  const Spacer(),
                  Text(
                    '${fa('${c.count}')} هزینه',
                    style: sans(size: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
              if (c.start != null && c.end != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '${jalaliDate(c.start!)} تا ${jalaliDate(c.end!)}',
                    style: sans(size: 10, color: Colors.grey.shade500),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _stat(
                    c.estimated ? 'حقوق (تخمینی)' : 'حقوق',
                    money(c.salary),
                    Colors.black87,
                  ),
                  _stat('خرج', money(c.spent), kRed),
                  _stat(
                    over ? 'کسری' : 'باقی‌مانده',
                    money(c.saved.abs()),
                    over ? kRed : kGreen,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 7,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              if (c.top.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final t in c.top)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: BudgetCategory.of(
                            t.category,
                          ).color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              BudgetCategory.of(t.category).icon,
                              size: 12,
                              color: BudgetCategory.of(t.category).color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${BudgetCategory.of(t.category).label}: ${compact(t.spent)}',
                              style: sans(size: 10, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: sans(size: 10, color: Colors.grey.shade600)),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            value,
            style: sans(size: 13, weight: FontWeight.bold, color: color),
          ),
        ),
      ],
    ),
  );
}
