import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class CoverImage {
  final String id;
  final String name;
  final Uint8List? bytes; // تصویر جدید (انتخاب‌شده در همین فرم)
  final String? url; // تصویر قبلی روی سرور (ویرایش)

  const CoverImage({
    required this.id,
    required this.name,
    this.bytes,
    this.url,
  });

  bool get isLocal => bytes != null;
  int get size => bytes?.lengthInBytes ?? 0;
}

class CoverController extends ValueNotifier<List<CoverImage>> {
  CoverController([List<CoverImage> initial = const []])
    : super(List<CoverImage>.of(initial));

  static const int maxImages = 10;
  static const int maxBytes = 5 * 1024 * 1024; // ۵ مگابایت برای هر تصویر
  static const List<String> _extensions = ['jpg', 'jpeg', 'png', 'webp', 'gif'];

  int _seq = 0;
  String _newId() => 'c${DateTime.now().microsecondsSinceEpoch}_${_seq++}';

  List<CoverImage> get locals => value.where((e) => e.isLocal).toList();

  /// چند تصویر اضافه می‌کند. اگر مورد ردشده‌ای بود پیام برمی‌گرداند
  Future<String?> pickAndAdd() async {
    final room = maxImages - value.length;
    if (room <= 0) return 'حداکثر $maxImages تصویر مجاز است';

    final res = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _extensions,
      allowMultiple: true,
      withData: true, // در وب برای خواندن bytes لازم است
    );
    if (res == null) return null;

    final added = <CoverImage>[];
    var tooBig = 0, unreadable = 0, overflow = 0;

    for (final f in res.files) {
      final bytes = f.bytes;
      if (bytes == null) {
        unreadable++;
        continue;
      }
      if (bytes.lengthInBytes > maxBytes) {
        tooBig++;
        continue;
      }
      if (added.length >= room) {
        overflow++;
        continue;
      }
      added.add(CoverImage(id: _newId(), name: f.name, bytes: bytes));
    }

    if (added.isNotEmpty) value = [...value, ...added];

    final msgs = <String>[
      if (tooBig > 0) '$tooBig تصویر بزرگ‌تر از ۵ مگابایت بود',
      if (overflow > 0) '$overflow تصویر به‌دلیل سقف $maxImages عدد اضافه نشد',
      if (unreadable > 0) '$unreadable فایل خوانده نشد',
    ];
    return msgs.isEmpty ? null : msgs.join('؛ ');
  }

  /// جایگزینی یک تصویر با تصویر دیگر (در همان جایگاه)
  Future<String?> pickAndReplace(String id) async {
    final res = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _extensions,
      allowMultiple: false,
      withData: true,
    );
    final f = res?.files.firstOrNull;
    if (f == null) return null;
    final bytes = f.bytes;
    if (bytes == null) return 'فایل خوانده نشد';
    if (bytes.lengthInBytes > maxBytes) {
      return 'حجم تصویر بیشتر از ۵ مگابایت است';
    }

    value = [
      for (final e in value)
        e.id == id ? CoverImage(id: _newId(), name: f.name, bytes: bytes) : e,
    ];
    return null;
  }

  void remove(String id) => value = value.where((e) => e.id != id).toList();

  void move(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final list = List<CoverImage>.of(value);
    list.insert(newIndex, list.removeAt(oldIndex));
    value = list;
  }
}
