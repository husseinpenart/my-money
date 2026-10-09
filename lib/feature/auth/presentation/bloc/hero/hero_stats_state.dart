
import 'package:money/feature/model/widgets/hero/hero_stats.dart';

abstract class HeroStatsState {
  const HeroStatsState();
  HeroStats? get stats => null;
  bool get isLoading => false;
  String? get error => null;
}

class HeroStatsInitial extends HeroStatsState {
  const HeroStatsInitial();
}

class HeroStatsLoading extends HeroStatsState {
  const HeroStatsLoading();
  @override
  bool get isLoading => true;
}

class HeroStatsLoaded extends HeroStatsState {
  const HeroStatsLoaded(this._stats);
  final HeroStats _stats;
  @override
  HeroStats get stats => _stats;
}

class HeroStatsFailure extends HeroStatsState {
  const HeroStatsFailure(this._message);
  final String _message;
  @override
  String get error => _message;
}