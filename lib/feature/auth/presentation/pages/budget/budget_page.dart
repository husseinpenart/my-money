import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:money/feature/auth/presentation/bloc/budget/budget_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/budget/budget_event.dart';
import 'package:money/feature/auth/presentation/bloc/budget/budget_state.dart';
import 'package:money/widgets/budget/budget_sheets.dart';
import 'package:money/widgets/budget/expenses_tab.dart';
import 'package:money/widgets/budget/history_tab.dart';
import 'package:money/widgets/budget/plan_tab.dart';
import 'package:money/widgets/budget/settings_tab.dart';
import 'package:money/widgets/contact/contact_style.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<BudgetBloc>()..add(const BudgetRefreshed()),
      child: const DefaultTabController(length: 4, child: _View()),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    return BlocListener<BudgetBloc, BudgetState>(
      listenWhen: (p, c) =>
          c.feedback != null && !identical(p.feedback, c.feedback),
      listener: (context, s) {
        final fb = s.feedback!;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: fb.isError
                  ? Colors.red.shade400
                  : Colors.green.shade600,
              content: Text(
                fb.message,
                style: sans(size: 13, color: Colors.white),
              ),
            ),
          );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'حقوق و هزینه‌ها',
                    style: sans(size: 20, weight: FontWeight.bold),
                  ),
                ),
                BlocBuilder<BudgetBloc, BudgetState>(
                  buildWhen: (p, c) => p.plan != c.plan || p.items != c.items,
                  builder: (context, s) => ElevatedButton.icon(
                    onPressed: () {
                      if (s.plan == null || s.plan!.needsSetup) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'ابتدا حقوق را تنظیم کن',
                              style: sans(size: 13, color: Colors.white),
                            ),
                          ),
                        );
                        return;
                      }
                      showExpenseSheet(context, items: s.items);
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      'ثبت هزینه',
                      style: sans(size: 12, weight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            labelColor: kAccent,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: kAccent,
            labelStyle: sans(size: 13, weight: FontWeight.bold),
            unselectedLabelStyle: sans(size: 13),
            tabs: const [
              Tab(text: 'برنامه'),
              Tab(text: 'هزینه‌ها'),
              Tab(text: 'تاریخچه'),
              Tab(text: 'تنظیمات'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [PlanTab(), ExpensesTab(), HistoryTab(), SettingsTab()],
            ),
          ),
        ],
      ),
    );
  }
}
