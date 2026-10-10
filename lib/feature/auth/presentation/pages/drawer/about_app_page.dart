import 'package:flutter/material.dart';
import 'package:money/core/drawer/app_info.dart';
import 'package:money/feature/auth/presentation/pages/drawer/privacy_page.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/drawer/section_card.dart';

const _brand = Color(0xFF4E81EF);
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
          // هدر معرفی
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

          SectionCard(
            icon: Icons.auto_awesome_rounded,
            title: 'چرا این اپ؟',
            child: Text(
              'مدیریت امور مالی نباید پراکنده و استرس‌آور باشد. این اپ سه نیاز '
              'اصلی را در یک جا جمع می‌کند: پیگیری دقیق طلب و بدهی، بودجه‌بندی '
              'واقع‌گرایانه‌ی ماهانه، و گزارش‌هایی که نشان می‌دهند پولت کجاست و '
              'چه چیزی معوق مانده. هدف، شفافیت و تصمیم‌گیری آگاهانه است؛ بدون '
              'شلوغی و بدون اصطلاحات پیچیده.',
              style: sans(size: 12.5, color: _grey700).copyWith(height: 1.8),
            ),
          ),

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
                          child: Text(
                            f.title,
                            style: sans(
                              size: 12.5,
                              color: _grey700,
                            ).copyWith(height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          SectionCard(
            icon: Icons.privacy_tip_outlined,
            title: 'تعهد ما به حریم تو',
            color: _sky,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'داده‌های تو صرفاً مال خودت است. اطلاعات مخاطبین فقط با اجازه‌ی '
                  'خودت و فقط برای راحتی انتخاب طرف حساب خوانده می‌شود؛ ذخیره‌ی '
                  'سراسری، ارسال یا فروش آن وجود ندارد. هر رکورد و تصویر نیز تنها '
                  'در حساب خودت قابل مشاهده است.',
                  style: sans(
                    size: 12.5,
                    color: _grey700,
                  ).copyWith(height: 1.7),
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

          SectionCard(
            icon: Icons.mail_outline_rounded,
            title: 'پشتیبانی',
            color: _green,
            child: Text(
              'برای گزارش باگ، پیشنهاد قابلیت یا هر پرسش: ${AppInfo.supportEmail}',
              style: sans(size: 12.5, color: _grey700).copyWith(height: 1.8),
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
