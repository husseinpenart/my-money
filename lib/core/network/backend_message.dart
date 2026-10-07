import 'package:dio/dio.dart';

/// پیام‌های داخل response بک‌اند را استخراج می‌کند.
///
/// پشتیبانی از:
/// errors: List<String>
/// errors: Map<String, List<String>>
/// message: String
/// data.errors
/// data.message
List<String> extractApiMessages(dynamic value) {
  final List<String> messages = [];
  final Set<String> seen = {};

  void addText(String text) {
    final String trimmed = text.trim();

    if (trimmed.isEmpty) {
      return;
    }

    if (seen.contains(trimmed)) {
      return;
    }

    seen.add(trimmed);
    messages.add(trimmed);
  }

  void addDynamic(dynamic item) {
    if (item == null) {
      return;
    }

    if (item is String) {
      addText(item);
      return;
    }

    if (item is List) {
      for (final dynamic child in item) {
        addDynamic(child);
      }
      return;
    }

    if (item is Map) {
      final dynamic directMessage =
          item['message'] ??
          item['msg'] ??
          item['error'] ??
          item['errors'] ??
          item['description'] ??
          item['detail'] ??
          item['title'];

      if (directMessage != null) {
        addDynamic(directMessage);
      }

      for (final dynamic child in item.values) {
        addDynamic(child);
      }

      return;
    }
  }

  addDynamic(value);

  return messages;
}

String _friendlyGenericMessage(List<String> messages) {
  if (messages.length == 1) {
    final String lower = messages.first.toLowerCase();

    if (lower.contains('unhandled input error')) {
      return 'ورودی نامعتبر است. لطفا فیلدهای فرم را بررسی کنید.';
    }
  }

  return messages.join('\n');
}

String backendMessage(Object error) {
  if (error is! DioException) {
    return error.toString();
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'زمان ارتباط با سرور به پایان رسید.';

    case DioExceptionType.badCertificate:
      return 'گواهی امنیتی سرور مورد قبول نیست.';

    case DioExceptionType.cancel:
      return 'درخواست لغو شد.';

    case DioExceptionType.connectionError:
      return 'اتصال به سرور برقرار نشد. آدرس، پورت، فایروال یا Cleartext Traffic را بررسی کنید.';

    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      break;

    default:
      break;
  }

  final dynamic data = error.response?.data;
  final List<String> messages = [];

  if (data is Map<String, dynamic>) {
    messages.addAll(extractApiMessages(data['errors']));

    if (messages.isEmpty) {
      messages.addAll(extractApiMessages(data['message']));
    }

    if (messages.isEmpty) {
      final dynamic innerData = data['data'];

      if (innerData is Map<String, dynamic>) {
        messages.addAll(extractApiMessages(innerData['errors']));

        if (messages.isEmpty) {
          messages.addAll(extractApiMessages(innerData['message']));
        }
      }
    }
  } else if (data is String) {
    messages.addAll(extractApiMessages(data));
  }

  if (messages.isNotEmpty) {
    return _friendlyGenericMessage(messages);
  }

  final int? statusCode = error.response?.statusCode;

  if (statusCode != null) {
    switch (statusCode) {
      case 400:
        return 'درخواست نامعتبر است.';

      case 401:
        return 'احراز هویت ناموفق بود.';

      case 403:
        return 'شما دسترسی لازم را ندارید.';

      case 404:
        return 'آدرس API پیدا نشد. baseUrl و مسیر endpoint را بررسی کنید.';

      case 409:
        return 'تعارض در داده‌ها وجود دارد.';

      case 422:
        return 'داده‌های ارسالی اعتبارسنجی نشدند.';

      case 500:
        return 'خطای داخلی سرور رخ داد.';

      default:
        return 'خطای سرور با کد $statusCode.';
    }
  }

  return 'خطای نامشخصی رخ داد.';
}
