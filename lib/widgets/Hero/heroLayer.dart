import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/network/api_client.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/auth/presentation/bloc/report/report_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/report/report_event.dart';
import 'package:money/feature/data/dataResource/report_remote_data_source.dart';
import 'package:money/feature/model/report/report_models.dart';
import 'package:money/widgets/Hero/heroContainerGrid.dart';
import 'package:money/widgets/Hero/heroCountItems.dart';
import 'package:money/widgets/Hero/heroInfo.dart';
import 'package:money/widgets/global/GlassContainer.dart';

class Herolayer extends StatefulWidget {
  const Herolayer({super.key});

  @override
  State<Herolayer> createState() => _HerolayerState();
}

class _HerolayerState extends State<Herolayer> {
  // instance مستقل برای Hero (تا بازه‌ی صفحه‌ی Report روی آن اثر نگذارد)
  late final ReportBloc _bloc;

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: const _HeroLayerBody(),
    );
  }
}

class _HeroLayerBody extends StatelessWidget {
  const _HeroLayerBody();

  @override
  Widget build(BuildContext context) {
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
              GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                containerWidth: 80,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ScreenDictionary.moenyUnit,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'sans',
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_drop_down_sharp,
                      color: Colors.white,
                      size: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          /// Hero info
          const Heroinfo(),
          const SizedBox(height: 20),
          const Herocontainergrid(),
          const SizedBox(height: 10),
          const Herocountitems(),
        ],
      ),
    );
  }
}