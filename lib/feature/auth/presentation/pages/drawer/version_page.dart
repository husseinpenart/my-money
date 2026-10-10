import 'package:flutter/material.dart';
import 'package:money/core/drawer/app_info.dart';
import 'package:money/feature/auth/presentation/pages/drawer/about_app_page.dart';
import 'package:money/feature/auth/presentation/pages/drawer/privacy_page.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/drawer/section_card.dart';

const _brand = Color(0xFF4E81EF);
const _blueGrey = Color(0xFF607D8B);
const _grey700 = Color(0xFF616161);
const _grey600 = Color(0xFF757575);
const _grey500 = Color(0xFF9E9E9E);
const _grey400 = Color(0xFFBDBDBD);

class VersionPage extends StatelessWidget {
  const VersionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'نسخه اپلیکیشن',
          style: sans(size: 16, weight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _brand.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'v${AppInfo.version}',
                    style: sans(
                      size: 16,
                      weight: FontWeight.bold,
                      color: _brand,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'ساخت: ${AppInfo.buildNumber}   ·   انتشار: ${AppInfo.releaseDate}',
                  style: sans(size: 12, color: _grey600),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        width: 230,
                        content: Text('همیشه به‌روز هستید ✅'),
                      ),
                    ),
                  icon: const Icon(Icons.system_update_alt_rounded, size: 16),
                  label: Text('بررسی بروزرسانی', style: sans(size: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _brand,
                    side: const BorderSide(color: _brand),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SectionCard(
            icon: Icons.history_rounded,
            title: 'تاریخچه‌ی تغییرات',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final cl in AppInfo.changelog) ...[
                  Row(
                    children: [
                      Text(
                        cl.version,
                        style: sans(
                          size: 13,
                          weight: FontWeight.bold,
                          color: _brand,
                        ),
                      ),
                      const Spacer(),
                      Text(cl.date, style: sans(size: 11, color: _grey500)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  for (final n in cl.notes)
                    Padding(
                      padding: const EdgeInsets.only(right: 4, bottom: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(fontSize: 13, color: _grey500),
                          ),
                          Expanded(
                            child: Text(
                              n,
                              style: sans(size: 12.5).copyWith(height: 1.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),

          SectionCard(
            icon: Icons.link_rounded,
            title: 'لینک‌های مفید',
            color: _blueGrey,
            child: Column(
              children: [
                _link(
                  context,
                  'درباره برنامه',
                  Icons.info_outline_rounded,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutAppPage()),
                  ),
                ),
                const SizedBox(height: 8),
                _link(
                  context,
                  'حریم خصوصی',
                  Icons.shield_outlined,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PrivacyPage()),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Center(
            child: Text(
              '© ${AppInfo.releaseDate.split('/').first} ${AppInfo.appName} — تمام حقوق محفوظ است.',
              style: sans(size: 10.5, color: _grey500),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _link(
    BuildContext context,
    String t,
    IconData ic,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(ic, size: 18, color: _grey600),
            const SizedBox(width: 10),
            Expanded(child: Text(t, style: sans(size: 12.5))),
            const Icon(Icons.chevron_left_rounded, size: 18, color: _grey400),
          ],
        ),
      ),
    );
  }
}
