import 'package:flutter/material.dart';
import 'package:money/core/drawer/app_info.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/drawer/copyable_field.dart';
import 'package:money/widgets/drawer/section_card.dart';

const _amber = Color(0xFFD97706);
const _red300 = Color(0xFFE57373);
const _grey700 = Color(0xFF616161);
const _grey600 = Color(0xFF757575);
const _grey500 = Color(0xFF9E9E9E);

class CoffeePage extends StatelessWidget {
  const CoffeePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'من را به یک قهوه مهمان کن',
          style: sans(size: 15, weight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.local_cafe_rounded,
                  color: Colors.white,
                  size: 46,
                ),
                const SizedBox(height: 12),
                Text(
                  'یه قهوه مهمانم کن ☕',
                  style: sans(
                    size: 17,
                    weight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'اگر این اپ کار را راه انداخت و راحتت کرد، کوچک‌ترین '
                  'حمایت تو انرژی بزرگی برای ادامه‌ی راه است. کاملاً اختیاری.',
                  textAlign: TextAlign.center,
                  style: sans(
                    size: 12.5,
                    color: Colors.white,
                  ).copyWith(height: 1.7),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SectionCard(
            icon: Icons.credit_card_rounded,
            title: 'شماره کارت‌ها',
            color: _amber,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'روی هر کارت بزن تا شماره کپی شود:',
                  style: sans(size: 12, color: _grey600),
                ),
                const SizedBox(height: 12),
                for (final c in AppInfo.cards) ...[
                  CopyableField(
                    label: 'کارت ${c.bank}',
                    value: c.number,
                    icon: Icons.account_balance_rounded,
                    color: _amber,
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.badge_outlined, size: 15, color: _grey500),
                    const SizedBox(width: 6),
                    Text(
                      'به نام: ${AppInfo.developer.name}',
                      style: sans(size: 11.5, color: _grey600),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SectionCard(
            icon: Icons.favorite_rounded,
            title: 'ممنونم از تو',
            color: _red300,
            child: Text(
              'هیچ اجباری نیست؛ همین که استفاده می‌کنی و بازخورد می‌دهی، '
              'بزرگ‌ترین حمایت است. اگر قهوه‌ای هم مهمانم کردی، با عشق '
              'روی ویژگی‌های بعدی می‌نویسمش. ❤️',
              style: sans(size: 12.5, color: _grey700).copyWith(height: 1.8),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
