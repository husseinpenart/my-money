import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/budget/budget_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/budget/budget_event.dart';
import 'package:money/feature/auth/presentation/bloc/budget/budget_state.dart';
import 'package:money/feature/model/budget/budget_models.dart';
import 'package:money/widgets/budget/budget_sheets.dart';
import 'package:money/widgets/budget/budget_widgets.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/report/report_format.dart';

class PlanTab extends StatelessWidget {
  const PlanTab({super.key});

  Future<void> _refresh(BuildContext context) {
    final done = Completer<void>();
    context.read<BudgetBloc>().add(BudgetRefreshed(done: done));
    return done.future;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      buildWhen: (p, c) =>
          p.plan != c.plan || p.status != c.status || p.items != c.items,
      builder: (context, s) {
        final plan = s.plan;
        if (plan == null) {
          if (s.status == BudgetStatus.failure) {
            return EmptyBox(
              icon: Icons.error_outline,
              text: s.error ?? 'خطا در دریافت اطلاعات',
              action: 'تلاش دوباره',
              onAction: () =>
                  context.read<BudgetBloc>().add(const BudgetRefreshed()),
            );
          }
          return const Center(child: CircularProgressIndicator(color: kAccent));
        }

        if (plan.needsSetup) {
          return EmptyBox(
            icon: Icons.account_balance_wallet_outlined,
            text:
                'برای شروع، مبلغ حقوق و روز دریافت آن را تنظیم کن تا برنامه‌ی هر دوره خودکار چیده شود.',
            action: 'تنظیم حقوق',
            onAction: () => showProfileSheet(context, s.profile),
          );
        }

        return RefreshIndicator(
          color: kAccent,
          onRefresh: () => _refresh(context),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _CycleBar(plan: plan),
              const SizedBox(height: 12),
              if (plan.isCurrent && !plan.salaryConfirmed)
                _ConfirmBanner(plan: plan),
              _SummaryCard(plan: plan),
              const SizedBox(height: 12),
              ..._alerts(plan),
              _sectionTitle(
                'برنامه‌ی این دوره',
                '${fa('${plan.items.length}')} مورد',
              ),
              if (plan.items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: cardDeco(),
                  child: Text(
                    'هنوز آیتمی در برنامه نیست یا موردی در این دوره سررسید ندارد. از تب «تنظیمات» قبض‌ها، بیمه‌ها و بودجه‌ی خرج‌ها را اضافه کن.',
                    style: sans(size: 12, color: Colors.grey.shade600),
                  ),
                )
              else
                for (final p in plan.items) _PlanItemTile(p: p, items: s.items),
              if (plan.categories.isNotEmpty) ...[
                _sectionTitle('تفکیک دسته‌ها', ''),
                _CategoriesCard(cats: plan.categories),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String t, String trailing) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 16, 2, 8),
    child: Row(
      children: [
        Text(t, style: sans(size: 13, weight: FontWeight.bold)),
        const Spacer(),
        Text(trailing, style: sans(size: 11, color: Colors.grey.shade600)),
      ],
    ),
  );

  List<Widget> _alerts(BudgetPlan p) {
    final a = <(IconData, String, Color)>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final overdue = p.items.where((i) => i.status == 'overdue').length;
    if (overdue > 0) {
      a.add((
        Icons.warning_amber_rounded,
        '${fa('$overdue')} مورد سررسیدگذشته هنوز پرداخت نشده است',
        kRed,
      ));
    }
    if (p.committed > p.salary) {
      a.add((
        Icons.error_outline,
        'تعهدات این دوره (${money(p.committed)}) از حقوق بیشتر است',
        kRed,
      ));
    } else if (p.free < 0) {
      a.add((
        Icons.trending_down,
        'هزینه‌های خارج از برنامه از مبلغ آزاد بیشتر شده است',
        kRed,
      ));
    }
    if (p.isCurrent) {
      for (final i in p.items) {
        final d = i.dueDate?.toLocal();
        if (!i.isFixed || d == null || i.status == 'paid') continue;
        final days = DateTime(d.year, d.month, d.day).difference(today).inDays;
        if (days >= 0 && days <= 3) {
          a.add((
            Icons.alarm,
            days == 0
                ? 'سررسید «${i.name}» امروز است'
                : 'تا سررسید «${i.name}» ${fa('$days')} روز مانده',
            kAmber,
          ));
        }
      }
    }
    return [
      for (final (icon, text, color) in a)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(text, style: sans(size: 12, color: Colors.black87)),
              ),
            ],
          ),
        ),
    ];
  }
}

// ───────────────────── انتخاب دوره ─────────────────────
class _CycleBar extends StatelessWidget {
  final BudgetPlan plan;
  const _CycleBar({required this.plan});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BudgetBloc>();
    final range = (plan.start != null && plan.end != null)
        ? '${jalaliDate(plan.start!)}  تا  ${jalaliDate(plan.end!)}'
        : '';
    return Row(
      children: [
        IconButton(
          tooltip: 'دوره‌ی قبل',
          onPressed: () => bloc.add(BudgetCycleSelected(plan.cycleKey - 1)),
          icon: const Icon(Icons.chevron_right_rounded),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                cycleLabel(plan.cycleKey),
                style: sans(size: 15, weight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(range, style: sans(size: 11, color: Colors.grey.shade600)),
            ],
          ),
        ),
        IconButton(
          tooltip: 'دوره‌ی بعد',
          onPressed: plan.isCurrent
              ? null
              : () => bloc.add(BudgetCycleSelected(plan.cycleKey + 1)),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
      ],
    );
  }
}

class _ConfirmBanner extends StatelessWidget {
  final BudgetPlan plan;
  const _ConfirmBanner({required this.plan});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFEFF4FF),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        const Icon(Icons.payments_outlined, color: kAccent),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'حقوق این دوره را دریافت کردی؟ مبلغ واقعی را ثبت کن تا محاسبه دقیق شود.',
            style: sans(size: 12),
          ),
        ),
        TextButton(
          onPressed: () => showSalaryConfirmSheet(context, plan.salary),
          child: Text(
            'ثبت',
            style: sans(size: 12, weight: FontWeight.bold, color: kAccent),
          ),
        ),
      ],
    ),
  );
}

// ───────────────────── خلاصه ─────────────────────
class _SummaryCard extends StatelessWidget {
  final BudgetPlan plan;
  const _SummaryCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final p = plan;
    final used = p.salary <= 0
        ? 0.0
        : (p.spent / p.salary).clamp(0.0, 1.0).toDouble();
    final over = p.spent > p.salary;

    Widget mini(String label, String value, Color c) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: sans(size: 10, color: Colors.white70)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                style: sans(size: 13, weight: FontWeight.bold, color: c),
              ),
            ),
          ],
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF1E3A8A), Color(0xFF3B5BDB)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B5BDB).withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(p.salaryTitle, style: sans(size: 12, color: Colors.white70)),
              const SizedBox(width: 6),
              StatusChip(
                p.salaryConfirmed ? 'تأییدشده' : 'ثابت ماهانه',
                p.salaryConfirmed ? const Color(0xFF86EFAC) : Colors.white70,
              ),
              const Spacer(),
              if (p.isCurrent)
                Text(
                  '${fa('${p.daysLeft}')} روز تا حقوق بعدی',
                  style: sans(size: 11, color: Colors.white70),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            money(p.salary),
            style: sans(size: 26, weight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'خرج‌شده ${money(p.spent)}',
                style: sans(size: 11, color: Colors.white),
              ),
              const Spacer(),
              Text(
                pct(p.salary <= 0 ? 0 : p.spent / p.salary),
                style: sans(size: 11, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: used,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation(
                over ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              mini('تعهدات دوره', money(p.committed), Colors.white),
              const SizedBox(width: 8),
              mini(
                'مبلغ آزاد',
                money(p.free),
                p.free < 0 ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC),
              ),
              const SizedBox(width: 8),
              mini(
                'سقف خرج روزانه',
                p.isCurrent ? money(p.dailyAllowance) : '—',
                Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'مانده‌ی حقوق: ${money(p.remaining)}',
            style: sans(
              size: 11,
              color: p.remaining < 0 ? const Color(0xFFFCA5A5) : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────── آیتم برنامه ─────────────────────
class _PlanItemTile extends StatelessWidget {
  final PlanItem p;
  final List<BudgetItem> items;
  const _PlanItemTile({required this.p, required this.items});

  @override
  Widget build(BuildContext context) {
    final cat = BudgetCategory.of(p.category);
    final (label, color) = statusInfo(p.status);
    final ratio = p.planned <= 0
        ? 0.0
        : (p.spent / p.planned).clamp(0.0, 1.0).toDouble();
    final canPay = p.status != 'paid';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: cardDeco(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(cat.icon, size: 18, color: cat.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sans(size: 14, weight: FontWeight.bold),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      p.isFixed && p.dueDate != null
                          ? 'سررسید: ${jalaliDate(p.dueDate!)}'
                          : 'بودجه‌ی متغیر این دوره',
                      style: sans(size: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              StatusChip(label, color),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${money(p.spent)} از ${money(p.planned)}',
                style: sans(size: 11, color: Colors.grey.shade700),
              ),
              const Spacer(),
              if (canPay)
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => showExpenseSheet(
                    context,
                    items: items,
                    itemId: p.itemId,
                    amount: p.isFixed ? p.remaining : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          size: 16,
                          color: kAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          p.isFixed ? 'ثبت پرداخت' : 'ثبت خرج',
                          style: sans(
                            size: 12,
                            weight: FontWeight.bold,
                            color: kAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoriesCard extends StatelessWidget {
  final List<CategoryTotal> cats;
  const _CategoriesCard({required this.cats});

  @override
  Widget build(BuildContext context) {
    final maxV = cats.fold<double>(
      0,
      (m, c) => [m, c.planned, c.spent].reduce((a, b) => a > b ? a : b),
    );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: cardDeco(),
      child: Column(
        children: [
          for (final c in cats)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        BudgetCategory.of(c.category).icon,
                        size: 16,
                        color: BudgetCategory.of(c.category).color,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          BudgetCategory.of(c.category).label,
                          style: sans(size: 12),
                        ),
                      ),
                      Text(
                        money(c.spent),
                        style: sans(size: 12, weight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: maxV <= 0 ? 0 : c.planned / maxV,
                          minHeight: 7,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation(
                            BudgetCategory.of(
                              c.category,
                            ).color.withValues(alpha: 0.28),
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: maxV <= 0 ? 0 : c.spent / maxV,
                          minHeight: 7,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation(
                            BudgetCategory.of(c.category).color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (c.planned > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'برنامه: ${money(c.planned)}',
                        style: sans(size: 10, color: Colors.grey.shade600),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
