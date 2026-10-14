import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// تمام مقادیر قابل‌ویرایش اپ در یک فایل.
class AppInfo {
  AppInfo._();

  // فایل لوگو باید در pubspec.yaml زیر flutter.assets ثبت شده باشد
  static const String logoAsset = 'assets/images/logo.png';
  static const String appName = 'مدیریت مالی';
  static const String appTagline = 'مدیریت هوشمند طلب، بدهی و بودجه';

  // 👇 این دو دیگر const نیستند؛ در runtime از بیلد واقعی پر می‌شوند.
  // مقادیر پایین فقط fallback‌اند (اگر خواندن نسخه شکست بخورد، اپ کرش نمی‌کند).
  static String version = '1.0.0';
  static String buildNumber = '1';

  /// نسخه‌ی واقعیِ build شده را از پلتفرم می‌خواند.
  /// باید قبل از runApp صدا زده شود (در main.dart).
  static Future<void> init() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) version = info.version;
      if (info.buildNumber.isNotEmpty) buildNumber = info.buildNumber;
    } catch (_) {
      // خواندن نشد → همان fallback بالا می‌ماند.
    }
  }

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
      '**گاوصندوق امن:** طلا، سند، چک و اطلاعات محرمانه‌ات را طوری نگه می‌دارد که حتی سازنده‌ی اپ هم نتواند بخواند',
      Icons.shield_moon_outlined,
    ),
    Feature(
      'ثبت و پیگیری طلب و بدهی با وضعیت پرداخت و **چند تصویر پیوست**',
      Icons.swap_vert_circle_outlined,
    ),
    Feature(
      '**اعلان سررسید:** معوق، امروز و ۳ روز مانده',
      Icons.notifications_active_outlined,
    ),
    Feature(
      'بودجه‌بندی ماهانه با حقوق و سقف خرج روزانه، حتی وقتی **حقوق دیر می‌رسد**',
      Icons.savings_outlined,
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
      '**سریع و کم‌مصرف:** اطلاعات روی گوشی ذخیره می‌شود و هر بار از اینترنت نمی‌آید',
      Icons.bolt_rounded,
    ),
    Feature(
      'جستجوی سراسری در مخاطبین و رکوردها، با فیلتر و مرتب‌سازی',
      Icons.tune_rounded,
    ),
    Feature(
      '**بازیابی رمز بدون پیامک و ایمیل** با کد بازیابی',
      Icons.vpn_key_outlined,
    ),
    Feature(
      'جداسازی کامل داده‌ی هر حساب و **حذف کامل حساب** هر وقت خواستی',
      Icons.delete_sweep_outlined,
    ),
  ];

  // 👇 changelog تاریخِ ثابتِ هر انتشار است؛ پس version هر entry یک رشته‌ی
  // const می‌ماند (نه AppInfo.version). وقتی نسخه بالا رفت، یک ChangeLog
  // جدید با عدد جدید به این لیست اضافه کن — entry قبلی دست نمی‌خورد.
  static const List<ChangeLog> changelog = [
    ChangeLog('1.0.0', releaseDate, [
      'انتشار اولیه‌ی اپلیکیشن',
      'ماژول طلب و بدهی با فیلتر، مرتب‌سازی، ویرایش و تصاویر پیوست',
      'ماژول بودجه: برنامه، هزینه‌ها، تاریخچه و تنظیمات، با پشتیبانی از حقوق دیرکرده',
      'ماژول گزارش: شاخص‌ها، دونات، روند ماهانه و معوقات',
      'اعلان سررسید، جستجوی سراسری و صفحه‌ی جزئیات مخاطب',
      'گاوصندوق امن با رمزنگاری کامل روی دستگاه و کلید بازیابی',
      'ذخیره‌ی محلی و همگام‌سازی سریع با دکمه‌ی بروزرسانی',
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
