import 'dart:convert';
import 'dart:typed_data';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:money/feature/model/vault/vault_models.dart';

class VaultLocalStore {
  static bool _hiveReady = false;

  late Box<String> _items;
  late Box<String> _meta;
  late Box<Uint8List> _blobs;

  Future<void> init() async {
    if (!_hiveReady) {
      await Hive.initFlutter();
      _hiveReady = true;
    }

    _items = await Hive.openBox<String>('vault_items');
    _meta = await Hive.openBox<String>('vault_meta');
    _blobs = await Hive.openBox<Uint8List>('vault_blobs');
  }

  List<VaultRecord> all() {
    final out = <VaultRecord>[];

    for (final s in _items.values) {
      try {
        out.add(VaultRecord.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {}
    }

    return out;
  }

  Future<void> put(VaultRecord r) => _items.put(r.id, jsonEncode(r.toJson()));

  Future<void> remove(String id) => _items.delete(id);

  String? meta(String k) => _meta.get(k);

  Future<void> setMeta(String k, String v) => _meta.put(k, v);

  Future<void> removeMeta(String k) => _meta.delete(k);

  Uint8List? blob(String id) => _blobs.get(id);

  Future<void> putBlob(String id, Uint8List data) => _blobs.put(id, data);

  Future<void> removeBlob(String id) => _blobs.delete(id);

  Future<void> clear() async {
    await _items.clear();
    await _meta.clear();
    await _blobs.clear();
  }
}
