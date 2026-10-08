/// آدرس سرور برای ساخت لینک تصاویر (مسیرهای نسبی covers)
const String kFilesBaseUrl = 'http://192.168.1.185:8085/uploads';

String resolveFileUrl(String path) {
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  final base = kFilesBaseUrl.endsWith('/')
      ? kFilesBaseUrl.substring(0, kFilesBaseUrl.length - 1)
      : kFilesBaseUrl;
  return path.startsWith('/') ? '$base$path' : '$base/$path';
}