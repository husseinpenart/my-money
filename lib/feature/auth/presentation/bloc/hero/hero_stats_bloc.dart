import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/auth/presentation/bloc/hero/hero_stats_event.dart';
import 'package:money/feature/auth/presentation/bloc/hero/hero_stats_state.dart';
import 'package:money/feature/data/dataResource/lib/feature/auth/data/dataResource/hero_remote_data_source.dart';

class HeroStatsBloc extends Bloc<HeroStatsEvent, HeroStatsState> {
  final HeroRemoteDataSource remoteDataSource;

  HeroStatsBloc(this.remoteDataSource) : super(const HeroStatsInitial()) {
    on<HeroStatsRequested>(_onRequested);
  }

  Future<void> _onRequested(
    HeroStatsRequested event,
    Emitter<HeroStatsState> emit,
  ) async {
    emit(const HeroStatsLoading());
    try {
      final stats = await remoteDataSource.fetch();
      emit(HeroStatsLoaded(stats));
    } catch (error) {
      emit(HeroStatsFailure(backendMessage(error)));
    }
  }
}