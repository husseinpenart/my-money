import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:money/core/network/api_client.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/model/vault/vault_models.dart';

class VaultRemoteDataSource {
  final ApiClient api;
  VaultRemoteDataSource(this.api);

  Future<T> _call<T>(Future<T> Function() f) async {
    try {
      return await f();
    } on DioException catch (e) {
      if (e.response == null) {
        throw VaultApiException('اتصال به سرور برقرار نشد', offline: true);
      }
      throw VaultApiException(backendMessage(e));
    }
  }

  dynamic _unwrap(dynamic body) {
    if (body is! Map<String, dynamic>) return null;
    final sc = body['statusCode'];
    if (body['success'] == false || (sc is int && sc >= 400)) {
      final errors = extractApiMessages(body['errors']);
      final msgs = errors.isNotEmpty
          ? errors
          : extractApiMessages(body['message']);
      throw VaultApiException(
        msgs.isNotEmpty ? msgs.join('\n') : 'عملیات ناموفق بود',
      );
    }
    return body['data'];
  }

  Future<VaultProfile?> getProfile() => _call(() async {
    final res = await api.get<dynamic>('/Vault/profile');
    final d = _unwrap(res.data);
    return d is Map<String, dynamic> ? VaultProfile.fromJson(d) : null;
  });

  Future<VaultProfile> setup(VaultProfile p) => _call(() async {
    final res = await api.post<dynamic>('/Vault/profile', data: p.toJson());
    final d = _unwrap(res.data);
    if (d is! Map<String, dynamic>)
      throw VaultApiException('پاسخ نامعتبر از سرور');
    return VaultProfile.fromJson(d);
  });

  Future<VaultProfile> updateProfile(
    VaultProfile p,
    String account,
    int baseRevision,
  ) => _call(() async {
    final res = await api.put<dynamic>(
      '/Vault/profile',
      data: {
        ...p.toJson(),
        'currentPassword': account,
        'baseRevision': baseRevision,
      },
    );
    final d = _unwrap(res.data);
    if (d is! Map<String, dynamic>)
      throw VaultApiException('پاسخ نامعتبر از سرور');
    return VaultProfile.fromJson(d);
  });

  Future<VaultSyncResult> sync(int since, List<Map<String, dynamic>> changes) =>
      _call(() async {
        final res = await api.post<dynamic>(
          '/Vault/sync',
          data: {'since': since, 'changes': changes},
        );
        final d = _unwrap(res.data);
        if (d is! Map<String, dynamic>)
          throw VaultApiException('پاسخ نامعتبر از سرور');
        return VaultSyncResult(
          cursor: (d['cursor'] as num?)?.toInt() ?? 0,
          hasMore: d['hasMore'] == true,
          profileStamp: (d['profileStamp'] as num?)?.toInt() ?? 0,
          profileRevision: (d['profileRevision'] as num?)?.toInt() ?? 0,
          fullReload: d['fullReload'] == true,
          accepted: {
            for (final a
                in ((d['accepted'] as List?) ?? const []).whereType<Map>())
              '${a['id']}': (a['version'] as num).toInt(),
          },
          conflicts: ((d['conflicts'] as List?) ?? const [])
              .map((e) => '$e')
              .toSet(),
          items: ((d['items'] as List?) ?? const [])
              .whereType<Map<String, dynamic>>()
              .toList(),
        );
      });

  Future<VaultUploadResult> upload({
    required String id,
    required String itemId,
    required String iv,
    required String meta,
    required Uint8List bytes,
  }) => _call(() async {
    final form = FormData.fromMap({
      'Id': id,
      'ItemId': itemId,
      'Iv': iv,
      'EncryptedMeta': meta,
    });
    form.files.add(
      MapEntry(
        'File',
        MultipartFile.fromBytes(
          bytes,
          filename: 'blob.bin',
          contentType: MediaType('application', 'octet-stream'),
        ),
      ),
    );
    final res = await api.post<dynamic>('/Vault/attachment', data: form);
    final d = _unwrap(res.data);
    if (d is! Map<String, dynamic>)
      throw VaultApiException('پاسخ نامعتبر از سرور');
    return VaultUploadResult(
      (d['size'] as num?)?.toInt() ?? bytes.length,
      (d['itemVersion'] as num?)?.toInt() ?? 0,
    );
  });

  Future<Uint8List> download(String id) => _call(() async {
    final res = await api.get<List<int>>(
      '/Vault/attachment/$id',
      responseType: ResponseType.bytes,
    );
    return Uint8List.fromList(res.data ?? const []);
  });

  /// نسخه‌ی جدید آیتم (۰ اگر پیوست از قبل حذف شده بود)
  Future<int> deleteAttachment(String id) => _call(() async {
    final res = await api.delete<dynamic>('/Vault/attachment/$id');
    final d = _unwrap(res.data);
    return d is num ? d.toInt() : 0;
  });

  Future<void> reset(String accountPassword) => _call(() async {
    final res = await api.post<dynamic>(
      '/Vault/reset',
      data: {'currentPassword': accountPassword},
    );
    _unwrap(res.data);
  });
}
