import 'package:flutter/material.dart';
import 'package:money/core/drawer/app_info.dart';
import 'package:money/feature/auth/presentation/pages/drawer/privacy_page.dart'; // 👈 اضافه شد
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
              'مدیریت طلب و بدهی نباید استرس‌آور باشد. این اپ با زبانی ساده و '
              'بدون شلوغی، به تو کمک می‌کند یادت بماند به whom بدهکار هستی، '
              'چه کسی به تو بدهکار است، و چقدر از هر کدام تسویه شده. '
              'همه‌چیز در یک جا، سریع و قابل‌اعتماد.',
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
                      children: [
                        Icon(f.icon, size: 18, color: _brand), // 👈 بدون cast
                        const SizedBox(width: 10),
                        Expanded(child: Text(f.title, style: sans(size: 12.5))),
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
                  'داده‌های تو فقط مال خودت است. ما مخاطبین را بدون اجازه‌ی تو '
                  'ذخیره یا ارسال نمی‌کنیم و هرگز اطلاعاتت را نمی‌فروشیم.',
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
              'سوال، پیشنهاد یا گزارش باگ داری؟ ما را بنویس:\n${AppInfo.supportEmail}',
              style: sans(size: 12.5, color: _grey700).copyWith(height: 1.8),
            ),
          ),

          const SizedBox(height: 8),
          Center(
            child: Text(
              'ساخته‌شده با ❤️ برای مدیریت آسان‌تر پول',
              style: sans(size: 11, color: _grey500),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
