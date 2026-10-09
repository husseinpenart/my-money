import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/auth/presentation/bloc/report/report_event.dart';
import 'package:money/feature/auth/presentation/bloc/report/report_state.dart';
import 'package:money/feature/data/dataResource/report_remote_data_source.dart';
import 'package:money/feature/model/report/report_models.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRemoteDataSource remoteDataSource;

  ReportBloc({required this.remoteDataSource}) : super(const ReportState()) {
    // با تغییر سریع بازه، درخواست قبلی نادیده گرفته می‌شود
    on<ReportRequested>(_onRequested, transformer: restartable());
  }

  Future<void> _onRequested(
    ReportRequested event,
    Emitter<ReportState> emit,
  ) async {
    final period = event.period ?? state.period;
    emit(
      state.copyWith(
        status: ReportStatus.loading,
        period: period,
        clearError: true,
      ),
    );

    try {
      final data = await remoteDataSource.fetch(period: period);
      emit(state.copyWith(status: ReportStatus.success, data: data));
    } catch (e) {
      emit(
        state.copyWith(
          status: ReportStatus.failure,
          error: e is ReportApiException ? e.message : backendMessage(e),
        ),
      );
    } finally {
      if (event.done != null && !event.done!.isCompleted) {
        event.done!.complete();
      }
    }
  }
}
