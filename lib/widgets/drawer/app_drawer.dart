import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/cache/contact_cache.dart';
import 'package:money/core/di/injection.dart';
import 'package:money/core/drawer/app_info.dart';
import 'package:money/core/storage/session/session_cleaner.dart';
import 'package:money/core/storage/token_storage.dart';
import 'package:money/feature/auth/presentation/pages/drawer/about_app_page.dart';
import 'package:money/feature/auth/presentation/pages/drawer/about_me_page.dart';
import 'package:money/feature/auth/presentation/pages/drawer/coffee_page.dart';
import 'package:money/feature/auth/presentation/pages/drawer/privacy_page.dart';
import 'package:money/feature/auth/presentation/pages/drawer/version_page.dart';
import 'package:money/screens/intro_page.dart';
import 'package:money/widgets/auth/recovery_code_dialog.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/drawer/delete_account_dialog.dart';
import 'package:money/widgets/drawer/drawer_tile.dart';

const _brandA = Color(0xFF4F28DF);
const _brandB = Color(0xFF947BEE);
const _red400 = Color(0xFFEF5350);

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _name = 'کاربر عزیز';

  @override
  void initState() {
    super.initState();
    final stored = GetIt.I<TokenStorage>().getName();
    if (stored != null && stored.isNotEmpty) _name = stored;
  }

  void _go(Widget page) {
    // Navigator قبل از pop گرفته می‌شود تا به context بسته‌شده وابسته نباشیم
    final nav = Navigator.of(context);
    nav.pop();
    nav.push(MaterialPageRoute(builder: (_) => page));
  }

  void _toIntro(NavigatorState nav) {
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const IntroPage()),
      (_) => false,
    );
  }

  Future<void> _logout() async {
    final nav = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'خروج از حساب',
          style: sans(size: 15, weight: FontWeight.bold),
        ),
        content: Text('مطمئنی می‌خواهی خارج شوی؟', style: sans(size: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('انصراف', style: sans(size: 13)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('خروج', style: sans(size: 13, color: _red400)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await SessionCleaner.clear();
    _toIntro(nav);
  }

  Future<void> _deleteAccount() async {
    final nav = Navigator.of(context);
    final deleted = await showDeleteAccountDialog(context);
    if (!deleted) return;
    await getIt<ContactCache>().clear();
    await SessionCleaner.clear();
    _toIntro(nav);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 6),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _label('اپلیکیشن'),
                  DrawerTile(
                    icon: Icons.info_outline_rounded,
                    title: 'درباره برنامه',
                    onTap: () => _go(const AboutAppPage()),
                  ),
                  DrawerTile(
                    icon: Icons.person_outline_rounded,
                    title: 'درباره من',
                    color: const Color(0xFF7C3AED),
                    onTap: () => _go(const AboutMePage()),
                  ),
                  DrawerTile(
                    icon: Icons.shield_outlined,
                    title: 'حریم خصوصی کاربران',
                    color: const Color(0xFF0EA5E9),
                    onTap: () => _go(const PrivacyPage()),
                  ),
                  DrawerTile(
                    icon: Icons.local_cafe_outlined,
                    title: 'من را به یک قهوه مهمان کن',
                    color: const Color(0xFFD97706),
                    onTap: () => _go(const CoffeePage()),
                  ),
                  DrawerTile(
                    icon: Icons.tag_rounded,
                    title: 'نسخه اپلیکیشن',
                    subtitle: 'v${AppInfo.version}',
                    color: const Color(0xFF64748B),
                    onTap: () => _go(const VersionPage()),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Divider(height: 1),
                  ),
                  _label('حساب کاربری'),
                  DrawerTile(
                    icon: Icons.vpn_key_outlined,
                    title: 'کد بازیابی رمز عبور',
                    subtitle: 'ساخت کد جدید، کد قبلی باطل می‌شود',
                    color: const Color(0xFF10B981),
                    onTap: () => showGenerateRecoveryCodeFlow(context),
                  ),
                  DrawerTile(
                    icon: Icons.delete_forever_outlined,
                    title: 'حذف حساب',
                    subtitle: 'پاک شدن دائمی همه‌ی اطلاعات',
                    color: _red400,
                    onTap: _deleteAccount,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            DrawerTile(
              icon: Icons.logout_rounded,
              title: 'خروج از حساب',
              color: _red400,
              trailing: const SizedBox.shrink(),
              onTap: _logout,
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 2),
    child: Text(
      t,
      style: sans(
        size: 11,
        weight: FontWeight.bold,
        color: const Color(0xFF9E9E9E),
      ),
    ),
  );

  Widget _header() {
    final initial = _name.isEmpty ? '؟' : _name.characters.first.toUpperCase();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [_brandA, _brandB],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Image.asset(
              AppInfo.logoAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppInfo.appName,
            style: sans(size: 16, weight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 3),
          Text(
            AppInfo.appTagline,
            style: sans(size: 11.5, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  initial,
                  style: sans(
                    size: 14,
                    weight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: sans(
                    size: 13,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
