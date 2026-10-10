import 'package:flutter/material.dart';

/// تمام مقادیر قابل‌ویرایش اپ در یک فایل. لوگو/کارت‌ها/توسعه‌دهنده/نسخه را اینجا عوض کن.
class AppInfo {
  AppInfo._();

  // 👇 فایل لوگو را در assets/images/logo.png بگذار و در pubspec.yaml:
  //   flutter:
  //     assets:
  //       - assets/images/
  static const String logoAsset = 'assets/images/logo.jpeg';

  static const String appName = 'مدیریت مالی';
  static const String appTagline = 'طلب و بدهی‌ات را ساده مدیریت کن';

  static const String version = '1.0.0';
  static const String buildNumber = '1';
  static const String releaseDate = '۱۴۵/۰۷/۱۹';
  static const String privacyUpdatedAt = '۱۴۰/۰۷/۱۹';

  static const String supportEmail = 'support@mymoney.app';

  static const Developer developer = Developer(
    name: 'نام تو',
    role: 'توسعه‌دهنده‌ی نرم‌افزار',
    bio:
        'این اپ را برای ساده‌کردن مدیریت طلب و بدهی ساختم؛ '
        'بدون پیچیدگی، بدون شلوغی، فقط آنچه لازم داری.',
    github: 'github.com/your-username',
    telegram: '@your_username',
    email: 'dev@mymoney.app',
  );

  // 👇 فعلاً دو شماره کارت (رقم‌ها بدون فاصله)
  static const List<BankCard> cards = [
    BankCard(bank: 'ملی', number: '6037701234567890'),
    BankCard(bank: 'سامان', number: '5022291234567890'),
  ];

  static const List<Feature> features = [
    Feature('ثبت سریع طلب و بدهی', Icons.swap_vert_circle_outlined),
    Feature('پیگیری پرداخت و تسویه', Icons.timelapse_rounded),
    Feature('گزارش‌های مالی و نمودار', Icons.insights_rounded),
    Feature('مدیریت مخاطبین و ستاره‌داری', Icons.star_rounded),
    Feature('بودجه و هزینه‌های دوره‌ای', Icons.pie_chart_outline_rounded),
    Feature('جستجو و فیلتر پیشرفته', Icons.search_rounded),
  ];

  static const List<ChangeLog> changelog = [
    ChangeLog('1.0.0', '۱۴۰۵/۰۷/۱۹', [
      'انتشار اولیه',
      'ثبت/ویرایش/حذف طلب و بدهی',
      'گزارش‌ها، بودجه و مخاطبین',
    ]),
  ];
}

class Developer {
  const Developer({
    required this.name,
    required this.role,
    required this.bio,
    required this.github,
    required this.telegram,
    required this.email,
  });
  final String name, role, bio, github, telegram, email;
}

class BankCard {
  const BankCard({required this.bank, required this.number});
  final String bank, number;
}

class Feature {
  const Feature(this.title, this.icon);
  final String title;
  final IconData icon; // 👈 حالا IconData مستقیم، بدون cast
}

class ChangeLog {
  const ChangeLog(this.version, this.date, this.notes);
  final String version, date;
  final List<String> notes;
}
