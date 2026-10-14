import 'dart:async';
import 'package:money/feature/model/contact/contact_model.dart';

abstract class ContactEvent {
  const ContactEvent();
}

/// ورود به صفحه: اگر کش دارد فقط محلی، وگرنه اولین دانلود
class ContactsFetched extends ContactEvent {
  final Completer<void>? done;
  const ContactsFetched({this.done});
}

/// دکمه‌ی رفرش / کشیدن به پایین: همگام‌سازی با سرور
class ContactsRefreshed extends ContactEvent {
  final Completer<void>? done;
  const ContactsRefreshed({this.done});
}

class ContactsLocalChanged extends ContactEvent {
  const ContactsLocalChanged();
}

class ContactsLoadMore extends ContactEvent {
  const ContactsLoadMore();
}

class ContactQueryChanged extends ContactEvent {
  final String query;
  const ContactQueryChanged(this.query);
}

class ContactFilterChanged extends ContactEvent {
  final ContactFilter filter;
  const ContactFilterChanged(this.filter);
}

class ContactSortChanged extends ContactEvent {
  final ContactSort sort;
  const ContactSortChanged(this.sort);
}

class ContactCreated extends ContactEvent {
  final String name;
  final String phoneNumber; // اختیاری؛ خالی یعنی بدون شماره
  const ContactCreated({required this.name, this.phoneNumber = ''});
}

class ContactUpdated extends ContactEvent {
  final String contactId;
  final String name;
  final String phoneNumber;
  const ContactUpdated({
    required this.contactId,
    required this.name,
    required this.phoneNumber,
  });
}

class ContactDeleted extends ContactEvent {
  final String contactId;
  const ContactDeleted(this.contactId);
}
