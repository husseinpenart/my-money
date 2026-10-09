
import 'package:money/feature/model/report/report_models.dart';

enum ReportStatus { initial, loading, success, failure }

class ReportState {
  final ReportStatus status;
  final ReportPeriod period;
  final ReportData? data; // هنگام بازخوانی، داده‌ی قبلی نمایش داده می‌شود
  final String? error;

  const ReportState({
    this.status = ReportStatus.initial,
    this.period = ReportPeriod.all,
    this.data,
    this.error,
  });

  ReportState copyWith({
    ReportStatus? status,
    ReportPeriod? period,
    ReportData? data,
    String? error,
    bool clearError = false,
  }) =>
      ReportState(
        status: status ?? this.status,
        period: period ?? this.period,
        data: data ?? this.data,
        error: clearError ? null : (error ?? this.error),
      );
}