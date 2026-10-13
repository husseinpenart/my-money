import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import 'package:money/core/storage/app_storage.dart';
import 'package:money/core/vault/vault_crypto.dart';
import 'package:money/core/vault/vault_local_store.dart';
import 'package:money/feature/data/dataResource/vault_remote_data_source.dart';
import 'package:money/feature/model/vault/vault_models.dart';

class SyncReport {
  final int pushed, pulled, conflicts, uploaded;
  const SyncReport(this.pushed, this.pulled, this.conflicts, this.uploaded);

  String get message {
    final parts = <String>[
      if (pushed > 0) '$pushed مورد ارسال شد',
      if (pulled > 0) '$pulled مورد دریافت شد',
      if (uploaded > 0) '$uploaded پیوست همگام شد',
    ];
    final base = parts.isEmpty ? 'همه‌چیز به‌روز است' : parts.join('، ');
    return conflicts > 0
        ? '$base. $conflicts مورد در دستگاه دیگری تغییر کرده بود و نسخه‌ی سرور جایگزین شد'
        : base;
  }
}

Uint8List _prepareImage(Uint8List bytes) {
  final src = img.decodeImage(bytes);
  if (src == null) throw const FormatException('not an image');

  const maxSide = 1600;
  var out = src;

  if (src.width > maxSide || src.height > maxSide) {
    out = src.width >= src.height
        ? img.copyResize(src, width: maxSide)
        : img.copyResize(src, height: maxSide);
  }

  return Uint8List.fromList(img.encodeJpg(out, quality: 80));
}

/// کلید فقط در RAM است. داده‌ی رمزشده از دیسک محلی خوانده می‌شود
/// و فقط تغییرات به سرور می‌رود.
class VaultRepository extends ChangeNotifier {
  VaultRepository(this.remote, this.store, this.storage);

  final VaultRemoteDataSource remote;
  final VaultLocalStore store;
  final AppStorage storage;

  static const int kMaxFileBytes = 5 * 1024 * 1024;
  static const int kMaxAttachments = 10;
  static const int _maxTries = 5;

  final ValueNotifier<bool> syncing = ValueNotifier(false);

  SecretKey? _key;
  VaultProfile? _profile;

  final Map<String, VaultRecord> _records = {};
  final Map<String, VaultPlain> _plain = {};
  final Map<String, String> _plainIv = {};

  List<VaultEntry> _entries = const [];
  DateTime? lastSyncedAt;

  Timer? _soon, _tick;
  Future<SyncReport>? _inflight;
  bool _again = false;
  int _ticks = 0;

  bool get isUnlocked => _key != null;
  List<VaultEntry> get entries => _entries;

  int get pendingCount => _records.values.fold<int>(
    0,
    (s, r) => s + (r.pending ? 1 : 0) + r.pendingAttachments,
  );

  VaultEntry? entryById(String id) {
    for (final e in _entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  SecretKey _need() => _key ?? (throw VaultApiException('گاوصندوق قفل است'));

  // ───────────── راه‌اندازی، باز کردن، بازیابی ─────────────

  /// true یعنی گاوصندوق ساخته شده.
  /// پروفایل محلی است و فقط بار اول از سرور می‌آید.
  Future<bool> hasProfile() async {
    final raw = store.meta('profile');
    if (raw != null) {
      _profile = VaultProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      return true;
    }

    final p = await remote.getProfile();
    if (p == null) return false;

    await _saveProfile(p);
    return true;
  }

  Future<void> _saveProfile(VaultProfile p) async {
    _profile = p;
    await store.setMeta('profile', jsonEncode(p.toJson()));
  }

  /// کلید بازیابی را برمی‌گرداند؛ فقط همین یک‌بار قابل نمایش است.
  Future<String> setup(String pass) async {
    final dek = VaultCrypto.randomBytes(32);
    final rec = VaultCrypto.randomBytes(32);
    final salt = VaultCrypto.randomBytes(16);

    final kek = await VaultCrypto.deriveKey(
      pass,
      salt,
      VaultCrypto.kIterations,
    );

    final wp = await VaultCrypto.wrapKey(kek, dek, 'pass');
    final wr = await VaultCrypto.wrapKey(SecretKey(rec), dek, 'rec');

    final saved = await remote.setup(
      VaultProfile(
        salt: base64Encode(salt),
        iterations: VaultCrypto.kIterations,
        wrappedPass: wp.dataB64,
        wrappedPassIv: wp.iv,
        wrappedRec: wr.dataB64,
        wrappedRecIv: wr.iv,
      ),
    );

    await store.clear();
    _records.clear();
    _plain.clear();
    _plainIv.clear();

    await _saveProfile(saved);
    await _clearFails();

    // اگر sync اولیه شکست خورد، کلید بازیابی نباید گم شود.
    try {
      await _open(SecretKey(dek));
    } catch (_) {
      // گاوصندوق باز است؛ همگام‌سازی بعداً دوباره تلاش می‌کند.
    }

    return await VaultCrypto.formatRecoveryKey(rec);
  }

  Future<SecretKey?> _tryUnwrap(String pass, VaultProfile p) async {
    try {
      final kek = await VaultCrypto.deriveKey(
        pass,
        base64Decode(p.salt),
        p.iterations,
      );
      return await VaultCrypto.unwrapKey(
        kek,
        p.wrappedPassIv,
        p.wrappedPass,
        'pass',
      );
    } on VaultCryptoException {
      return null;
    }
  }

  /// ممکن است رمز در دستگاه دیگری عوض شده باشد؛ پروفایل تازه از سرور گرفته می‌شود.
  Future<VaultProfile?> _freshProfile(VaultProfile cur) async {
    try {
      final s = await remote.getProfile();
      if (s == null) return null;
      if (s.revision == cur.revision && s.stamp == cur.stamp) return null;

      if (s.stamp != cur.stamp) {
        // گاوصندوق از نو ساخته شده؛ داده‌ی محلی بی‌معناست.
        await store.clear();
        _records.clear();
        _plain.clear();
        _plainIv.clear();
      }

      await _saveProfile(s);
      return s;
    } catch (_) {
      return null;
    }
  }

  Future<void> unlock(String secret) async {
    final profile = _profile;
    if (profile == null) {
      throw VaultApiException('گاوصندوق راه‌اندازی نشده است');
    }

    var p = profile;

    final rem = lockRemaining();
    if (rem != null) throw VaultLockedOut(rem);

    var dek = await _tryUnwrap(secret, p);

    if (dek == null) {
      final fresh = await _freshProfile(p);
      if (fresh != null) {
        p = fresh;
        dek = await _tryUnwrap(secret, p);
      }
    }

    if (dek == null) {
      final left = await _fail();
      final r = lockRemaining();
      if (r != null) throw VaultLockedOut(r);
      throw VaultWrongSecret(left);
    }

    await _clearFails();
    await _open(dek);
  }

  Future<void> _open(SecretKey dek) async {
    _key = dek;

    _records
      ..clear()
      ..addEntries(store.all().map((r) => MapEntry(r.id, r)));

    await _rebuild();
    _startTimers();

    // دستگاه جدید: اولین دانلود.
    // دفعات بعد بدون هیچ درخواستی از حافظه‌ی محلی می‌خواند.
    if (store.meta('cursor') == null) {
      try {
        await sync();
      } on VaultApiException catch (e) {
        if (!e.offline) rethrow;
      }
    } else {
      lastSyncedAt = DateTime.tryParse(store.meta('syncedAt') ?? '');
    }
  }

  // ───────── فراموشی رمز: بدون هیچ پاک شدنی ─────────

  /// با کلید بازیابی DEK را باز می‌کند، رمز جدید می‌گذارد
  /// و کلید بازیابی جدیدی صادر می‌کند.
  Future<String> recover(
    String recoveryKey,
    String newPass,
    String accountPassword,
  ) async {
    final parsed = await VaultCrypto.parseRecoveryKey(recoveryKey);
    if (parsed == null) {
      throw VaultApiException(
        'کلید بازیابی معتبر نیست؛ احتمالاً اشتباه تایپی دارد',
      );
    }

    final server = await remote.getProfile();
    if (server == null) {
      throw VaultApiException('گاوصندوقی برای این حساب وجود ندارد');
    }

    if (_profile != null && server.stamp != _profile!.stamp) {
      await store.clear();
      _records.clear();
      _plain.clear();
      _plainIv.clear();
    }

    await _saveProfile(server);

    final SecretKey dek;
    try {
      dek = await VaultCrypto.unwrapKey(
        SecretKey(parsed),
        server.wrappedRecIv,
        server.wrappedRec,
        'rec',
      );
    } on VaultCryptoException {
      throw VaultApiException('کلید بازیابی اشتباه است');
    }

    final newRec = await _commit(
      dek: dek,
      newPass: newPass,
      rotateRec: true,
      account: accountPassword,
    );

    await _clearFails();

    // اگر sync اولیه شکست خورد، کلید بازیابی جدید نباید گم شود.
    try {
      await _open(dek);
    } catch (_) {
      // گاوصندوق باز است؛ همگام‌سازی بعداً دوباره تلاش می‌کند.
    }

    if (newRec == null) {
      throw VaultApiException('کلید بازیابی جدید ساخته نشد');
    }

    return newRec;
  }

  /// تغییر رمز؛ فقط وقتی باز است. رمز فعلی دوباره تأیید می‌شود.
  Future<void> changePassphrase(
    String oldPass,
    String newPass,
    String accountPassword,
  ) async {
    final dek = _need();
    final p = _profile;
    if (p == null) throw VaultApiException('گاوصندوق راه‌اندازی نشده است');

    if (await _tryUnwrap(oldPass, p) == null) {
      throw VaultApiException('رمز فعلی گاوصندوق اشتباه است');
    }

    await _commit(
      dek: dek,
      newPass: newPass,
      rotateRec: false,
      account: accountPassword,
    );
  }

  /// کلید بازیابی جدید؛ کلید قبلی باطل می‌شود.
  Future<String> regenerateRecovery(String accountPassword) async {
    final k = await _commit(
      dek: _need(),
      rotateRec: true,
      account: accountPassword,
    );

    if (k == null) throw VaultApiException('کلید بازیابی جدید ساخته نشد');
    return k;
  }

  Future<String?> _commit({
    required SecretKey dek,
    String? newPass,
    required bool rotateRec,
    required String account,
  }) async {
    final p = _profile;
    if (p == null) throw VaultApiException('گاوصندوق راه‌اندازی نشده است');

    final dekBytes = await dek.extractBytes();

    var salt = p.salt;
    var it = p.iterations;
    var wp = p.wrappedPass;
    var wpIv = p.wrappedPassIv;
    var wr = p.wrappedRec;
    var wrIv = p.wrappedRecIv;
    String? recText;

    if (newPass != null) {
      final s = VaultCrypto.randomBytes(16);
      final kek = await VaultCrypto.deriveKey(
        newPass,
        s,
        VaultCrypto.kIterations,
      );
      final w = await VaultCrypto.wrapKey(kek, dekBytes, 'pass');

      salt = base64Encode(s);
      it = VaultCrypto.kIterations;
      wp = w.dataB64;
      wpIv = w.iv;
    }

    if (rotateRec) {
      final rec = VaultCrypto.randomBytes(32);
      final w = await VaultCrypto.wrapKey(SecretKey(rec), dekBytes, 'rec');

      wr = w.dataB64;
      wrIv = w.iv;
      recText = await VaultCrypto.formatRecoveryKey(rec);
    }

    final saved = await remote.updateProfile(
      VaultProfile(
        salt: salt,
        iterations: it,
        wrappedPass: wp,
        wrappedPassIv: wpIv,
        wrappedRec: wr,
        wrappedRecIv: wrIv,
      ),
      account,
      p.revision,
    );

    await _saveProfile(saved);
    return recText;
  }

  /// آخرین راه، فقط برای کسی که هم رمز و هم کلید بازیابی را گم کرده.
  Future<void> reset(String accountPassword) async {
    await remote.reset(accountPassword);
    await _wipeLocal();
  }

  Future<void> _wipeLocal() async {
    lock();
    _records.clear();
    _plain.clear();
    _plainIv.clear();
    _profile = null;
    await store.clear();
    await _clearFails();
    notifyListeners();
  }

  void lock() {
    _soon?.cancel();
    _tick?.cancel();
    _key = null;
    _plain.clear();
    _plainIv.clear();
    _entries = const [];
    notifyListeners();
  }

  // ───────────── محدودیت تلاش (محلی) ─────────────

  Duration? lockRemaining() {
    final u = DateTime.tryParse(storage.getString('vault_lock_until') ?? '');
    if (u == null) return null;
    final d = u.difference(DateTime.now());
    return d.isNegative ? null : d;
  }

  Future<int> _fail() async {
    final n = (int.tryParse(storage.getString('vault_fail') ?? '') ?? 0) + 1;
    await storage.setString('vault_fail', '$n');

    if (n % _maxTries == 0) {
      final secs = min(30 * pow(2, n ~/ _maxTries - 1).toInt(), 3600);
      await storage.setString(
        'vault_lock_until',
        DateTime.now().add(Duration(seconds: secs)).toIso8601String(),
      );
    }

    return _maxTries - (n % _maxTries);
  }

  Future<void> _clearFails() async {
    await storage.remove('vault_fail');
    await storage.remove('vault_lock_until');
  }

  // ───────────── رمزگشایی در RAM ─────────────

  // دسته از AAD رفت؛ حالا داخل VaultPlain.cat است.
  List<int> _aad(String id) => utf8.encode('item|$id');

  List<int> _attAad(String id, String itemId, {bool meta = false}) =>
      utf8.encode('att|$id|$itemId${meta ? '|meta' : ''}');

  Future<void> _rebuild() async {
    final k = _key;
    if (k == null) return;

    final list = <VaultEntry>[];

    for (final r in _records.values) {
      if (r.isDeleted) continue;

      VaultPlain? p = _plainIv[r.id] == r.iv ? _plain[r.id] : null;

      if (p == null) {
        try {
          final text = await VaultCrypto.openString(
            k,
            r.iv,
            r.encryptedData,
            aad: _aad(r.id),
          );
          p = VaultPlain.fromJson(jsonDecode(text) as Map<String, dynamic>);
          _plain[r.id] = p;
          _plainIv[r.id] = r.iv;
        } catch (_) {
          p = null;
        }
      }

      list.add(VaultEntry(r, p));
    }

    list.sort((a, b) => b.record.updatedAt.compareTo(a.record.updatedAt));
    _entries = list;
    notifyListeners();
  }

  // ───────────── Commandها: اول محلی، بعد پس‌زمینه ─────────────

  Future<String> save({
    String? id,
    required VaultCategory category,
    required VaultPlain plain,
  }) async {
    final k = _need();
    final rid = id ?? VaultCrypto.newId();
    final old = _records[rid];

    final p = VaultPlain(
      title: plain.title,
      note: plain.note,
      fields: plain.fields,
      cat: category.id,
    );

    final sealed = await VaultCrypto.sealString(
      k,
      jsonEncode(p.toJson()),
      aad: _aad(rid),
    );

    final now = DateTime.now().toUtc();

    final base =
        old ??
        VaultRecord(
          id: rid,
          category: 0,
          encryptedData: '',
          iv: '',
          createdAt: now,
          updatedAt: now,
        );

    final rec = base.copyWith(
      category: 0,
      encryptedData: sealed.dataB64,
      iv: sealed.iv,
      updatedAt: now,
      pending: true,
      rev: base.rev + 1,
    );

    await store.put(rec);
    _records[rid] = rec;
    _plain[rid] = p;
    _plainIv[rid] = sealed.iv;

    await _rebuild();
    syncSoon();

    return rid;
  }

  Future<void> delete(String id) async {
    final r = _records[id];
    if (r == null) return;

    if (r.version == 0) {
      // هرگز به سرور نرسیده بود.
      await _dropLocal(id);
    } else {
      final rec = r.copyWith(
        isDeleted: true,
        pending: true,
        encryptedData: '',
        rev: r.rev + 1,
      );
      await store.put(rec);
      _records[id] = rec;
    }

    await _rebuild();
    syncSoon();
  }

  Future<void> _dropLocal(String id) async {
    final r = _records.remove(id);
    _plain.remove(id);
    _plainIv.remove(id);
    await store.remove(id);

    for (final a in r?.attachments ?? const <VaultAttachment>[]) {
      await store.removeBlob(a.id);
    }
  }

  // ───────────── پیوست‌ها ─────────────

  Future<void> addAttachment(
    String itemId,
    String name,
    List<int> bytes,
  ) async {
    final k = _need();
    final r = _records[itemId];

    if (r == null || r.isDeleted) throw VaultApiException('آیتم پیدا نشد');

    if (r.attachments.where((a) => a.state != 2).length >= kMaxAttachments) {
      throw VaultApiException(
        'حداکثر $kMaxAttachments پیوست برای هر آیتم مجاز است',
      );
    }

    Uint8List jpg;
    try {
      jpg = await compute(_prepareImage, Uint8List.fromList(bytes));
    } catch (_) {
      throw VaultApiException('«$name» تصویر معتبر نیست');
    }

    if (jpg.length > kMaxFileBytes) {
      throw VaultApiException(
        '«$name» پس از فشرده‌سازی هم بیشتر از ۵ مگابایت است',
      );
    }

    final id = VaultCrypto.newId();
    final blob = await VaultCrypto.seal(k, jpg, aad: _attAad(id, itemId));

    final base = name.replaceAll(RegExp(r'\.[^.]*$'), '');
    final safe = (base.length > 60 ? base.substring(0, 60) : base);

    final meta = await VaultCrypto.sealString(
      k,
      jsonEncode({'n': '$safe.jpg', 'm': 'image/jpeg'}),
      aad: _attAad(id, itemId, meta: true),
    );

    await store.putBlob(id, blob.data);

    final att = VaultAttachment(
      id: id,
      itemId: itemId,
      encryptedMeta: '${meta.iv}.${meta.dataB64}',
      iv: blob.iv,
      size: blob.data.length,
      state: 1,
      createdAt: DateTime.now().toUtc(),
    );

    final rec = r.copyWith(attachments: [...r.attachments, att]);
    await store.put(rec);
    _records[itemId] = rec;

    await _rebuild();
    syncSoon();
  }

  Future<void> removeAttachment(String itemId, String attId) async {
    final r = _records[itemId];
    if (r == null) return;

    final a = r.attachments.where((x) => x.id == attId).firstOrNull;
    if (a == null) return;

    final list = a.state == 1
        ? r.attachments.where((x) => x.id != attId).toList()
        : [
            for (final x in r.attachments)
              x.id == attId ? x.copyWith(state: 2) : x,
          ];

    if (a.state == 1) await store.removeBlob(attId);

    final rec = r.copyWith(attachments: list);
    await store.put(rec);
    _records[itemId] = rec;

    await _rebuild();
    syncSoon();
  }

  Future<({String name, String mime})> attachmentInfo(VaultAttachment a) async {
    final k = _need();
    final i = a.encryptedMeta.indexOf('.');

    if (i <= 0 || i >= a.encryptedMeta.length - 1) {
      return (name: 'فایل', mime: 'application/octet-stream');
    }

    try {
      final text = await VaultCrypto.openString(
        k,
        a.encryptedMeta.substring(0, i),
        a.encryptedMeta.substring(i + 1),
        aad: _attAad(a.id, a.itemId, meta: true),
      );

      final j = jsonDecode(text) as Map<String, dynamic>;
      return (name: '${j['n']}', mime: '${j['m']}');
    } catch (_) {
      return (name: 'فایل', mime: 'application/octet-stream');
    }
  }

  /// اول از دیسک محلی؛ فقط اگر نبود از سرور و بعد برای دفعات بعد ذخیره می‌شود.
  Future<Uint8List> readAttachment(VaultAttachment a) async {
    final k = _need();
    var blob = store.blob(a.id);

    if (blob == null) {
      blob = await remote.download(a.id);
      await store.putBlob(a.id, blob);
    }

    return VaultCrypto.open(k, a.iv, blob, aad: _attAad(a.id, a.itemId));
  }

  // ───────────── Delta Sync ─────────────

  int get _cursor => int.tryParse(store.meta('cursor') ?? '') ?? 0;

  void syncSoon() {
    _soon?.cancel();
    _soon = Timer(const Duration(milliseconds: 800), () {
      unawaited(sync().then((_) {}, onError: (_) {}));
    });
  }

  void _startTimers() {
    _tick?.cancel();
    _ticks = 0;

    _tick = Timer.periodic(const Duration(seconds: 60), (_) {
      if (_key == null || syncing.value) return;

      _ticks++;

      // Push فوری اگر تغییر معلق داریم؛ Pull سبک هر ۱۵ دقیقه.
      if (pendingCount > 0 || _ticks % 15 == 0) {
        unawaited(sync().then((_) {}, onError: (_) {}));
      }
    });
  }

  Future<SyncReport> sync() {
    if (_inflight != null) {
      _again = true;
      return _inflight!;
    }

    return _inflight = _sync().whenComplete(() {
      _inflight = null;
      if (_again) {
        _again = false;
        if (_key != null && pendingCount > 0) syncSoon();
      }
    });
  }

  Future<SyncReport> _sync() async {
    _need();
    syncing.value = true;

    var pushed = 0, pulled = 0, conflicts = 0, uploaded = 0;

    try {
      final sentRev = <String, int>{};
      var changes = <Map<String, dynamic>>[];

      for (final r in _records.values) {
        if (!r.pending) continue;
        sentRev[r.id] = r.rev;
        changes.add(r.toChange());
      }

      var cursor = _cursor;
      var full = false;
      final pulledIds = <String>{};

      while (true) {
        final res = await remote.sync(cursor, changes);
        changes = const [];

        if (res.profileStamp != _profile!.stamp) {
          await _wipeLocal();
          throw VaultApiException(
            'گاوصندوق از نو ساخته شده است. دوباره وارد شو.',
          );
        }

        if (res.profileRevision != _profile!.revision) {
          // رمز یا کلید بازیابی عوض شده؛ DEK همان است و چیزی پاک نمی‌شود.
          final f = await remote.getProfile();
          if (f != null && f.stamp == _profile!.stamp) {
            await _saveProfile(f);
          }
        }

        full = full || res.fullReload;

        for (final e in res.accepted.entries) {
          pushed++;
          await _onAccepted(e.key, e.value, sentRev[e.key]);
        }

        conflicts += res.conflicts.length;

        for (final j in res.items) {
          pulled++;
          pulledIds.add('${j['id']}');
          await _applyServerItem(j, res.conflicts);
        }

        cursor = res.cursor;
        await store.setMeta('cursor', '$cursor');

        if (!res.hasMore) break;
      }

      if (full) {
        // دستگاه خیلی قدیمی بود؛ رکوردهای همگام‌شده‌ای که سرور دیگر ندارد
        // حذف‌شده‌اند.
        for (final r in _records.values.toList()) {
          if (!r.pending && !pulledIds.contains(r.id)) {
            await _dropLocal(r.id);
          }
        }
      }

      uploaded = await _syncAttachments();

      lastSyncedAt = DateTime.now();
      await store.setMeta('syncedAt', lastSyncedAt!.toIso8601String());

      await _rebuild();

      return SyncReport(pushed, pulled, conflicts, uploaded);
    } finally {
      syncing.value = false;
      notifyListeners();
    }
  }

  Future<void> _onAccepted(String id, int version, int? sentRev) async {
    final local = _records[id];

    if (local == null) {
      // وسط همگام‌سازی حذف شده بود؛ روی سرور هم باید حذف شود.
      final t = VaultRecord.tombstone(id, version);
      _records[id] = t;
      await store.put(t);
      return;
    }

    if (sentRev == null) return;

    if (local.rev == sentRev) {
      if (local.isDeleted) {
        await _dropLocal(id);
      } else {
        final rec = local.copyWith(version: version, pending: false);
        _records[id] = rec;
        await store.put(rec);
      }
    } else {
      // هنگام ارسال دوباره ویرایش شده؛ پایه به‌روز می‌شود ولی هنوز در انتظار است.
      final rec = local.copyWith(version: version);
      _records[id] = rec;
      await store.put(rec);
    }
  }

  Future<void> _applyServerItem(
    Map<String, dynamic> j,
    Set<String> conflicts,
  ) async {
    final s = VaultRecord.fromServer(j);
    final local = _records[s.id];

    if (local != null && local.pending && !conflicts.contains(s.id)) return;

    // دستگاه دیگری همین آیتم را تغییر داده یا حذف کرده:
    // ویرایش محلی به‌صورت آیتم جدید می‌ماند.
    if (local != null &&
        local.pending &&
        conflicts.contains(s.id) &&
        !local.isDeleted) {
      await _keepConflictCopy(local);
    }

    if (s.isDeleted) {
      await _dropLocal(s.id);
      return;
    }

    final merged = await _mergeAtts(local, s.attachments);
    final rec = s.copyWith(
      pending: false,
      rev: local?.rev ?? 0,
      attachments: merged,
    );

    await store.put(rec);
    _records[s.id] = rec;
  }

  Future<void> _keepConflictCopy(VaultRecord local) async {
    try {
      final text = await VaultCrypto.openString(
        _need(),
        local.iv,
        local.encryptedData,
        aad: _aad(local.id),
      );

      final p = VaultPlain.fromJson(jsonDecode(text) as Map<String, dynamic>);

      await save(
        category: VaultCategory.of(p.cat),
        plain: VaultPlain(
          title: '${p.title} (نسخه‌ی تعارضی)',
          note: p.note,
          fields: p.fields,
          cat: p.cat,
        ),
      );
    } catch (_) {
      // داده‌ی خراب قابل کپی نیست.
    }
  }

  Future<List<VaultAttachment>> _mergeAtts(
    VaultRecord? local,
    List<VaultAttachment> server,
  ) async {
    final mine = local?.attachments ?? const <VaultAttachment>[];
    final serverIds = server.map((a) => a.id).toSet();
    final out = <VaultAttachment>[];

    for (final a in server) {
      final l = mine.where((x) => x.id == a.id).firstOrNull;
      out.add(l != null && l.state == 2 ? l : a);
    }

    for (final l in mine) {
      if (serverIds.contains(l.id)) continue;

      if (l.state == 1) {
        out.add(l);
      } else {
        await store.removeBlob(l.id);
      }
    }

    return out;
  }

  Future<int> _syncAttachments() async {
    var done = 0;

    for (final r in _records.values.toList()) {
      if (r.pending || r.isDeleted) continue;

      for (final a in r.attachments.where((a) => a.state != 0).toList()) {
        try {
          if (a.state == 1) {
            final blob = store.blob(a.id);
            if (blob == null) {
              await _replaceAtt(r.id, a.id, null);
              continue;
            }

            final res = await remote.upload(
              id: a.id,
              itemId: r.id,
              iv: a.iv,
              meta: a.encryptedMeta,
              bytes: blob,
            );

            await _replaceAtt(
              r.id,
              a.id,
              a.copyWith(state: 0, size: res.size),
              version: res.itemVersion,
            );
          } else {
            final v = await remote.deleteAttachment(a.id);
            await store.removeBlob(a.id);
            await _replaceAtt(r.id, a.id, null, version: v);
          }

          done++;
        } on VaultApiException catch (e) {
          if (e.offline) rethrow; // خطای یک فایل بقیه را متوقف نمی‌کند.
        }
      }
    }

    return done;
  }

  Future<void> _replaceAtt(
    String itemId,
    String attId,
    VaultAttachment? repl, {
    int? version,
  }) async {
    final r = _records[itemId];
    if (r == null) return;

    final list = <VaultAttachment>[];
    for (final a in r.attachments) {
      if (a.id != attId) {
        list.add(a);
      } else if (repl != null) {
        list.add(repl);
      }
    }

    final rec = r.copyWith(
      attachments: list,
      version: (version != null && version > 0) ? version : null,
    );

    await store.put(rec);
    _records[itemId] = rec;
  }
}
