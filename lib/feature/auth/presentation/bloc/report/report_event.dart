import 'dart:async';

import 'package:money/feature/model/report/report_models.dart';

abstract class ReportEvent {
  const ReportEvent();
}

/// [period] نال یعنی همان بازه‌ی فعلی (بازخوانی). [done] برای RefreshIndicator
class ReportRequested extends ReportEvent {
  final ReportPeriod? period;
  final Completer<void>? done;
  const ReportRequested({this.period, this.done});
}