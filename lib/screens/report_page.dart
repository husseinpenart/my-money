import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/auth/presentation/bloc/report/report_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/report/report_event.dart';
import 'package:money/feature/auth/presentation/bloc/report/report_state.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/report/report_format.dart';
import 'package:money/widgets/report/report_sections.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<ReportBloc>()..add(const ReportRequested()),
      child: const _ReportView(),
    );
  }
}

class _ReportView extends StatelessWidget {
  const _ReportView();

  Future<void> _refresh(BuildContext context) {
    final done = Completer<void>();
    context.read<ReportBloc>().add(ReportRequested(done: done));
    return done.future;
  }

  Future<void> _copy(BuildContext context, ReportState s) async {
    if (s.data == null) return;
    await Clipboard.setData(
      ClipboardData(text: buildReportText(s.data!, s.period)),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade600,
          content: Text(
            'خلاصه‌ی گزارش کپی شد',
            style: sans(size: 13, color: Colors.white),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportBloc, ReportState>(
      builder: (context, state) {
        final data = state.data;
        final loading =
            state.status == ReportStatus.loading ||
            state.status == ReportStatus.initial;

        return RefreshIndicator(
          color: kAccent,
          onRefresh: () => _refresh(context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ───── عنوان + عملیات ─────
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'کپی خلاصه‌ی گزارش',
                          onPressed: data == null
                              ? null
                              : () => _copy(context, state),
                          icon: const Icon(Icons.copy_all_outlined, size: 22),
                        ),
                        Expanded(
                          child: Text(
                            ScreenDictionary.dataReports,
                            textAlign: TextAlign.center,
                            style: sans(size: 20, weight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          tooltip: 'بازخوانی',
                          onPressed: loading ? null : () => _refresh(context),
                          icon: const Icon(Icons.refresh, size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ReportPeriodBar(
                      selected: state.period,
                      onChanged: (p) => context.read<ReportBloc>().add(
                        ReportRequested(period: p),
                      ),
                    ),
                    const SizedBox(height: 8),

                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: loading && data != null ? 1 : 0,
                      child: const LinearProgressIndicator(
                        minHeight: 2,
                        color: kAccent,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (state.status == ReportStatus.failure && data != null)
                      _Banner(
                        text:
                            '${state.error ?? 'بروزرسانی ناموفق بود'}\nداده‌های قبلی نمایش داده می‌شود.',
                      ),

                    ..._body(context, state),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _body(BuildContext context, ReportState state) {
    final data = state.data;

    if (data == null) {
      if (state.status == ReportStatus.failure) {
        return [
          const SizedBox(height: 60),
          Icon(Icons.error_outline, size: 44, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            state.error ?? 'خطا در دریافت گزارش',
            textAlign: TextAlign.center,
            style: sans(size: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          Center(
            child: OutlinedButton(
              onPressed: () =>
                  context.read<ReportBloc>().add(const ReportRequested()),
              child: Text('تلاش دوباره', style: sans(size: 12)),
            ),
          ),
        ];
      }
      return const [
        SizedBox(height: 80),
        Center(child: CircularProgressIndicator(color: kAccent)),
      ];
    }

    if (data.summary.recordCount == 0) {
      return [
        const SizedBox(height: 60),
        Icon(Icons.insights_outlined, size: 44, color: Colors.grey.shade400),
        const SizedBox(height: 10),
        Text(
          'در این بازه رکوردی برای گزارش وجود ندارد',
          textAlign: TextAlign.center,
          style: sans(size: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        ReportFooter(data: data, period: state.period),
      ];
    }

    const gap = SizedBox(height: 14);
    return [
      ReportKpiGrid(s: data.summary),
      gap,
      OutstandingDonutCard(s: data.summary),
      gap,
      RatesCard(s: data.summary),
      gap,
      MonthlyChartCard(months: data.monthly),
      gap,
      AgingCard(buckets: data.aging),
      gap,
      TopContactsCard(contacts: data.topContacts),
      gap,
      ReportFooter(data: data, period: state.period),
    ];
  }
}

class _Banner extends StatelessWidget {
  final String text;
  const _Banner({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(text, style: sans(size: 12, color: Colors.red.shade400)),
  );
}
