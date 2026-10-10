import 'package:flutter/material.dart';
import 'package:money/core/drawer/app_info.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/drawer/copyable_field.dart';
import 'package:money/widgets/drawer/section_card.dart';

const _brand = Color(0xFF4E81EF);
const _purple = Color(0xFF7C3AED);
const _sky = Color(0xFF0EA5E9);
const _green = Color(0xFF10B981);
const _amber = Color(0xFFD97706);
const _grey700 = Color(0xFF616161);
const _grey600 = Color(0xFF757575);

/// چهار «وعده» به کاربر — هیچ‌کدام تکنولوژی ندارد؛ هرکدام یک نگرانی واقعی را جواب می‌دهد.
const List<({IconData icon, Color color, String title, String body})> _trust = [
  (
    icon: Icons.calculate_rounded,
    color: _green,
    title: 'اعداد، خطا نمی‌پذیرند',
    body:
        'محاسبات طلب، بدهی و بودجه با دقت ساخته و آزمایش شده؛ چون یک ریال '
        'اشتباه در یک ابزار مالی، یعنی بی‌اعتمادی.',
  ),
  (
    icon: Icons.shield_rounded,
    color: _sky,
    title: 'داده‌ات فقط مال خودت',
    body:
        'هر حساب کاملاً جداست. اطلاعاتت نه فروخته می‌شود نه با کسی به‌اشتراک '
        'گذاشته می‌شود؛ دسترسی مخاطبین هم فقط با اجازه‌ی خودت.',
  ),
  (
    icon: Icons.workspace_premium_rounded,
    color: _purple,
    title: 'ساخته‌شده با تجربه',
    body:
        'سازنده بیش از ۹ سال در این حوزه فعال است و پروژه‌هایی با ده‌ها هزار '
        'کاربر تحویل داده؛ کیفیت و نگهداری برایش اولویت است، نه فقط تحویل.',
  ),
  (
    icon: Icons.support_agent_rounded,
    color: _amber,
    title: 'تنها نیستی',
    body:
        'پشتیبانی واقعی از طریق ایمیل در دسترس است و بازخورد تو مستقیماً روی '
        'نسخه‌های بعدی اثر می‌گذارد.',
  ),
];

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
          // ───── کارت پروفایل ─────
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

          // ───── وعده‌های اعتماد (به‌جای فهرست تکنولوژی) ─────
          SectionCard(
            icon: Icons.handshake_rounded,
            title: 'چرا می‌توانی اعتماد کنی',
            color: _brand,
            child: Column(
              children: [
                for (var i = 0; i < _trust.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  _TrustRow(t: _trust[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ───── راه‌های ارتباط ─────
          SectionCard(
            icon: Icons.link_rounded,
            title: 'راه‌های ارتباط',
            child: Column(
              children: [
                CopyableField(
                  label: 'گیت‌هاب',
                  value: d.github,
                  display: 'husseinpenart',
                  icon: Icons.code_rounded,
                  color: const Color(0xFF24292F),
                  mono: false,
                ),
                const SizedBox(height: 10),
                CopyableField(
                  label: 'لینکدین',
                  value: d.linkedin,
                  display: 'hussain-asadi',
                  icon: Icons.work_outline_rounded,
                  color: const Color(0xFF0A66C2),
                  mono: false,
                ),
                const SizedBox(height: 10),
                CopyableField(
                  label: 'تلگرام',
                  value: d.telegram,
                  icon: Icons.send_rounded,
                  color: _sky,
                  mono: false,
                ),
                const SizedBox(height: 10),
                CopyableField(
                  label: 'ایمیل',
                  value: d.email,
                  icon: Icons.mail_outline_rounded,
                  color: _purple,
                  mono: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow({required this.t});
  final ({IconData icon, Color color, String title, String body}) t;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: t.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(t.icon, size: 19, color: t.color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.title,
                style: sans(size: 13, weight: FontWeight.bold, color: t.color),
              ),
              const SizedBox(height: 3),
              Text(
                t.body,
                style: sans(size: 12, color: _grey700).copyWith(height: 1.7),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
