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

/// پیشنهادهای آماده؛ مبلغ را کاربر پر می‌کند
const _templates = <BudgetItem>[
  BudgetItem(
    name: 'قبض برق',
    category: 'Utilities',
    plannedAmount: 0,
    dueDay: 10,
  ),
  BudgetItem(
    name: 'قبض آب',
    category: 'Utilities',
    plannedAmount: 0,
    dueDay: 10,
    frequencyMonths: 3,
  ),
  BudgetItem(
    name: 'قبض گاز',
    category: 'Utilities',
    plannedAmount: 0,
    dueDay: 10,
  ),
  BudgetItem(
    name: 'اینترنت و موبایل',
    category: 'Utilities',
    plannedAmount: 0,
    dueDay: 5,
  ),
  BudgetItem(name: 'اجاره‌خانه', category: 'Rent', plannedAmount: 0, dueDay: 1),
  BudgetItem(
    name: 'قسط وام',
    category: 'Installment',
    plannedAmount: 0,
    dueDay: 15,
  ),
  BudgetItem(
    name: 'بیمه‌ی بدنه‌ی ماشین',
    category: 'Insurance',
    plannedAmount: 0,
    dueDay: 1,
    frequencyMonths: 12,
  ),
  BudgetItem(
    name: 'بیمه‌ی شخص ثالث',
    category: 'Insurance',
    plannedAmount: 0,
    dueDay: 1,
    frequencyMonths: 12,
  ),
  BudgetItem(
    name: 'بیمه‌ی تکمیلی / عمر',
    category: 'Insurance',
    plannedAmount: 0,
    dueDay: 1,
  ),
  BudgetItem(
    name: 'تعویض روغن ماشین',
    category: 'Car',
    plannedAmount: 0,
    dueDay: 15,
    frequencyMonths: 6,
  ),
  BudgetItem(name: 'بنزین', category: 'Car', plannedAmount: 0, isFixed: false),
  BudgetItem(
    name: 'خرید خانه',
    category: 'Groceries',
    plannedAmount: 0,
    isFixed: false,
  ),
  BudgetItem(
    name: 'درمان و دارو',
    category: 'Health',
    plannedAmount: 0,
    isFixed: false,
  ),
  BudgetItem(
    name: 'تفریح و بیرون',
    category: 'Fun',
    plannedAmount: 0,
    isFixed: false,
  ),
  BudgetItem(
    name: 'پس‌انداز ماهانه',
    category: 'Savings',
    plannedAmount: 0,
    dueDay: 1,
  ),
];

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  Future<void> _confirmDelete(BuildContext context, BudgetItem it) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'حذف از برنامه',
          style: sans(size: 15, weight: FontWeight.bold),
        ),
        content: Text(
          '«${it.name}» از برنامه‌ی دوره‌های بعد حذف شود؟\nهزینه‌های ثبت‌شده‌ی قبلی حفظ می‌شوند.',
          style: sans(size: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('انصراف', style: sans(size: 13)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'حذف',
              style: sans(size: 13, color: Colors.red.shade400),
            ),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted)
      context.read<BudgetBloc>().add(BudgetItemDeleted(it.itemId!));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      buildWhen: (p, c) =>
          p.items != c.items || p.profile != c.profile || p.plan != c.plan,
      builder: (context, s) {
        final curKey = s.plan?.cycleKey ?? 0;
        final p = s.profile;
        final used = s.items.map((i) => i.name).toSet();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // ───── حقوق ─────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: cardDeco(),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kAccent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.payments_outlined, color: kAccent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p?.title ?? 'حقوق تنظیم نشده',
                          style: sans(size: 13, weight: FontWeight.bold),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          p == null
                              ? 'مبلغ و روز دریافت را مشخص کن'
                              : '${money(p.amount)} · روز ${fa('${p.payDay}')} هر ماه',
                          style: sans(size: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => showProfileSheet(context, p),
                    child: Text(
                      p == null ? 'تنظیم' : 'ویرایش',
                      style: sans(size: 12),
                    ),
                  ),
                ],
              ),
            ),

            // ───── آیتم‌ها ─────
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 18, 2, 8),
              child: Row(
                children: [
                  Text(
                    'برنامه‌ی ثابت من',
                    style: sans(size: 13, weight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: p == null
                        ? null
                        : () => showItemSheet(context, curKey: curKey),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text('آیتم جدید', style: sans(size: 12)),
                  ),
                ],
              ),
            ),
            if (s.items.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: cardDeco(),
                child: Text(
                  'هنوز آیتمی نداری. از پیشنهادهای پایین شروع کن تا قبض‌ها، بیمه‌ها و بودجه‌ی خرج‌ها خودکار هر دوره در برنامه بیایند.',
                  style: sans(size: 12, color: Colors.grey.shade600),
                ),
              )
            else
              for (final it in s.items)
                _ItemTile(
                  item: it,
                  onEdit: () =>
                      showItemSheet(context, item: it, curKey: curKey),
                  onDelete: () => _confirmDelete(context, it),
                ),

            // ───── پیشنهادها ─────
            if (p != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 20, 2, 8),
                child: Text(
                  'افزودن سریع از پیشنهادها',
                  style: sans(size: 13, weight: FontWeight.bold),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in _templates.where(
                    (t) => !used.contains(t.name),
                  ))
                    ActionChip(
                      avatar: Icon(
                        BudgetCategory.of(t.category).icon,
                        size: 16,
                        color: BudgetCategory.of(t.category).color,
                      ),
                      label: Text(t.name, style: sans(size: 12)),
                      onPressed: () =>
                          showItemSheet(context, item: t, curKey: curKey),
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ItemTile extends StatelessWidget {
  final BudgetItem item;
  final VoidCallback onEdit, onDelete;
  const _ItemTile({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cat = BudgetCategory.of(item.category);
    final freq = kFrequencies[item.frequencyMonths] ?? '';
    final sub = item.isFixed
        ? '$freq · سررسید روز ${fa('${item.dueDay}')}'
        : 'بودجه‌ی متغیر · $freq';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      decoration: cardDeco(),
      child: Row(
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
                Text(item.name, style: sans(size: 13, weight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(sub, style: sans(size: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Text(
            money(item.plannedAmount),
            style: sans(size: 13, weight: FontWeight.bold),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              size: 20,
              color: Colors.grey.shade600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Text('ویرایش', style: sans(size: 13)),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('حذف', style: sans(size: 13, color: kRed)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
