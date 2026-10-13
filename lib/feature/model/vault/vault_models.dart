import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart'; // برای IconData/Icons/Color (متادیتای UI دسته‌ها)

int _i(dynamic v) => (v is num) ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;

DateTime _dt(dynamic v) =>
    DateTime.tryParse('${v ?? ''}')?.toUtc() ?? DateTime.now().toUtc();

// ───────────── استثناها ─────────────
class VaultApiException implements Exception {
  final String message;
  final bool offline;
  const VaultApiException(this.message, {this.offline = false});
  @override
  String toString() => message;
}

class VaultWrongSecret implements Exception {
  final int triesLeft;
  const VaultWrongSecret(this.triesLeft);
  @override
  String toString() => 'رمز نادرست است';
}

class VaultLockedOut implements Exception {
  final Duration remaining;
  const VaultLockedOut(this.remaining);
  @override
  String toString() => 'گاوصندوق موقتاً قفل است';
}

// ───────────── فایل تازه‌ی انتخاب‌شده (قبل از رمزنگاری) ─────────────
// سازنده positional تا UI بتواند VaultNewFile(name, bytes) صدا بزند.
class VaultNewFile {
  final String name;
  final Uint8List bytes;
  const VaultNewFile(this.name, this.bytes);
}

// ───────────── دسته‌ها ─────────────
/// id داخل داده‌ی رمزشده (VaultPlain.cat) ذخیره می‌شود؛
/// label/icon/color فقط برای UI‌اند و روی سرور نمی‌روند.
/// نام‌ها باید با کلیدهای kVaultFields یکی باشند: asset/document/secret.
enum VaultCategory {
  asset(1, 'دارایی', Icons.savings_outlined, Color(0xFF0EA5E9)),
  document(2, 'اسناد', Icons.description_outlined, Color(0xFFF59E0B)),
  secret(3, 'محرمانه', Icons.privacy_tip_outlined, Color(0xFF8B5CF6));

  const VaultCategory(this.id, this.label, this.icon, this.color);
  final int id;
  final String label;
  final IconData icon;
  final Color color;

  static VaultCategory of(int id) =>
      values.firstWhere((c) => c.id == id, orElse: () => asset);
}

// ───────────── پروفایل گاوصندوق ─────────────
class VaultProfile {
  final String salt, wrappedPass, wrappedPassIv, wrappedRec, wrappedRecIv;
  final int iterations, stamp, revision;

  const VaultProfile({
    required this.salt,
    required this.iterations,
    required this.wrappedPass,
    required this.wrappedPassIv,
    required this.wrappedRec,
    required this.wrappedRecIv,
    this.stamp = 0,
    this.revision = 0,
  });

  factory VaultProfile.fromJson(Map<String, dynamic> j) => VaultProfile(
    salt: '${j['salt']}',
    iterations: _i(j['iterations']),
    wrappedPass: '${j['wrappedPass']}',
    wrappedPassIv: '${j['wrappedPassIv']}',
    wrappedRec: '${j['wrappedRec']}',
    wrappedRecIv: '${j['wrappedRecIv']}',
    stamp: _i(j['stamp']),
    revision: _i(j['revision']),
  );

  Map<String, dynamic> toJson() => {
    'salt': salt,
    'iterations': iterations,
    'wrappedPass': wrappedPass,
    'wrappedPassIv': wrappedPassIv,
    'wrappedRec': wrappedRec,
    'wrappedRecIv': wrappedRecIv,
    'stamp': stamp,
    'revision': revision,
  };
}

// ───────────── محتوای رمزشده‌ی هر رکورد ─────────────
class VaultPlain {
  final String title, note;
  final Map<String, String> fields;
  final int cat;

  const VaultPlain({
    required this.title,
    this.note = '',
    this.fields = const {},
    this.cat = 1,
  });

  Map<String, dynamic> toJson() => {
    't': title,
    'n': note,
    'f': fields,
    'c': cat,
  };

  factory VaultPlain.fromJson(Map<String, dynamic> j) => VaultPlain(
    title: '${j['t'] ?? ''}',
    note: '${j['n'] ?? ''}',
    fields: ((j['f'] as Map?) ?? const {}).map((k, v) => MapEntry('$k', '$v')),
    cat: _i(j['c'] ?? 1),
  );
}

// ───────────── پیوست ─────────────
class VaultAttachment {
  final String id, itemId, encryptedMeta, iv;
  final int size;

  /// 0 = همگام‌شده، 1 = در انتظار آپلود، 2 = در انتظار حذف
  final int state;
  final DateTime createdAt;

  const VaultAttachment({
    required this.id,
    required this.itemId,
    required this.encryptedMeta,
    required this.iv,
    required this.size,
    required this.state,
    required this.createdAt,
  });

  factory VaultAttachment.fromServer(Map<String, dynamic> j) => VaultAttachment(
    id: '${j['id']}',
    itemId: '${j['itemId']}',
    encryptedMeta: '${j['encryptedMeta'] ?? ''}',
    iv: '${j['iv'] ?? ''}',
    size: _i(j['size']),
    state: 0,
    createdAt: _dt(j['createdAt']),
  );

  VaultAttachment copyWith({int? size, int? state}) => VaultAttachment(
    id: id,
    itemId: itemId,
    encryptedMeta: encryptedMeta,
    iv: iv,
    size: size ?? this.size,
    state: state ?? this.state,
    createdAt: createdAt,
  );
}

// ───────────── رکورد (لایه‌ی رمزشده + متادیتای sync) ─────────────
class VaultRecord {
  final String id;

  /// فقط برای sync/سرور؛ دسته‌ی واقعی از plain.cat خوانده می‌شود.
  final int category;
  final String encryptedData, iv;
  final DateTime createdAt, updatedAt;
  final int version; // نسخه‌ی سرور
  final int rev; // شمارنده‌ی ویرایش محلی (برای conflict detection)
  final bool pending;
  final bool isDeleted;
  final List<VaultAttachment> attachments;

  const VaultRecord({
    required this.id,
    required this.category,
    required this.encryptedData,
    required this.iv,
    required this.createdAt,
    required this.updatedAt,
    this.version = 0,
    this.rev = 0,
    this.pending = false,
    this.isDeleted = false,
    this.attachments = const [],
  });

  int get pendingAttachments => attachments.where((a) => a.state != 0).length;

  Map<String, dynamic> toChange() => {
    'id': id,
    'category': category,
    'encryptedData': encryptedData,
    'iv': iv,
    'baseVersion': version,
    'isDeleted': isDeleted,
  };

  factory VaultRecord.fromServer(Map<String, dynamic> j) => VaultRecord(
    id: '${j['id']}',
    category: _i(j['category']),
    encryptedData: '${j['encryptedData'] ?? ''}',
    iv: '${j['iv'] ?? ''}',
    createdAt: _dt(j['createdAt']),
    updatedAt: _dt(j['updatedAt']),
    version: _i(j['version']),
    isDeleted: j['isDeleted'] == true,
    attachments: ((j['attachments'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(VaultAttachment.fromServer)
        .toList(),
  );

  static VaultRecord tombstone(String id, int version) => VaultRecord(
    id: id,
    category: 1,
    encryptedData: '',
    iv: '',
    createdAt: DateTime.now().toUtc(),
    updatedAt: DateTime.now().toUtc(),
    version: version,
    isDeleted: true,
  );

  VaultRecord copyWith({
    int? category,
    String? encryptedData,
    String? iv,
    DateTime? updatedAt,
    int? version,
    int? rev,
    bool? pending,
    bool? isDeleted,
    List<VaultAttachment>? attachments,
  }) => VaultRecord(
    id: id,
    category: category ?? this.category,
    encryptedData: encryptedData ?? this.encryptedData,
    iv: iv ?? this.iv,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
    rev: rev ?? this.rev,
    pending: pending ?? this.pending,
    isDeleted: isDeleted ?? this.isDeleted,
    attachments: attachments ?? this.attachments,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'encryptedData': encryptedData,
    'iv': iv,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'version': version,
    'rev': rev,
    'pending': pending,
    'isDeleted': isDeleted,
    'attachments': attachments
        .map(
          (a) => {
            'id': a.id,
            'itemId': a.itemId,
            'encryptedMeta': a.encryptedMeta,
            'iv': a.iv,
            'size': a.size,
            'state': a.state,
            'createdAt': a.createdAt.toIso8601String(),
          },
        )
        .toList(),
  };

  factory VaultRecord.fromJson(Map<String, dynamic> j) => VaultRecord(
    id: '${j['id']}',
    category: _i(j['category']),
    encryptedData: '${j['encryptedData'] ?? ''}',
    iv: '${j['iv'] ?? ''}',
    createdAt: _dt(j['createdAt']),
    updatedAt: _dt(j['updatedAt']),
    version: _i(j['version']),
    rev: _i(j['rev']),
    pending: j['pending'] == true,
    isDeleted: j['isDeleted'] == true,
    attachments: ((j['attachments'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (a) => VaultAttachment(
            id: '${a['id']}',
            itemId: '${a['itemId']}',
            encryptedMeta: '${a['encryptedMeta'] ?? ''}',
            iv: '${a['iv'] ?? ''}',
            size: _i(a['size']),
            state: _i(a['state']),
            createdAt: _dt(a['createdAt']),
          ),
        )
        .toList(),
  );
}

// ───────────── نمای رمزگشایی‌شده برای UI ─────────────
class VaultEntry {
  final VaultRecord record;
  final VaultPlain? plain;
  const VaultEntry(this.record, this.plain);

  String get id => record.id;
  bool get pending => record.pending;
  int get version => record.version;
  DateTime get updatedAt => record.updatedAt;
  List<VaultAttachment> get attachments => record.attachments;

  VaultCategory get category => VaultCategory.of(plain?.cat ?? 1);

  /// عنوان برای لیست/دیتیل؛ اگر رمزگشایی نشده باشد '—'.
  String get title => plain?.title ?? '—';

  /// true یعنی داده رمزگشایی نشد (خراب/دستکاری‌شده) → در UI قرمز نمایش داده می‌شود.
  bool get corrupt => plain == null;

  /// تعداد پیوست‌های قابل‌مشاهده (حذف‌شده‌های در انتظار ارسال شمرده نمی‌شوند).
  int get visibleAttachments =>
      record.attachments.where((a) => a.state != 2).length;
}

// ───────────── نتیجه‌ی sync ─────────────
class VaultSyncResult {
  final int cursor;
  final bool hasMore;
  final int profileStamp;
  final int profileRevision;
  final bool fullReload;
  final Map<String, int> accepted;
  final Set<String> conflicts;
  final List<Map<String, dynamic>> items;

  const VaultSyncResult({
    required this.cursor,
    required this.hasMore,
    required this.profileStamp,
    required this.profileRevision,
    required this.fullReload,
    required this.accepted,
    required this.conflicts,
    required this.items,
  });
}

class VaultUploadResult {
  final int size;
  final int itemVersion;
  const VaultUploadResult(this.size, this.itemVersion);
}
