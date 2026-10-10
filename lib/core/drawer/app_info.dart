import 'package:flutter/material.dart';

/// تمام مقادیر قابل‌ویرایش اپ در یک فایل.
class AppInfo {
  AppInfo._();

  // 👇 فایل لوگو: assets/images/logo.jpeg (در pubspec.yaml زیر flutter.assets ثبت شده باشد)
  static const String logoAsset = 'assets/images/logo.png';
  static const String appName = 'مدیریت مالی';
  static const String appTagline = 'مدیریت هوشمند طلب، بدهی و بودجه';

  static const String version = '1.0.0';
  static const String buildNumber = '1';
  static const String releaseDate = '۱۴۵/۰۷/۱۹';
  static const String privacyUpdatedAt = '۱۴۰۵/۰۷/۱۹';

  // 👇 پشتیبانی = ایمیل توسعه‌دهنده
  static const String supportEmail = 'hussainasadi1996@gmail.com';

  static const Developer developer = Developer(
    name: 'حسین اسدی',
    // 👈 به‌جای «فول‌استک» (که برای کاربر عادی بی‌معنی است)
    role: 'مهندس نرم‌افزار',
    // 👈 بدون اصطلاح فنی؛ با اعتبار واقعی و به زبان کاربر
    bio:
        'بیش از ۹ سال است نرم‌افزار می‌سازم و در پروژه‌هایی دست داشته‌ام که '
        'ده‌ها هزار نفر از آن‌ها استفاده کرده‌اند. این اپ را با همان وسواسی '
        'ساخته‌ام که یک ابزار مالی لازم دارد: اعداد دقیق، داده‌ی امن، و '
        'استفاده‌ای که خسته‌کننده نباشد.',
    github: 'https://github.com/husseinpenart',
    linkedin: 'https://www.linkedin.com/in/hussain-asadi-1157221b9/',
    telegram: '@Hussainpen',
    email: 'hussainasadi1996@gmail.com',
  );

  // 👇 دو شماره کارت (رقم‌ها بدون فاصله)
  static const List<BankCard> cards = [
    BankCard(bank: 'بلو بانک', number: '6219861878226967'),
    BankCard(bank: 'بانک دی', number: '5029381062878418'),
  ];

  // 👇 قابلیت‌های واقعی، بر اساس صفحات اپ
  static const List<Feature> features = [
    Feature(
      'ثبت و پیگیری طلب و بدهی با وضعیت پرداخت',
      Icons.swap_vert_circle_outlined,
    ),
    Feature(
      'بودجه‌بندی ماهانه با حقوق و سقف خرج روزانه',
      Icons.savings_outlined,
    ),
    Feature(
      'دسته‌بندی هوشمند هزینه‌ها (قبوض، بیمه، حمل‌ونقل و…)',
      Icons.category_outlined,
    ),
    Feature(
      'گزارش تحلیلی: تراز خالص، معوقات و نرخ تسویه',
      Icons.insights_rounded,
    ),
    Feature(
      'روند ماهانه و سن مطالبات به تفکیک مخاطب',
      Icons.query_stats_rounded,
    ),
    Feature('جستجو، فیلتر و مرتب‌سازی پیشرفته', Icons.tune_rounded),
    Feature('ستاره‌دار کردن موارد مهم و دسترسی سریع', Icons.star_rounded),
    Feature(
      'مستندسازی هر رکورد با تصویر و مشاهده‌ی تمام‌صفحه',
      Icons.image_outlined,
    ),
    Feature('امنیت داده و جداسازی کامل هر حساب کاربری', Icons.shield_outlined),
  ];

  static const List<ChangeLog> changelog = [
    ChangeLog('1.0.0', '۱۴۰/۰۷/۹', [
      'انتشار اولیه‌ی اپلیکیشن',
      'ماژول طلب و بدهی با فیلتر، مرتب‌سازی و ویرایش',
      'ماژول بودجه: برنامه، هزینه‌ها، تاریخچه و تنظیمات',
      'ماژول گزارش: شاخص‌ها، دونات، روند ماهانه و معوقات',
      'دسترسی سریع، موارد مهم و جستجوی سراسری',
    ]),
  ];
}

class Developer {
  const Developer({
    required this.name,
    required this.role,
    required this.bio,
    required this.github,
    required this.linkedin,
    required this.telegram,
    required this.email,
  });
  final String name, role, bio, github, linkedin, telegram, email;
}

class BankCard {
  const BankCard({required this.bank, required this.number});
  final String bank, number;
}

class Feature {
  const Feature(this.title, this.icon);
  final String title;
  final IconData icon;
}

class ChangeLog {
  const ChangeLog(this.version, this.date, this.notes);
  final String version, date;
  final List<String> notes;
}
