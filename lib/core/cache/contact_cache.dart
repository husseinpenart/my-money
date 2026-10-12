import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:money/feature/model/contact/contact_model.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/helper/utils/input_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Entry {
  final ContactModel c;
  final String hay;
  _Entry(this.c, this.hay);
}

String _norm(String s) => normalizeDigits(s)
    .toLowerCase()
    .replaceAll('\u064A', '\u06CC') // ي → ی
    .replaceAll('\u0643', '\u06A9') // ك → ک
    .replaceAll('\u200C', ' ');

final DateTime _epoch = DateTime.fromMillisecondsSinceEpoch(0);

/// منبع واحد داده‌ی مخاطبین و بدهی/طلب روی دستگاه.
/// از سرور فقط با دکمه‌ی رفرش پر می‌شود؛ Commandها نتیجه‌شان را مستقیم اینجا اعمال می‌کنند.
class ContactCache extends ChangeNotifier {
  static const _key = 'cache_contacts_v1';

  final SharedPreferences _prefs;
  final Map<String, Map<String, dynamic>> _raw = {};

  List<_Entry>? _entries;
  ContactStats _stats = const ContactStats(total: 0, demanders: 0, debtors: 0);
  int _version = 0;
  DateTime? _syncedAt;
  Timer? _timer;
  int _batch = 0;
  bool _pending = false;

  ContactCache(this._prefs) {
    _load();
  }

  int get version => _version;
  DateTime? get syncedAt => _syncedAt;
  bool get hasData => _syncedAt != null;

  // ───────────── خواندن ─────────────
  ContactStats get stats {
    _list;
    return _stats;
  }

  List<ContactModel> get contacts => _list.map((e) => e.c).toList();

  List<SearchDebt> get allDebts => _list.expand((e) => e.c.debts).toList();

  ContactModel? byId(String id) {
    final m = _raw[id];
    return m == null ? null : ContactModel.fromJson(m);
  }

  SearchDebt? debtById(String payId) {
    for (final e in _list) {
      for (final d in e.c.debts) {
        if (d.payId == payId) return d;
      }
    }
    return null;
  }

  /// جستجو (همه‌ی کلمه‌ها باید پیدا شوند)، فیلتر و مرتب‌سازی؛ همه محلی
  List<ContactModel> query({
    String query = '',
    ContactFilter filter = ContactFilter.all,
    ContactSort sort = ContactSort.newest,
  }) {
    final terms = _norm(query).split(' ').where((t) => t.isNotEmpty).toList();

    Iterable<_Entry> it = _list;
    if (filter == ContactFilter.demander) {
      it = it.where((e) => e.c.hasUnpaidReceivable);
    } else if (filter == ContactFilter.debtor) {
      it = it.where((e) => e.c.hasUnpaidDebt);
    }

    if (terms.isNotEmpty) {
      it = it.where(
        (e) => terms.every((t) {
          if (t == 'بدهی') return e.c.debts.any((d) => d.isDebt);
          if (t == 'طلب') return e.c.debts.any((d) => !d.isDebt);
          return e.hay.contains(t);
        }),
      );
    }

    final list = it.map((e) => e.c).toList();
    int tie(ContactModel a, ContactModel b) =>
        a.contactId.compareTo(b.contactId);

    list.sort((a, b) {
      final r = switch (sort) {
        ContactSort.newest => (b.createdAt ?? _epoch).compareTo(
          a.createdAt ?? _epoch,
        ),
        ContactSort.oldest => (a.createdAt ?? _epoch).compareTo(
          b.createdAt ?? _epoch,
        ),
        ContactSort.name => a.name.compareTo(b.name),
        ContactSort.mostDebts => b.debts.length.compareTo(a.debts.length),
      };
      return r != 0 ? r : tie(a, b);
    });
    return list;
  }

  // ───────────── نوشتن (از سرور) ─────────────
  void replaceAll(List<Map<String, dynamic>> items, int version) {
    _raw.clear();
    for (final e in items) {
      final id = '${e['contactId']}';
      if (id.isNotEmpty) _raw[id] = _fix(e);
    }
    _version = version;
    _syncedAt = DateTime.now();
    _entries = null;
    _persistNow();
    _notify();
  }

  /// رفرش انجام شد ولی تغییری نبود
  void touchSynced() {
    _syncedAt = DateTime.now();
    _persistSoon();
    _notify();
  }

  /// هدر X-Data-Version بعد از هر Command. فقط اگر دقیقاً یک‌قدم جلوتر باشد،
  /// یعنی کس دیگری تغییری نداده و کش ما کامل است
  void noteServerVersion(int v) {
    if (hasData && v == _version + 1) {
      _version = v;
      _persistSoon();
    }
  }

  // ───────────── Commandها (نتیجه‌ی پاسخ سرور) ─────────────
  void applyContact(Map<String, dynamic> json) {
    final id = '${json['contactId']}';
    if (id.isEmpty) return;
    _raw[id] = _fix(json);
    _changed();
  }

  void removeContact(String id) {
    if (_raw.remove(id) != null) _changed();
  }

  void applyDebt(Map<String, dynamic> json) {
    final payId = '${json['payId']}';
    final target = _raw['${json['contactId']}'];
    if (payId.isEmpty || target == null) return;

    for (final c in _raw.values) {
      (c['debtReceivable'] as List).removeWhere(
        (d) => d is Map && '${d['payId']}' == payId,
      );
    }
    (target['debtReceivable'] as List).add(json);
    _changed();
  }

  void removeDebt(String payId) {
    var removed = false;
    for (final c in _raw.values) {
      final l = c['debtReceivable'] as List;
      final before = l.length;
      l.removeWhere((d) => d is Map && '${d['payId']}' == payId);
      if (l.length != before) removed = true;
    }
    if (removed) _changed();
  }

  /// چند تغییر پشت‌سرهم، فقط یک بار اطلاع‌رسانی (مثلاً ثبت گروهی)
  Future<T> runBatch<T>(Future<T> Function() body) async {
    _batch++;
    try {
      return await body();
    } finally {
      _batch--;
      if (_batch == 0 && _pending) {
        _pending = false;
        notifyListeners();
      }
    }
  }

  Future<void> clear() async {
    _timer?.cancel();
    _raw.clear();
    _entries = null;
    _version = 0;
    _syncedAt = null;
    await _prefs.remove(_key);
    notifyListeners();
  }

  // ───────────── داخلی ─────────────
  List<_Entry> get _list => _entries ??= _build();

  List<_Entry> _build() {
    final out = <_Entry>[];
    var demanders = 0, debtors = 0;
    for (final m in _raw.values) {
      final c = ContactModel.fromJson(m);
      final hay = _norm(
        '${c.name} ${c.phoneNumber} '
        '${c.debts.map((d) => '${d.description ?? ''} ${d.wholePrice}').join(' ')}',
      );
      if (c.hasUnpaidReceivable) demanders++;
      if (c.hasUnpaidDebt) debtors++;
      out.add(_Entry(c, hay));
    }
    _stats = ContactStats(
      total: out.length,
      demanders: demanders,
      debtors: debtors,
    );
    return out;
  }

  Map<String, dynamic> _fix(Map<String, dynamic> e) {
    e['debtReceivable'] = List<dynamic>.from(
      (e['debtReceivable'] as List?) ?? const [],
    );
    return e;
  }

  void _changed() {
    _entries = null;
    _persistSoon();
    if (_batch > 0) {
      _pending = true;
    } else {
      notifyListeners();
    }
  }

  void _notify() {
    if (_batch > 0) {
      _pending = true;
    } else {
      notifyListeners();
    }
  }

  void _load() {
    final s = _prefs.getString(_key);
    if (s == null) return;
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      _version = (m['v'] as num?)?.toInt() ?? 0;
      _syncedAt = DateTime.tryParse('${m['at']}');
      for (final e in (m['items'] as List)) {
        if (e is Map<String, dynamic>) _raw['${e['contactId']}'] = _fix(e);
      }
    } catch (_) {
      _raw.clear();
      _version = 0;
      _syncedAt = null;
    }
  }

  void _persistSoon() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 500), _persistNow);
  }

  void _persistNow() {
    _timer?.cancel();
    try {
      final data = jsonEncode({
        'v': _version,
        'at': _syncedAt?.toIso8601String(),
        'items': _raw.values.toList(),
      });
      // در وب localStorage حدود ۵ مگابایت جا دارد؛ اگر پر شد فقط در حافظه می‌ماند
      _prefs.setString(_key, data);
    } catch (_) {}
  }
}
