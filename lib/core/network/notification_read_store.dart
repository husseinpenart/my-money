import 'package:money/core/storage/app_storage.dart';

class NotificationReadStore {
  static const _k = 'notif_read_keys';
  static const _max = 1000;

  final AppStorage _s;
  NotificationReadStore(this._s);

  Set<String> load() => (_s.getStringList(_k) ?? const <String>[]).toSet();

  Future<void> save(Set<String> keys) async {
    var list = keys.toList();
    if (list.length > _max) list = list.sublist(list.length - _max);
    await _s.setStringList(_k, list);
  }

  Future<void> clear() => _s.remove(_k);
}
