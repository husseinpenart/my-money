import 'package:flutter/material.dart';

/// تمام مقادیر قابل‌ویرایش اپ در یک فایل.
class AppInfo {
  AppInfo._();

  // فایل لوگو باید در pubspec.yaml زیر flutter.assets ثبت شده باشد
  static const String logoAsset = 'assets/images/logo.png';
  static const String appName = 'مدیریت مالی';
  static const String appTagline = 'مدیریت هوشمند طلب، بدهی و بودجه';

  static const String version = '1.0.0';
  static const String buildNumber = '1';

  // تاریخ‌ها شمسی‌اند
  static const String releaseDate = '۱۴۰۵/۰۷/۱۹';
  static const String privacyUpdatedAt = '۱۴۰۵/۰۷/۱۹';
  static const String copyrightYear = '۱۴۰۵';

  static const String supportEmail = 'hussainasadi1996@gmail.com';

  static const Developer developer = Developer(
    name: 'حسین اسدی',
    role: 'مهندس نرم‌افزار',
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

  static const List<BankCard> cards = [
    BankCard(bank: 'بلو بانک', number: '6219861878226967'),
    BankCard(bank: 'بانک دی', number: '5029381062878418'),
  ];

  static const List<Feature> features = [
    Feature(
      'ثبت و پیگیری طلب و بدهی با وضعیت پرداخت',
      Icons.swap_vert_circle_outlined,
    ),
    Feature(
      'اعلان سررسید: معوق، امروز و ۳ روز مانده',
      Icons.notifications_active_outlined,
    ),
    Feature(
      'بودجه‌بندی ماهانه با حقوق و سقف خرج روزانه',
      Icons.savings_outlined,
    ),
    Feature(
      'مدیریت حقوق دیرکرده، کسری و بیش‌خرجی با هشدار هوشمند',
      Icons.event_repeat_rounded,
    ),
    Feature(
      'دسته‌بندی هزینه‌ها (قبوض، بیمه، خودرو، خرید خانه و…)',
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
    Feature(
      'جستجوی سراسری در مخاطبین و رکوردها، با فیلتر و مرتب‌سازی',
      Icons.tune_rounded,
    ),
    Feature(
      'مستندسازی هر رکورد با چند تصویر و بزرگ‌نمایی',
      Icons.image_outlined,
    ),
    Feature(
      'بازیابی رمز عبور با کد بازیابی، بدون نیاز به پیامک یا ایمیل',
      Icons.vpn_key_outlined,
    ),
    Feature(
      'جداسازی کامل داده‌ی هر حساب و امکان حذف کامل حساب',
      Icons.shield_outlined,
    ),
  ];

  static const List<ChangeLog> changelog = [
    ChangeLog('1.0.0', releaseDate, [
      'انتشار اولیه‌ی اپلیکیشن',
      'ماژول طلب و بدهی با فیلتر، مرتب‌سازی، ویرایش و تصاویر پیوست',
      'ماژول بودجه: برنامه، هزینه‌ها، تاریخچه و تنظیمات، با پشتیبانی از حقوق دیرکرده',
      'ماژول گزارش: شاخص‌ها، دونات، روند ماهانه و معوقات',
      'اعلان سررسید، جستجوی سراسری و صفحه‌ی جزئیات مخاطب',
      'بازیابی رمز با کد بازیابی و امکان حذف حساب',
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
