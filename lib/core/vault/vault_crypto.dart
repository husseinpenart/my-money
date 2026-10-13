import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class VaultCryptoException implements Exception {
  @override
  String toString() => 'رمزگشایی ناموفق بود؛ داده خراب یا دستکاری شده است';
}

class Sealed {
  final String iv; // Base64
  final Uint8List data; // Ciphertext + Tag

  const Sealed(this.iv, this.data);

  String get dataB64 => base64Encode(data);
}

/// AES-256-GCM + PBKDF2-HMAC-SHA256
///
/// هر رکورد IV تصادفی ۱۲ بایتی دارد و شناسه/هدف آن به‌عنوان AAD به رمز گره می‌خورد،
/// پس جابه‌جا کردن Ciphertext بین رکوردها یا بین purposeها توسط مهاجم شناسایی می‌شود.
class VaultCrypto {
  VaultCrypto._();

  static const int kIterations = 200000;
  static const int _ivLen = 12;
  static const int _macLen = 16;

  static final Random _rng = Random.secure();
  static final AesGcm _aes = AesGcm.with256bits();

  static Uint8List randomBytes(int n) =>
      Uint8List.fromList(List<int>.generate(n, (_) => _rng.nextInt(256)));

  /// UUID نسخه‌ی ۴
  static String newId() {
    final b = randomBytes(16);
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }

  static Future<SecretKey> deriveKey(
    String secret,
    Uint8List salt,
    int iterations,
  ) {
    final kdf = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );
    return kdf.deriveKeyFromPassword(password: secret, nonce: salt);
  }

  static Future<Sealed> seal(
    SecretKey key,
    List<int> plain, {
    List<int> aad = const [],
  }) async {
    final iv = randomBytes(_ivLen);
    final box = await _aes.encrypt(plain, secretKey: key, nonce: iv, aad: aad);
    return Sealed(
      base64Encode(iv),
      Uint8List.fromList([...box.cipherText, ...box.mac.bytes]),
    );
  }

  static Future<Uint8List> open(
    SecretKey key,
    String ivB64,
    List<int> data, {
    List<int> aad = const [],
  }) async {
    try {
      if (data.length < _macLen) throw VaultCryptoException();

      final ct = data.sublist(0, data.length - _macLen);
      final tag = data.sublist(data.length - _macLen);

      final box = SecretBox(ct, nonce: base64Decode(ivB64), mac: Mac(tag));

      return Uint8List.fromList(
        await _aes.decrypt(box, secretKey: key, aad: aad),
      );
    } on SecretBoxAuthenticationError {
      throw VaultCryptoException();
    } on FormatException {
      throw VaultCryptoException();
    }
  }

  static Future<Sealed> sealString(
    SecretKey key,
    String text, {
    List<int> aad = const [],
  }) => seal(key, utf8.encode(text), aad: aad);

  static Future<String> openString(
    SecretKey key,
    String ivB64,
    String dataB64, {
    List<int> aad = const [],
  }) async {
    final bytes = await open(key, ivB64, base64Decode(dataB64), aad: aad);
    return utf8.decode(bytes);
  }

  // ───────── Key Wrapping ─────────

  /// یک DEK را با KEK رمز می‌کند.
  ///
  /// purpose مثلاً:
  /// - `pass` برای کلید رمز عبور
  /// - `rec`  برای کلید بازیابی
  ///
  /// AAD باعث می‌شود یک کلید رمز شده فقط برای همان purpose قابل باز کردن باشد.
  static Future<Sealed> wrapKey(SecretKey kek, List<int> dek, String purpose) =>
      seal(kek, dek, aad: utf8.encode('dek|$purpose'));

  /// اگر KEK اشتباه باشد، purpose اشتباه باشد، یا داده دستکاری شده باشد،
  /// GCM tag معتبر نیست و VaultCryptoException پرتاب می‌شود.
  static Future<SecretKey> unwrapKey(
    SecretKey kek,
    String ivB64,
    String dataB64,
    String purpose,
  ) async {
    final bytes = await open(
      kek,
      ivB64,
      base64Decode(dataB64),
      aad: utf8.encode('dek|$purpose'),
    );
    return SecretKey(bytes);
  }

  // ───────── کلید بازیابی: ۲۵۶ بیت، Base32 (Crockford) + چک‌سام ─────────

  /// الفبای Crockford Base32:
  /// بدون I, L, O, U برای کاهش اشتباه تایپی.
  static const _a = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

  static String _b32(List<int> bytes) {
    final sb = StringBuffer();
    var acc = 0;
    var bits = 0;

    for (final b in bytes) {
      acc = (acc << 8) | b;
      bits += 8;

      while (bits >= 5) {
        sb.write(_a[(acc >> (bits - 5)) & 31]);
        bits -= 5;
      }

      acc &= (1 << bits) - 1;
    }

    if (bits > 0) {
      sb.write(_a[(acc << (5 - bits)) & 31]);
    }

    return sb.toString();
  }

  static Uint8List? _unb32(String s, int nBytes) {
    var acc = 0;
    var bits = 0;
    final out = <int>[];

    for (final ch in s.split('')) {
      final v = _a.indexOf(ch);
      if (v < 0) return null;

      acc = (acc << 5) | v;
      bits += 5;

      if (bits >= 8) {
        out.add((acc >> (bits - 8)) & 255);
        bits -= 8;
        acc &= (1 << bits) - 1;
      }
    }

    if (out.length < nBytes) return null;
    return Uint8List.fromList(out.sublist(0, nBytes));
  }

  /// ۴ کاراکتر چک‌سام از SHA-256 کلید.
  /// فقط برای تشخیص اشتباه تایپی است، نه امنیت رمزنگاریی.
  static Future<String> _checksum(List<int> bytes) async {
    final h = await Sha256().hash(bytes);
    return _b32(h.bytes.sublist(0, 3)).substring(0, 4);
  }

  /// خروجی: ۵۶ کاراکتر در ۱۴ گروه ۴تایی.
  ///
  /// مثال:
  /// XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-XXXX-CHK1
  ///
  /// ۵۲ کاراکتر اول = کلید ۳۲ بایتی
  /// ۴ کاراکتر آخر = چک‌سام
  static Future<String> formatRecoveryKey(Uint8List key) async {
    final s = _b32(key) + (await _checksum(key));
    return [
      for (var i = 0; i < s.length; i += 4) s.substring(i, i + 4),
    ].join('-');
  }

  /// ورودی کاربر را نرمال می‌کند و در صورت معتبر بودن چک‌سام، کلید ۳۲ بایتی را برمی‌گرداند.
  ///
  /// اگر:
  /// - طول درست نباشد
  /// - کاراکتر نامجاز داشته باشد
  /// - چک‌سام نخورد
  ///
  /// مقدار null برمی‌گرداند.
  static Future<Uint8List?> parseRecoveryKey(String input) async {
    final s = input
        .toUpperCase()
        .replaceAll(RegExp(r'[^0-9A-Z]'), '')
        .replaceAll('I', '1')
        .replaceAll('L', '1')
        .replaceAll('O', '0');

    if (s.length != 56) return null;

    final key = _unb32(s.substring(0, 52), 32);
    if (key == null) return null;

    final expected = await _checksum(key);
    if (expected != s.substring(52)) return null;

    return key;
  }
}
