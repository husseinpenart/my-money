import 'package:flutter/material.dart';
import 'package:money/core/drawer/app_info.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/drawer/section_card.dart';

const _sky = Color(0xFF0EA5E9);
const _purple = Color(0xFF7C3AED);
const _green = Color(0xFF10B981);
const _amber = Color(0xFFD97706);
const _blueGrey = Color(0xFF607D8B);
const _grey700 = Color(0xFF616161);

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        'داده‌های تو، فقط مال خودت',
                        style: sans(
                          size: 13.5,
                          weight: FontWeight.bold,
                          color: const Color(0xFF065F46),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'این سیاست ساده نوشته شده تا بدانی دقیقاً چه اطلاعاتی '
                        'ذخیره می‌شود و چرا. اطلاعات شخصی تو فروخته یا برای '
                        'تبلیغات به کسی داده نمی‌شود.',
                        style: sans(
                          size: 12,
                          color: const Color(0xFF047857),
                        ).copyWith(height: 1.7),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SectionCard(
            icon: Icons.storage_rounded,
            title: 'چه اطلاعاتی ذخیره می‌کنیم؟',
            child: const Column(
              children: [
                BulletRow(
                  text:
                      'طلب و بدهی‌هایی که خودت ثبت می‌کنی (مبلغ، تاریخ، توضیح و تصاویر).',
                ),
                BulletRow(
                  text: 'مخاطبانی که خودت ثبت یا انتخاب می‌کنی (نام و شماره).',
                ),
                BulletRow(
                  text:
                      'اطلاعات بودجه: حقوق، قبض‌ها و بیمه‌های برنامه‌ریزی‌شده، هزینه‌ها و تاریخچه‌ی دوره‌ها.',
                ),
                BulletRow(
                  text:
                      'اطلاعات ورود: نام، شماره‌ی موبایل و رمز عبور (فقط به‌صورت رمزنگاری‌شده؛ متن اصلی رمز هرگز ذخیره نمی‌شود).',
                ),
                BulletRow(
                  text:
                      'کد بازیابی رمز: فقط نسخه‌ی رمزنگاری‌شده‌ی آن نگهداری می‌شود، پس ما هم نمی‌توانیم آن را ببینیم یا دوباره بفرستیم.',
                ),
              ],
            ),
          ),

          SectionCard(
            icon: Icons.contacts_rounded,
            title: 'دسترسی به مخاطبین گوشی',
            color: _sky,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'چرا این دسترسی را می‌خواهیم؟',
                  style: sans(size: 12.5, weight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'تا هنگام ثبت مخاطب جدید مجبور نباشی نام و شماره را دستی '
                  'تایپ کنی. این قابلیت اختیاری است و در نسخه‌ی وب وجود ندارد.',
                  style: sans(
                    size: 12.5,
                    color: _grey700,
                  ).copyWith(height: 1.8),
                ),
                const SizedBox(height: 12),
                Text(
                  'این‌طور کار می‌کند:',
                  style: sans(size: 12.5, weight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Column(
                  children: [
                    BulletRow(
                      text:
                          'فقط وقتی خودت «از مخاطبین گوشی» را انتخاب می‌کنی، لیست خوانده می‌شود.',
                    ),
                    BulletRow(
                      text:
                          'کل مخاطبین تو ذخیره یا ارسال نمی‌شود؛ فقط نام و شماره‌ی مواردی که خودت تیک می‌زنی به حسابت اضافه می‌شود.',
                    ),
                    BulletRow(
                      text:
                          'اگر دسترسی را ندهی، همه‌چیز کار می‌کند و می‌توانی مخاطب را دستی ثبت کنی.',
                    ),
                  ],
                ),
              ],
            ),
          ),

          SectionCard(
            icon: Icons.phone_android_rounded,
            title: 'اطلاعاتی که روی دستگاه خودت می‌ماند',
            color: _amber,
            child: const Column(
              children: [
                BulletRow(
                  text:
                      'نشست ورود (توکن)، برای اینکه هر بار مجبور به ورود نشوی.',
                  color: _amber,
                ),
                BulletRow(
                  text:
                      'جستجوهای اخیر و وضعیت «خوانده‌شده» اعلان‌ها. این‌ها به سرور ارسال نمی‌شوند.',
                  color: _amber,
                ),
                BulletRow(
                  text:
                      'با «خروج از حساب» همه‌ی این موارد از دستگاه پاک می‌شود.',
                  color: _amber,
                ),
              ],
            ),
          ),

          SectionCard(
            icon: Icons.lock_outline_rounded,
            title: 'امنیت و نگهداری',
            color: _purple,
            child: const Column(
              children: [
                BulletRow(
                  text: 'ورود با توکن رمزنگاری‌شده (JWT) و ارتباط امن با سرور.',
                  icon: Icons.shield_outlined,
                  color: _purple,
                ),
                BulletRow(
                  text:
                      'هر حساب از دیگران جدا است؛ کاربران دیگر هیچ راهی برای دیدن داده‌ی تو ندارند.',
                  icon: Icons.shield_outlined,
                  color: _purple,
                ),
                BulletRow(
                  text:
                      'تلاش‌های پشت‌سرهم و اشتباه برای بازیابی رمز، موقتاً قفل می‌شود.',
                  icon: Icons.shield_outlined,
                  color: _purple,
                ),
                BulletRow(
                  text:
                      'دسترسی فنی به سرور فقط برای نگهداری سیستم و به‌صورت محدود است و داده‌ی تو برای هیچ هدف دیگری استفاده نمی‌شود.',
                  icon: Icons.shield_outlined,
                  color: _purple,
                ),
              ],
            ),
          ),

          SectionCard(
            icon: Icons.gavel_rounded,
            title: 'حقوق تو',
            color: _green,
            child: const Column(
              children: [
                BulletRow(
                  text:
                      'هر زمان بخواهی می‌توانی مخاطب، طلب، بدهی یا هزینه را ویرایش یا حذف کنی.',
                  color: _green,
                ),
                BulletRow(
                  text:
                      'حذف کامل حساب: از «منو ← حذف حساب» با وارد کردن رمز عبور. مخاطبین، رکوردها، تصاویر، بودجه و اطلاعات ورود تو بلافاصله از سرور پاک می‌شود و قابل بازگشت نیست.',
                  color: _green,
                ),
                BulletRow(
                  text:
                      'دسترسی به مخاطبین را هر وقت خواستی از تنظیمات دستگاه می‌توانی پس بگیری.',
                  color: _green,
                ),
              ],
            ),
          ),

          SectionCard(
            icon: Icons.update_rounded,
            title: 'به‌روزرسانی این سیاست',
            color: _blueGrey,
            child: Text(
              'این صفحه آخرین بار در ${AppInfo.privacyUpdatedAt} به‌روز شده است. '
              'در صورت تغییر مهم، همین‌جا و در تاریخچه‌ی نسخه‌ها اعلام می‌شود.',
              style: sans(size: 12.5, color: _grey700).copyWith(height: 1.8),
            ),
          ),

          SectionCard(
            icon: Icons.mail_outline_rounded,
            title: 'سوال داری؟',
            child: Text(
              'برای هر پرسش درباره‌ی حریم خصوصی: ${AppInfo.supportEmail}',
              style: sans(size: 12.5, color: _grey700).copyWith(height: 1.7),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
