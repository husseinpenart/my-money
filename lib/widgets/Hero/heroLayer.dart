import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/network/api_client.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/auth/presentation/bloc/report/report_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/report/report_event.dart';
import 'package:money/feature/data/dataResource/report_remote_data_source.dart';
import 'package:money/feature/model/report/report_models.dart';
import 'package:money/helper/utils/currency_scope.dart';
import 'package:money/widgets/Hero/heroContainerGrid.dart';
import 'package:money/widgets/Hero/heroCountItems.dart';
import 'package:money/widgets/Hero/heroInfo.dart';
import 'package:money/widgets/global/GlassContainer.dart';
import 'package:money/widgets/report/report_format.dart';

const _green = Color(0xFF16A34A);
const _blue = Color.fromRGBO(37, 99, 235, 1);
const _orange = Color(0xFFF59E0B);

class Herolayer extends StatefulWidget {
  const Herolayer({super.key});

  @override
  State<Herolayer> createState() => _HerolayerState();
}

class _HerolayerState extends State<Herolayer> {
  late final ReportBloc _bloc;
  CurrencyUnit _unit = CurrencyUnit.toman;

  @override
  void initState() {
    super.initState();
    _bloc = ReportBloc(
      remoteDataSource: ReportRemoteDataSource(GetIt.I<ApiClient>()),
    )..add(const ReportRequested(period: ReportPeriod.all));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _toggleUnit() {
    HapticFeedback.selectionClick();
    setState(() {
      _unit = _unit == CurrencyUnit.toman
          ? CurrencyUnit.rial
          : CurrencyUnit.toman;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: CurrencyScope(
        unit: _unit,
        toggle: _toggleUnit,
        child: const _HeroLayerBody(),
      ),
    );
  }
}

class _HeroLayerBody extends StatelessWidget {
  const _HeroLayerBody();

  @override
  Widget build(BuildContext context) {
    final cur = CurrencyScope.of(context);

    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(99, 48, 40, 39),
            blurRadius: 50,
            offset: Offset(15, 45),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.centerRight,
          colors: [
            Color.fromARGB(255, 4, 19, 58),
            Color.fromARGB(255, 22, 53, 139),
            Color.fromARGB(255, 62, 105, 197),
            Color.fromARGB(255, 77, 118, 199),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white54,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    ScreenDictionary.myWalllet,
                    style: TextStyle(
                      color: Colors.grey[200],
                      fontFamily: 'sans',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // 👈 refresh آمار
                  IconButton(
                    tooltip: 'به‌روزرسانی آمار',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => context.read<ReportBloc>().add(
                      const ReportRequested(period: ReportPeriod.all),
                    ),
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // 👈 دکمه‌ی تبدیل واحد
                  GestureDetector(
                    onTap: cur.toggle,
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      containerWidth: 90,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cur.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'sans',
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.swap_vert,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Heroinfo(),
          const SizedBox(height: 20),
          const Herocontainergrid(),
          const SizedBox(height: 10),
          const Herocountitems(),
          const SizedBox(height: 14),

          // 👈 نرخ‌ها + معوق
          const _RatesRow(),
        ],
      ),
    );
  }
}

class _RatesRow extends StatelessWidget {
  const _RatesRow();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<ReportBloc>().state.data?.summary;
    if (s == null) return const SizedBox.shrink();

    final overdue = s.overdueCount > 0;

    return Row(
      children: [
        Expanded(
          child: _rate(
            'وصول طلب',
            s.collectionRate,
            'از ${money(s.totalReceivable)}',
            _green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _rate(
            'بازپرداخت',
            s.repaymentRate,
            'از ${money(s.totalDebt)}',
            _blue,
          ),
        ),
        if (overdue) ...[
          const SizedBox(width: 10),
          _overdueChip(s.overdueCount),
        ],
      ],
    );
  }

  Widget _rate(String label, double? rate, String detail, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'sans',
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
              Text(
                rate == null ? '—' : pct(rate),
                style: TextStyle(
                  fontFamily: 'sans',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (rate ?? 0).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'sans',
              fontSize: 9,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _overdueChip(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _orange.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _orange.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 16, color: _orange),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fa('$count'),
                style: const TextStyle(
                  fontFamily: 'sans',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _orange,
                ),
              ),
              const Text(
                'معوق',
                style: TextStyle(
                  fontFamily: 'sans',
                  fontSize: 9,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}