import 'package:get_it/get_it.dart';
import 'package:money/core/cache/contact_cache.dart';
import 'package:money/core/network/notification_read_store.dart';
import 'package:money/core/storage/app_storage.dart';
import 'package:money/core/storage/token_storage.dart';

class SessionCleaner {
  SessionCleaner._();

  static Future<void> clear() async {
    final g = GetIt.I;
    await g<TokenStorage>().clearAll();
    await g<NotificationReadStore>().clear();
    await g<ContactCache>().clear();
    await g<AppStorage>().remove('recent_searches');
  }
}
