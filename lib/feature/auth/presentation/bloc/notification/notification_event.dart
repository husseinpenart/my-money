import 'dart:async';

import 'package:money/feature/model/notification/notification_models.dart';

abstract class NotificationEvent {
  const NotificationEvent();
}

/// خواندن وضعیت ذخیره‌شده + شمارنده
class NotificationStarted extends NotificationEvent {
  const NotificationStarted();
}

/// فقط شمارنده (برای زنگوله)
class NotificationSummaryRequested extends NotificationEvent {
  const NotificationSummaryRequested();
}

/// بارگذاری صفحه‌ی اول لیست + شمارنده
class NotificationRefreshed extends NotificationEvent {
  final Completer<void>? done;
  const NotificationRefreshed({this.done});
}

class NotificationQueryChanged extends NotificationEvent {
  final String query;
  const NotificationQueryChanged(this.query);
}

class NotificationFilterChanged extends NotificationEvent {
  final NotificationFilter filter;
  const NotificationFilterChanged(this.filter);
}

class NotificationLoadMore extends NotificationEvent {
  const NotificationLoadMore();
}

class NotificationRead extends NotificationEvent {
  final String key;
  const NotificationRead(this.key);
}

class NotificationAllRead extends NotificationEvent {
  const NotificationAllRead();
}