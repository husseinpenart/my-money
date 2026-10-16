import 'package:get_it/get_it.dart';
import 'package:money/core/alerts/alert_coordinator.dart';
import 'package:money/core/cache/contact_cache.dart';
import 'package:money/core/network/notification_read_store.dart';
import 'package:money/core/storage/app_storage.dart';
import 'package:money/core/storage/token_storage.dart';
import 'package:money/core/vault/vault_local_store.dart';
import 'package:money/core/vault/vault_repository.dart';

class SessionCleaner {
  SessionCleaner._();

  static Future<void> clear() async {
    final g = GetIt.I;
    g<VaultRepository>().lock();
    await g<TokenStorage>().clearAll();
    await g<NotificationReadStore>().clear();
    await g<ContactCache>().clear();
    await g<AlertCoordinator>().clear();
    await g<AppStorage>().remove('recent_searches');
    await g<VaultLocalStore>().clear();
    await g<AppStorage>().remove('vault_fail');
    await g<AppStorage>().remove('vault_lock_until');
  }
}
