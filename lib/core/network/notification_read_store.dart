import 'package:shared_preferences/shared_preferences.dart';

class NotificationReadStore {
  static const _k = 'notif_read_keys';
  static const _max = 1000;

  final SharedPreferences _prefs;
  NotificationReadStore(this._prefs);

  Set<String> load() => (_prefs.getStringList(_k) ?? const <String>[]).toSet();

  Future<void> save(Set<String> keys) async {
    var list = keys.toList();
    if (list.length > _max) list = list.sublist(list.length - _max);
    await _prefs.setStringList(_k, list);
  }

  /// هنگام خروج از حساب صدا بزن
  Future<void> clear() => _prefs.remove(_k);
}
