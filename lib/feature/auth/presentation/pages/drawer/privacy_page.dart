import 'package:flutter/material.dart';
import 'package:money/core/drawer/app_info.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/drawer/rich_line.dart';
import 'package:money/widgets/drawer/section_card.dart';

const _sky = Color(0xFF0EA5E9);
const _purple = Color(0xFF7C3AED);
const _green = Color(0xFF10B981);
const _amber = Color(0xFFD97706);
const _blueGrey = Color(0xFF607D8B);
const _grey700 = Color(0xFF616161);

/// این صفحه باید با عملکرد واقعی برنامه و سند سیاست حریم خصوصی
/// نمایش‌داده‌شده هنگام ثبت‌نام یکسان باشد.
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'حریم خصوصی کاربران',
            style: sans(size: 16, weight: FontWeight.bold),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFF059669),
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'خلاصه‌ی ساده',
                          style: sans(
                            size: 13.5,
                            weight: FontWeight.bold,
                            color: const Color(0xFF065F46),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const RichLine(
                          '**اطلاعاتت را نمی‌فروشیم** و برای تبلیغات در اختیار دیگران '
                          'قرار نمی‌دهیم. محتوای گاوصندوق پیش از ارسال به سرور '
                          'روی دستگاه رمزنگاری می‌شود. می‌توانی اطلاعاتت را '
                          'مدیریت و حساب خود را حذف کنی؛ جزئیات حذف و مهلت '
                          'پاک‌سازی نسخه‌های پشتیبان را پایین‌تر توضیح داده‌ایم.',
                          color: Color(0xFF047857),
                          boldColor: Color(0xFF065F46),
                          size: 12.5,
                          height: 1.8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionCard(
              icon: Icons.info_outline_rounded,
              title: 'درباره‌ی این سیاست',
              color: _blueGrey,
              child: RichLine(
                'این صفحه توضیح می‌دهد «پول من» چه اطلاعاتی را، برای چه هدفی، '
                'کجا و تا چه زمانی نگهداری می‌کند و چه انتخاب‌هایی داری. '
                'پردازش اطلاعات در چارچوب قوانین قابل اعمال جمهوری اسلامی ایران، '
                'از جمله مقررات مرتبط قانون تجارت الکترونیکی و قانون جرایم '
                'رایانه‌ای، انجام می‌شود. شرایط قراردادی استفاده از خدمات '
                'در سند جداگانه‌ی «شرایط استفاده» آمده است.',
              ),
            ),
            SectionCard(
              icon: Icons.shield_moon_rounded,
              title: 'گاوصندوق و رمزنگاری اطلاعات',
              color: _purple,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const RichLine(
                    'محتوایی که در گاوصندوق قرار می‌دهی، مانند سند، چک، '
                    'شماره کارت، یادداشت و عکس، **پیش از ارسال به سرور روی '
                    'دستگاه رمزنگاری می‌شود**. سرور نسخه‌ی رمزنگاری‌شده '
                    'را برای همگام‌سازی نگهداری می‌کند.',
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _purple.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const RichLine(
                      '**به زبان ساده:** مانند نامه‌ای است که پیش از سپردن '
                      'به پست، داخل پاکت قفل‌دار می‌گذاری. طراحی گاوصندوق '
                      'برای این است که نگهدارنده‌ی سرور به محتوای قابل‌خواندن '
                      'دسترسی نداشته باشد.',
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const BulletRow(
                    text:
                        'کلید رمزگشایی گاوصندوق برای استفاده‌ی عادی '
                        '**به سرور ارسال نمی‌شود**.',
                    color: _purple,
                  ),
                  const BulletRow(
                    text:
                        'محتوای متنی، اعداد، توضیحات، دسته‌بندی و اطلاعات '
                        'حساس فایل‌ها باید پیش از ارسال رمزنگاری شوند.',
                    color: _purple,
                  ),
                  const BulletRow(
                    text:
                        'قفل خودکار و محدودسازی تلاش‌های ناموفق برای '
                        'کاهش خطر دسترسی غیرمجاز به کار می‌روند.',
                    color: _purple,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'بازیابی گاوصندوق',
                    style: sans(size: 12.5, weight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const BulletRow(
                    text:
                        'هنگام ایجاد گاوصندوق، **کلید بازیابی** نمایش داده '
                        'می‌شود. آن را جدا از دستگاه و در جای امن نگهداری کن.',
                    color: _purple,
                  ),
                  const BulletRow(
                    text:
                        'اگر رمز را فراموش کنی، با کلید بازیابی معتبر و '
                        'طبق فرایند برنامه می‌توانی دسترسی را بازیابی کنی. '
                        'با صدور کلید جدید، کلید قبلی باطل می‌شود.',
                    color: _purple,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: const RichLine(
                      '**هشدار مهم:** اگر هم رمز گاوصندوق و هم کلید بازیابی '
                      'معتبر را از دست بدهی، به دلیل طراحی رمزنگاری ممکن است '
                      'بازیابی محتوا ممکن نباشد. در این وضعیت، بازنشانی '
                      'گاوصندوق می‌تواند به حذف غیرقابل‌بازگشت محتوای قبلی '
                      'منجر شود. هیچ سامانه‌ای مصونیت مطلق در برابر رخدادهای '
                      'امنیتی ندارد.',
                      color: Color(0xFF9A3412),
                      boldColor: Color(0xFF7C2D12),
                    ),
                  ),
                ],
              ),
            ),
            const SectionCard(
              icon: Icons.storage_rounded,
              title: 'چه اطلاعاتی نگهداری می‌کنیم؟',
              child: Column(
                children: [
                  BulletRow(
                    text:
                        '**حساب کاربری:** نام، شماره موبایل و '
                        'اطلاعات لازم برای احراز هویت؛ رمز ورود به‌صورت '
                        'مقدار مشتق‌شده‌ی امن نگهداری می‌شود، نه متن آشکار آن.',
                  ),
                  BulletRow(
                    text:
                        '**طرف‌حساب‌ها:** نام و در صورت ثبت توسط '
                        'خودت، شماره تماس؛ برای ارتباط با سوابق مالی.',
                  ),
                  BulletRow(
                    text:
                        '**طلب و بدهی:** مبلغ، تاریخ، سررسید، '
                        'توضیحات، وضعیت و تصاویر یا پیوست‌هایی که اضافه می‌کنی.',
                  ),
                  BulletRow(
                    text:
                        '**بودجه و مخارج:** حقوق، قبض‌ها، بیمه، '
                        'هزینه‌ها، دسته‌بندی‌ها و تاریخچه دوره‌ها.',
                  ),
                  BulletRow(
                    text:
                        '**گاوصندوق:** محتوای رمزنگاری‌شده و '
                        'اطلاعات فنی لازم برای نگهداری و همگام‌سازی آن.',
                    color: _purple,
                  ),
                  BulletRow(
                    text:
                        '**داده‌های فنی ضروری:** اطلاعات لازم '
                        'برای امنیت، عیب‌یابی و عملکرد سرویس، در حدی که '
                        'واقعاً توسط برنامه جمع‌آوری می‌شود.',
                  ),
                ],
              ),
            ),
            const SectionCard(
              icon: Icons.visibility_rounded,
              title: 'تفاوت گاوصندوق با سایر بخش‌ها',
              color: _amber,
              child: Column(
                children: [
                  BulletRow(
                    text:
                        '**گاوصندوق:** محتوا پیش از انتقال '
                        'رمزنگاری می‌شود و برای ارائه‌دهنده در حالت عادی '
                        'قابل‌خواندن طراحی نشده است.',
                    color: _purple,
                  ),
                  BulletRow(
                    text:
                        '**طلب، بدهی، طرف حساب و بودجه:** برای '
                        'ارائه گزارش، جستجو و همگام‌سازی، داده‌های این بخش‌ها '
                        'ممکن است در سمت سرور به‌شکل قابل‌پردازش نگهداری شوند. '
                        'بنابراین دسترسی فنی مجاز و محدود به آن‌ها ممکن است.',
                    color: _amber,
                    icon: Icons.info_outline_rounded,
                  ),
                  BulletRow(
                    text:
                        'اطلاعات بسیار حساس مانند رمزها و '
                        'تصاویر اسناد محرمانه را در **گاوصندوق** قرار بده، '
                        'نه در توضیحات عادی تراکنش‌ها.',
                    color: _amber,
                    icon: Icons.lightbulb_outline_rounded,
                  ),
                ],
              ),
            ),
            const SectionCard(
              icon: Icons.contacts_rounded,
              title: 'طرف حساب گوشی و طرف‌حساب‌های مالی',
              color: _sky,
              child: Column(
                children: [
                  RichLine(
                    'می‌توانی طرف‌حساب را دستی ثبت کنی. در نسخه‌ی '
                    'موبایل، انتخاب طرف حساب از دفترچه تلفن **اختیاری** است '
                    'و تنها پس از اقدام و اعطای مجوز لازم انجام می‌شود.',
                  ),
                  SizedBox(height: 8),
                  BulletRow(
                    text:
                        'هدف این دسترسی، ساده‌تر کردن ورود نام و '
                        'شماره است؛ **کل دفترچه تلفن نباید به حساب یا سرور '
                        'منتقل شود**. فقط طرف حسابی که خودت انتخاب و تأیید '
                        'می‌کنی به فهرست طرف‌حساب‌ها افزوده می‌شوند.',
                  ),
                  BulletRow(
                    text:
                        'اگر مجوز ندهی، امکان ثبت دستی باقی '
                        'می‌ماند. مجوز را می‌توانی از تنظیمات دستگاه لغو کنی.',
                  ),
                  BulletRow(
                    text:
                        'اطلاعات طرف‌حساب‌های انتخاب‌شده برای '
                        'اتصال به بدهی‌ها و طلب‌ها در حساب و سرور ذخیره می‌شود؛ '
                        'ثبت شماره تماس، در صورت پشتیبانی فرم، اختیاری است.',
                  ),
                ],
              ),
            ),
            const SectionCard(
              icon: Icons.people_outline_rounded,
              title: 'حقوق اشخاص ثالث',
              color: _sky,
              child: Column(
                children: [
                  RichLine(
                    'نام و شماره طرف‌حساب ممکن است متعلق به شخصی '
                    'باشد که خودش کاربر «پول من» نیست. این اطلاعات فقط '
                    'برای مدیریت روابط مالی ثبت‌شده توسط کاربر پردازش '
                    'می‌شوند و برای تبلیغات، تماس با آن شخص یا ساخت حساب '
                    'مستقل استفاده نمی‌شوند.',
                  ),
                  SizedBox(height: 8),
                  BulletRow(
                    text:
                        'لطفاً فقط اطلاعات ضروری و درست اشخاص '
                        'دیگر را ثبت کن و حقوق قانونی آن‌ها را رعایت کن.',
                  ),
                  BulletRow(
                    text:
                        'شخص مربوط می‌تواند از راه پشتیبانی، '
                        'درخواست بررسی، اصلاح یا حذف اطلاعات خود را مطرح کند. '
                        'رسیدگی پس از بررسی هویت، وضعیت رکورد و حقوق اشخاص '
                        'مرتبط انجام می‌شود.',
                  ),
                ],
              ),
            ),
            const SectionCard(
              icon: Icons.phone_android_rounded,
              title: 'اطلاعات روی دستگاه و سرور',
              color: _amber,
              child: Column(
                children: [
                  BulletRow(
                    text:
                        'نسخه‌ی محلی داده‌های موردنیاز، مانند '
                        'طرف حساب، طلب و بدهی، بودجه و داده‌های رمزنگاری‌شده '
                        'گاوصندوق، برای سرعت و قابلیت‌های آفلاین نگهداری و '
                        'با سرور همگام‌سازی می‌شود.',
                    color: _amber,
                  ),
                  BulletRow(
                    text:
                        'اطلاعات نشست ورود برای حفظ وضعیت '
                        'ورود در دستگاه نگهداری می‌شود.',
                    color: _amber,
                  ),
                  BulletRow(
                    text:
                        'داده‌های محلی مانند جستجوهای اخیر یا '
                        'وضعیت اعلان‌ها، در صورتی که صرفاً محلی باشند، '
                        'برای این کار به سرور ارسال نمی‌شوند.',
                    color: _amber,
                  ),
                  BulletRow(
                    text:
                        'خروج از حساب باید باعث پاک‌سازی '
                        'اطلاعات محلی مرتبط و نشست ورود در همان دستگاه شود. '
                        'خروج از حساب به معنی حذف اطلاعات سرور نیست.',
                    color: _amber,
                  ),
                ],
              ),
            ),
            const SectionCard(
              icon: Icons.rule_folder_outlined,
              title: 'هدف استفاده و اشتراک‌گذاری',
              color: _blueGrey,
              child: Column(
                children: [
                  BulletRow(
                    text:
                        'اطلاعات برای ساخت و حفاظت حساب، ثبت '
                        'سوابق مالی، گزارش‌ها، جستجو، همگام‌سازی، یادآوری '
                        'سررسید و پشتیبانی فنی استفاده می‌شوند.',
                  ),
                  BulletRow(
                    text:
                        'اطلاعات کاربران فروخته یا برای '
                        'تبلیغات در اختیار اشخاص دیگر قرار داده نمی‌شود.',
                  ),
                  BulletRow(
                    text:
                        'دسترسی عوامل مجاز نگهداری سامانه '
                        'به اطلاعات عادی باید متناسب با ضرورت فنی و محدود '
                        'باشد. ارائه اطلاعات به مراجع صالح تنها در حدود '
                        'الزامات قانونی انجام می‌شود.',
                  ),
                  BulletRow(
                    text:
                        'در صورت استفاده از ارائه‌دهنده '
                        'زیرساخت یا سرویس بیرونی، نوع داده و هدف پردازش '
                        'باید در این سیاست شفاف اعلام شود.',
                  ),
                ],
              ),
            ),
            const SectionCard(
              icon: Icons.lock_outline_rounded,
              title: 'امنیت و رخدادهای احتمالی',
              color: _purple,
              child: Column(
                children: [
                  BulletRow(
                    text:
                        'از ارتباط رمزنگاری‌شده، کنترل دسترسی '
                        'و تدابیر فنی متناسب برای کاهش خطر دسترسی غیرمجاز '
                        'استفاده می‌شود.',
                    color: _purple,
                  ),
                  BulletRow(
                    text:
                        'محدودسازی درخواست‌ها و تلاش‌های '
                        'ناموفق ورود یا بازیابی، بخشی از اقدامات محافظتی '
                        'سامانه است.',
                    color: _purple,
                  ),
                  BulletRow(
                    text:
                        '**هیچ سامانه‌ای امنیت مطلق ندارد.** '
                        'در صورت شناسایی رخداد امنیتی مؤثر بر اطلاعات، '
                        'موضوع بررسی و مهار می‌شود و در موارد لازم یا '
                        'مقرر قانونی، کاربران متأثر و مراجع ذی‌صلاح '
                        'مطلع خواهند شد.',
                    color: _purple,
                  ),
                ],
              ),
            ),
            const SectionCard(
              icon: Icons.vpn_key_outlined,
              title: 'بازیابی رمز حساب',
              color: _green,
              child: Column(
                children: [
                  RichLine(
                    'کد بازیابی ورود به حساب با **کلید بازیابی '
                    'گاوصندوق متفاوت است**. کد حساب هنگام ثبت‌نام '
                    'نمایش داده می‌شود و باید در جای امن نگهداری شود.',
                  ),
                  SizedBox(height: 8),
                  BulletRow(
                    text:
                        'نسخه‌ی قابل‌خواندن کد بازیابی حساب '
                        'نباید در پایگاه داده ذخیره شود؛ فقط مقدار امن '
                        'لازم برای اعتبارسنجی آن نگهداری می‌شود.',
                    color: _green,
                  ),
                  BulletRow(
                    text:
                        'در صورت صدور کد جدید مطابق فرایند '
                        'برنامه، کد قبلی باطل می‌شود.',
                    color: _green,
                  ),
                ],
              ),
            ),
            const SectionCard(
              icon: Icons.cloud_outlined,
              title: 'محل و مدت نگهداری',
              color: _blueGrey,
              child: Column(
                children: [
                  RichLine(
                    'سرور اصلی برنامه در ایران قرار دارد. '
                    'اطلاعات تا زمانی که حساب فعال است و برای ارائه '
                    'خدمات لازم است، مطابق این سیاست نگهداری می‌شوند.',
                  ),
                  SizedBox(height: 8),
                  BulletRow(
                    text:
                        'نسخه‌های پشتیبان برای بازیابی فنی '
                        'تهیه می‌شوند و طبق چرخه اعلام‌شده، حداکثر '
                        '**۷ روز** نگهداری و سپس حذف یا بازنویسی می‌شوند.',
                  ),
                  BulletRow(
                    text:
                        'هرگونه انتقال داده به خارج از کشور '
                        'یا استفاده از زیرساخت بیرونی، در صورت وقوع، '
                        'باید پیش از اعمال تغییرات مرتبط به‌صورت شفاف '
                        'در سیاست اعلام و الزامات قانونی رعایت شود.',
                  ),
                ],
              ),
            ),
            const SectionCard(
              icon: Icons.gavel_rounded,
              title: 'حقوق تو و حذف اطلاعات',
              color: _green,
              child: Column(
                children: [
                  BulletRow(
                    text:
                        'می‌توانی به اطلاعات ثبت‌شده‌ی خود '
                        'دسترسی داشته باشی، آن‌ها را اصلاح کنی و از '
                        'گزارش‌ها و خروجی‌های موجود در برنامه استفاده کنی.',
                    color: _green,
                  ),
                  BulletRow(
                    text:
                        'می‌توانی رکوردهای قابل‌حذف و حساب '
                        'کاربری خود را از مسیر تعیین‌شده در برنامه حذف کنی.',
                    color: _green,
                  ),
                  BulletRow(
                    text:
                        'پس از حذف حساب، داده‌های مربوط از '
                        'پایگاه داده‌ی فعال طبق فرایند حذف پاک می‌شوند؛ '
                        'نسخه‌های موجود در بکاپ حداکثر تا پایان چرخه '
                        '۷ روزه باقی می‌مانند، مگر نگهداری خاصی که قانون '
                        'الزام کرده باشد.',
                    color: _green,
                  ),
                  BulletRow(
                    text:
                        'حذف طرف‌حساب، اگر سوابق مالی مرتبط '
                        'را هم حذف کند، باید پیش از تأیید نهایی با '
                        'هشدار روشن به تو اعلام شود.',
                    color: _green,
                  ),
                  BulletRow(
                    text:
                        'می‌توانی درخواست‌های حریم خصوصی '
                        'یا شکایت خود را از طریق پشتیبانی مطرح کنی؛ '
                        'حق مراجعه به مراجع قانونی صالح محفوظ است.',
                    color: _green,
                  ),
                ],
              ),
            ),
            const SectionCard(
              icon: Icons.receipt_long_outlined,
              title: 'ماهیت حقوقی سوابق مالی و یادآورها',
              color: _amber,
              child: Column(
                children: [
                  RichLine(
                    'ثبت بدهی، طلب، چک یا سند در برنامه، صرفاً '
                    'ثبت اطلاعات توسط کاربر است و به معنی تأیید '
                    'وجود دین یا صحت ادعا توسط «پول من» نیست. '
                    'ارزش اثباتی داده‌پیام در هر اختلاف، مطابق قانون '
                    'و با تشخیص مرجع صالح بررسی می‌شود.',
                  ),
                  SizedBox(height: 8),
                  BulletRow(
                    text:
                        'گزارش‌ها و یادآوری‌های سررسید '
                        'ابزار کمکی‌اند و ممکن است به علت تنظیمات دستگاه، '
                        'قطع اینترنت یا اختلال فنی با تأخیر مواجه شوند.',
                    color: _amber,
                  ),
                  BulletRow(
                    text:
                        'این توضیح، مسئولیت قانونی احتمالی '
                        'ارائه‌دهنده در قبال تقصیر یا نقض تعهدات خودش '
                        'را منتفی نمی‌کند.',
                    color: _amber,
                  ),
                ],
              ),
            ),
            const SectionCard(
              icon: Icons.notifications_none_rounded,
              title: 'اعلان‌ها و پیام‌ها',
              color: _sky,
              child: RichLine(
                'اعلان‌های خدماتی برای مواردی مانند '
                'سررسید و اطلاع‌رسانی ضروری حساب استفاده می‌شوند. '
                'در صورت اضافه شدن پیام‌های غیرضروری یا تبلیغاتی، '
                'هدف آن‌ها اعلام و امکان مدیریت یا لغو دریافت '
                'در موارد لازم فراهم می‌شود.',
              ),
            ),
            SectionCard(
              icon: Icons.update_rounded,
              title: 'به‌روزرسانی این سیاست',
              color: _blueGrey,
              child: RichLine(
                'تاریخ آخرین به‌روزرسانی: **${AppInfo.privacyUpdatedAt}**. '
                'تغییرات از طریق برنامه اطلاع‌رسانی می‌شوند. در صورت '
                'تغییر اساسی در هدف یا نحوه‌ی پردازش داده‌ها، '
                'اطلاع‌رسانی مشخص و در موارد لازم موافقت مجدد دریافت '
                'می‌شود. نسخه‌های قبلی برای امکان بررسی نگهداری می‌شوند.',
                color: _grey700,
              ),
            ),
            SectionCard(
              icon: Icons.mail_outline_rounded,
              title: 'تماس، درخواست و شکایت',
              child: RichLine(
                'برای پرسش درباره‌ی حریم خصوصی، درخواست بررسی اطلاعات '
                'یا گزارش مشکل امنیتی، از راه پشتیبانی برنامه یا ایمیل '
                '**${AppInfo.supportEmail}** با ارائه‌دهنده تماس بگیر. '
                'مشخصات قانونی ارائه‌دهنده خدمات نیز باید در بخش '
                '«درباره برنامه» در دسترس باشد.',
                color: _grey700,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
