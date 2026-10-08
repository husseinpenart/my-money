import 'dart:async';

import 'package:money/feature/model/contact/contact_model.dart';

abstract class ContactEvent {
  const ContactEvent();
}

/// دریافت (یا بازخوانی) صفحه‌ی اول. [done] برای بستن RefreshIndicator
class ContactsFetched extends ContactEvent {
  final Completer<void>? done;
  const ContactsFetched({this.done});
}

class ContactsLoadMore extends ContactEvent {
  const ContactsLoadMore();
}

class ContactCreated extends ContactEvent {
  final String name;
  final String phoneNumber;
  const ContactCreated({required this.name, required this.phoneNumber});
}

/// ثبت گروهی از مخاطبین گوشی
class ContactsImported extends ContactEvent {
  final List<PhoneEntry> entries;
  const ContactsImported(this.entries);
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