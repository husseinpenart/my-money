import 'package:flutter/material.dart';
import 'package:money/core/drawer/app_info.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/drawer/copyable_field.dart';
import 'package:money/widgets/drawer/section_card.dart';

const _brand = Color(0xFF4E81EF);
const _red300 = Color(0xFFE57373);
const _grey700 = Color(0xFF616161);
const _grey600 = Color(0xFF757575);

class AboutMePage extends StatelessWidget {
  const AboutMePage({super.key});

  @override
  Widget build(BuildContext context) {
    final d = AppInfo.developer;
    final initial = d.name.isEmpty
        ? '؟'
        : d.name.characters.first.toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'درباره من',
          style: sans(size: 16, weight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEEF0F4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFF4F28DF), Color(0xFF947BEE)],
                    ),
                  ),
                  child: Text(
                    initial,
                    style: sans(
                      size: 30,
                      weight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(d.name, style: sans(size: 17, weight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(d.role, style: sans(size: 12, color: _brand)),
                const SizedBox(height: 12),
                Text(
                  d.bio,
                  textAlign: TextAlign.center,
                  style: sans(
                    size: 12.5,
                    color: _grey600,
                  ).copyWith(height: 1.8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SectionCard(
            icon: Icons.link_rounded,
            title: 'راه‌های ارتباط',
            child: Column(
              children: [
                CopyableField(
                  label: 'گیت‌هاب',
                  value: d.github,
                  icon: Icons.code_rounded,
                  mono: false,
                ),
                const SizedBox(height: 10),
                CopyableField(
                  label: 'تلگرام',
                  value: d.telegram,
                  icon: Icons.send_rounded,
                  mono: false,
                ),
                const SizedBox(height: 10),
                CopyableField(
                  label: 'ایمیل',
                  value: d.email,
                  icon: Icons.mail_outline_rounded,
                  mono: false,
                ),
              ],
            ),
          ),

          SectionCard(
            icon: Icons.favorite_rounded,
            title: 'یک تشکر',
            color: _red300,
            child: Text(
              'ممنون که از این اپ استفاده می‌کنی. انگیزه‌ی من برای ساختنش، '
              'ساده‌کردن زندگی مالی تو بود. اگر راضی بودی، یک قهوه مهمانم کن ☕',
              style: sans(size: 12.5, color: _grey700).copyWith(height: 1.8),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
