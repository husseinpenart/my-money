import 'package:flutter/material.dart';
import 'package:money/core/drawer/app_info.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/drawer/section_card.dart';

const _sky = Color(0xFF0EA5E9);
const _purple = Color(0xFF7C3AED);
const _green = Color(0xFF10B981);
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
                        'این سیاست با زبانی ساده نوشته شده تا بدانی دقیقاً چه '
                        'اطلاعاتی ذخیره می‌شود و چرا. هیچ فروش یا اشتراک‌گذاری '
                        'اطلاعات شخصی وجود ندارد.',
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
                      'طلب و بدهی‌هایی که خودت ثبت می‌کنی (مبلغ، تاریخ، توضیح، تصاویر).',
                ),
                BulletRow(
                  text: 'مخاطبانی که خودت انتخاب یا ثبت می‌کنی (نام و شماره).',
                ),
                BulletRow(text: 'تصاویری که برای مستندسازی آپلود می‌کنی.'),
                BulletRow(
                  text:
                      'اطلاعات حساب کاربری برای ورود (ایمیل/شماره و رمز عبور رمزنگاری‌شده).',
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
                  'برای اینکه هنگام ثبت طلب یا بدهی، مجبور نباشی نام و شماره‌ی طرف '
                  'حساب را دستی تایپ کنی؛ لیست مخاطبین گوشی را می‌خوانیم تا بتوانی '
                  'فقط با یک لمس، شخص موردنظر را انتخاب کنی.',
                  style: sans(
                    size: 12.5,
                    color: _grey700,
                  ).copyWith(height: 1.8),
                ),
                const SizedBox(height: 14),
                Text(
                  'نگران نباش؛ این‌طور کار می‌کند:',
                  style: sans(size: 12.5, weight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Column(
                  children: [
                    BulletRow(
                      text:
                          'فقط وقتی خودت روی «انتخاب از مخاطبین» می‌زنی، لیست نمایش داده می‌شود.',
                    ),
                    BulletRow(
                      text:
                          'ما کل مخاطبین تو را برای خودمان ذخیره یا ارسال نمی‌کنیم.',
                    ),
                    BulletRow(
                      text:
                          'فقط نام و شماره‌ی همان کسی که خودت انتخاب می‌کنی، داخل رکورد تو ثبت می‌شود.',
                    ),
                    BulletRow(
                      text:
                          'اگر دسترسی را ندهی، هیچ‌چیز خراب نمی‌شود؛ می‌توانی دستی تایپ کنی.',
                    ),
                    BulletRow(
                      text:
                          'اطلاعات مخاطبین هرگز فروخته یا با شخص ثالثی به‌اشتراک گذاشته نمی‌شود.',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: Color(0xFF0284C7),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'خلاصه: این دسترسی برای راحتی توست، نه برای جمع‌آوری داده. '
                          'کنترل کامل با خودته.',
                          style: sans(
                            size: 12,
                            color: const Color(0xFF075985),
                          ).copyWith(height: 1.6),
                        ),
                      ),
                    ],
                  ),
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
                  text:
                      'ورود با توکن رمزنگاری‌شده (JWT) و انتقال داده روی HTTPS.',
                  icon: Icons.shield_outlined,
                  color: _purple,
                ),
                BulletRow(
                  text:
                      'هر حساب کاملاً از دیگران جدا است؛ هیچ‌کس به داده‌ی تو دسترسی ندارد.',
                  icon: Icons.shield_outlined,
                  color: _purple,
                ),
                BulletRow(
                  text:
                      'تصاویر و رکوردها فقط برای نمایش در حساب خودت نگهداری می‌شوند.',
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
                      'هر زمان بخواهی می‌توانی رکورد یا مخاطب را ویرایش/حذف کنی.',
                  color: _green,
                ),
                BulletRow(
                  text: 'می‌توانی حساب و تمام داده‌هایت را حذف کنی.',
                  color: _green,
                ),
                BulletRow(
                  text:
                      'اجازه‌ی دسترسی به مخاطبین را هر وقت خواستی از تنظیمات گوشی thu جمع کنی.',
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
              'در صورت تغییرات مهم، از طریق اپ به تو اطلاع می‌دهیم.',
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
