import 'package:flutter/material.dart';
import 'package:money/core/drawer/app_info.dart';
import 'package:money/feature/auth/presentation/pages/drawer/privacy_page.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/drawer/rich_line.dart';
import 'package:money/widgets/drawer/section_card.dart';

const _brand = Color(0xFF4E81EF);
const _purple = Color(0xFF7C3AED);
const _sky = Color(0xFF0EA5E9);
const _green = Color(0xFF10B981);
const _grey700 = Color(0xFF616161);
const _grey500 = Color(0xFF9E9E9E);

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'درباره برنامه',
          style: sans(size: 16, weight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ───── هدر ─────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF4F28DF), Color(0xFF947BEE)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.asset(
                    AppInfo.logoAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  AppInfo.appName,
                  style: sans(
                    size: 18,
                    weight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppInfo.appTagline,
                  style: sans(
                    size: 12.5,
                    color: Colors.white70,
                  ).copyWith(height: 1.6),
                ),
                const SizedBox(height: 10),
                Text(
                  'نسخه ${AppInfo.version}',
                  style: sans(size: 11, color: Colors.white60),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ───── چرا این اپ ─────
          SectionCard(
            icon: Icons.auto_awesome_rounded,
            title: 'چرا این اپ؟',
            child: const RichLine(
              'مدیریت پول نباید پراکنده و استرس‌آور باشد. این اپ سه کار را '
              'در یک جا انجام می‌دهد: **طلب و بدهی‌هایت را دقیق پیگیری می‌کند**، '
              '**بودجه‌ی ماهانه‌ات را می‌چیند** و **گزارش می‌دهد پولت کجا رفته**. '
              'بدون شلوغی و بدون اصطلاحات پیچیده.',
            ),
          ),

          // ───── گاوصندوق (مهم‌ترین نقطه‌ی قوت) ─────
          SectionCard(
            icon: Icons.shield_moon_rounded,
            title: 'گاوصندوق با رمزنگاری سمت دستگاه',
            color: _purple,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RichLine(
                  'گاوصندوق جایی برای چیزهای خیلی مهم است: طلا و سکه، سند، چک، '
                  'شماره کارت یا هر یادداشت محرمانه.',
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _purple.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const RichLine(
                    '**مثال ساده:** گاوصندوق مثل یک جعبه‌ی قفل‌دار است که '
                    '**فقط خودت کلیدش را داری**. ما جعبه را برایت نگه می‌داریم، '
                    'و کلید رمزگشایی طبق طراحی گاوصندوق به سرور ارسال نمی‌شود. '
                    'به همین دلیل محتوای رمزنگاری‌شده برای سرور قابل خواندن نیست.',
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 10),
                const BulletRow(
                  text:
                      '**قفل‌گذاری روی گوشی خودت انجام می‌شود،** قبل از اینکه چیزی '
                      'به اینترنت برود. آنچه روی سرور می‌ماند فقط حروف درهم‌ریخته‌ای '
                      'است که بدون کلید معتبر قابل خواندن نیست.',
                  color: _purple,
                ),
                const BulletRow(
                  text:
                      '**تصاویر و اطلاعات حساس همراه آن‌ها** نیز مطابق سازوکار '
                      'رمزنگاری گاوصندوق، پیش از ارسال محافظت می‌شوند.',
                  color: _purple,
                ),
                const BulletRow(
                  text:
                      '**اگر رمز را فراموش کنی،** کلید بازیابی که هنگام ساخت دریافت '
                      'کرده‌ای، در صورت نگهداری صحیح امکان تعیین رمز تازه و '
                      'بازیابی دسترسی را فراهم می‌کند.',
                  color: _purple,
                ),
                const BulletRow(
                  text:
                      '**کلید بازیابی را روی کاغذ بنویس** و جای امنی نگه دار. '
                      'اگر رمز را نیز فراموش کنی، بدون این کلید امکان بازیابی نیست.',
                  color: _purple,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const RichLine(
                    '**یک نکته‌ی صادقانه:** چون ما کلید را نداریم، اگر هم رمز و هم '
                    'کلید بازیابی را گم کنی، طبق سازوکار فعلی گاوصندوق '
                    '**امکان بازیابی محتوای رمزنگاری‌شده وجود ندارد**؛ حتی '
                    'از طریق پشتیبانی.',
                    color: Color(0xFF9A3412),
                  ),
                ),
              ],
            ),
          ),

          // ───── قابلیت‌ها ─────
          SectionCard(
            icon: Icons.bolt_rounded,
            title: 'قابلیت‌های کلیدی',
            child: Column(
              children: [
                for (final f in AppInfo.features)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(f.icon, size: 18, color: _brand),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichLine(
                            f.title,
                            size: 12.5,
                            height: 1.6,
                            boldColor: _brand,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ───── سرعت ─────
          SectionCard(
            icon: Icons.speed_rounded,
            title: 'چرا اپ سریع است؟',
            color: _green,
            child: Column(
              children: const [
                BulletRow(
                  text:
                      '**اطلاعاتت روی گوشی خودت ذخیره می‌شود،** پس هر بار که صفحه '
                      'را باز می‌کنی، لازم نیست منتظر اینترنت بمانی.',
                  color: _green,
                ),
                BulletRow(
                  text:
                      'وقتی چیزی را **اضافه یا ویرایش می‌کنی، همان لحظه** در لیست '
                      'می‌بینی.',
                  color: _green,
                ),
                BulletRow(
                  text:
                      'اگر از گوشی یا مرورگر دیگری تغییر دادی، با دکمه‌ی '
                      '«بروزرسانی» اطلاعات تازه می‌رسد.',
                  color: _green,
                ),
              ],
            ),
          ),

          // ───── تعهد حریم ─────
          SectionCard(
            icon: Icons.privacy_tip_outlined,
            title: 'تعهد ما به حریم تو',
            color: _sky,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RichLine(
                  '**داده‌هایت مال خودت است.** نه می‌فروشیم، نه برای تبلیغات '
                  'استفاده می‌کنیم. مخاطبین گوشی فقط با اجازه‌ی خودت و فقط '
                  'برای انتخاب طرف حساب خوانده می‌شود. هر حساب از حساب‌های دیگر '
                  'جداست.',
                  height: 1.7,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PrivacyPage()),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text('متن کامل حریم خصوصی', style: sans(size: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _sky,
                    side: const BorderSide(color: _sky),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ───── شفافیت در استفاده و مسئولیت ─────
          SectionCard(
            icon: Icons.info_outline_rounded,
            title: 'چند نکته درباره اطلاعات مالی',
            color: _brand,
            child: const Column(
              children: [
                BulletRow(
                  text:
                      'ثبت طلب، بدهی یا تصویر سند در برنامه، به‌تنهایی '
                      '**تأیید یا اثبات قطعی آن توسط سازنده** نیست. '
                      'اعتبار هر مدرک در اختلافات به تشخیص مرجع صالح بستگی دارد.',
                  color: _brand,
                ),
                BulletRow(
                  text:
                      'گزارش‌ها و یادآوری سررسیدها ابزار کمکی‌اند؛ '
                      'برای تعهدات مهم، سوابق و یادآور مستقل هم نگه دار.',
                  color: _brand,
                ),
                BulletRow(
                  text:
                      'می‌توانی اطلاعاتت را مطابق امکانات برنامه مدیریت '
                      'یا درخواست حذف حساب بدهی. جزئیات حذف و چرخه بکاپ '
                      'در سیاست حریم خصوصی توضیح داده شده است.',
                  color: _brand,
                ),
              ],
            ),
          ),

          // ───── اطلاعات ارائه‌دهنده ─────
          SectionCard(
            icon: Icons.business_outlined,
            title: 'ارائه‌دهنده و راه ارتباط',
            color: _sky,
            child: RichLine(
              'برای گزارش اشکال، درخواست مرتبط با داده‌ها یا پیگیری شکایت، '
              'از راه ارتباط رسمی **${AppInfo.supportEmail}** استفاده کن. '
              'اطلاعات کامل درباره پردازش داده‌ها و حقوق کاربران در صفحه '
              'حریم خصوصی در دسترس است.',
              color: _grey700,
              height: 1.7,
            ),
          ),

          SectionCard(
            icon: Icons.mail_outline_rounded,
            title: 'پشتیبانی',
            color: _green,
            child: RichLine(
              'برای گزارش مشکل، پیشنهاد، درخواست حریم خصوصی یا شکایت: **${AppInfo.supportEmail}**',
              color: _grey700,
            ),
          ),

          const SizedBox(height: 8),
          Center(
            child: Text(
              'ساخته‌شده با دقت برای مدیریت آسان‌تر امور مالی',
              style: sans(size: 11, color: _grey500),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
