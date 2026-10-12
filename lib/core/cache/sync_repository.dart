import 'package:flutter/foundation.dart';
import 'package:money/core/cache/contact_cache.dart';
import 'package:money/feature/data/dataResource/sync_remote_data_source.dart';
import 'package:money/helper/utils/number_helper.dart';

class SyncOutcome {
  final bool changed;
  final int remaining;
  final String message;
  const SyncOutcome(this.changed, this.remaining, this.message);
}

class SyncRepository {
  final SyncRemoteDataSource remote;
  final ContactCache cache;
  SyncRepository(this.remote, this.cache);

  /// برای نمایش اسپینر در هر صفحه‌ای
  final ValueNotifier<bool> syncing = ValueNotifier(false);
  Future<SyncOutcome>? _inflight;

  /// چند صفحه هم‌زمان رفرش بزنند، فقط یک درخواست می‌رود
  Future<SyncOutcome> refresh() =>
      _inflight ??= _run().whenComplete(() => _inflight = null);

  Future<SyncOutcome> _run() async {
    syncing.value = true;
    try {
      final r = await remote.snapshot(
        since: cache.hasData ? cache.version : null,
      );
      final left = NumberHelper.toPersianDigits('${r.remaining}');

      if (r.unchanged) {
        cache.touchSynced();
        return SyncOutcome(false, r.remaining, 'اطلاعات شما به‌روز است');
      }
      cache.replaceAll(r.contacts, r.version);
      return SyncOutcome(
        true,
        r.remaining,
        'بروزرسانی شد · $left بار دیگر امروز',
      );
    } finally {
      syncing.value = false;
    }
  }
}
