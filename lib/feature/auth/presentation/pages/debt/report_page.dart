import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/network/api_client.dart';
import 'package:money/feature/auth/presentation/bloc/report/report_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/report/report_event.dart';
import 'package:money/feature/auth/presentation/bloc/report/report_state.dart';
import 'package:money/feature/data/dataResource/report_remote_data_source.dart';
import 'package:money/feature/model/report/report_models.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/report/report_sections.dart';


class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReportBloc>(
      create: (_) => ReportBloc(
        remoteDataSource: ReportRemoteDataSource(GetIt.I<ApiClient>()),
      )..add(const ReportRequested(period: ReportPeriod.all)),
      child: const _ReportView(),
    );
  }
}

class _ReportView extends StatelessWidget {
  const _ReportView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('گزارشات', style: sans(size: 16, weight: FontWeight.bold)),
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state.status == ReportStatus.initial ||
              (state.status == ReportStatus.loading && state.data == null)) {
            return const Center(
              child: CircularProgressIndicator(color: kAccent),
            );
          }

          if (state.status == ReportStatus.failure && state.data == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 44,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    state.error ?? 'دریافت گزارش ناموفق بود',
                    textAlign: TextAlign.center,
                    style: sans(size: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.read<ReportBloc>().add(
                      const ReportRequested(period: ReportPeriod.all),
                    ),
                    child: Text('تلاش دوباره', style: sans(size: 12)),
                  ),
                ],
              ),
            );
          }

          final data = state.data!;
          final bloc = context.read<ReportBloc>();

          return RefreshIndicator(
            color: kAccent,
            onRefresh: () async {
              bloc.add(ReportRequested(period: state.period));
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              children: [
                ReportPeriodBar(
                  selected: state.period,
                  onChanged: (p) => bloc.add(ReportRequested(period: p)),
                ),
                const SizedBox(height: 14),
                ReportKpiGrid(s: data.summary),
                const SizedBox(height: 14),
                OutstandingDonutCard(s: data.summary),
                const SizedBox(height: 14),
                RatesCard(s: data.summary),
                const SizedBox(height: 14),
                MonthlyChartCard(months: data.monthly),
                const SizedBox(height: 14),
                AgingCard(buckets: data.aging),
                const SizedBox(height: 14),
                TopContactsCard(contacts: data.topContacts),
                const SizedBox(height: 14),
                ReportFooter(data: data, period: state.period),
              ],
            ),
          );
        },
      ),
    );
  }
}
