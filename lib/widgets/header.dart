import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/storage/token_storage.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/auth/presentation/pages/search/search_sheet.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/drawer/drawer_menu_button.dart'; // 👈 جدید
import 'package:money/widgets/global/notification_bell.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  String _userName = 'کاربر عزیز';

  @override
  void initState() {
    super.initState();
    final stored = GetIt.I<TokenStorage>().getName();
    if (stored != null && stored.isNotEmpty) _userName = stored;
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 5) return 'شب بخیر';
    if (h < 12) return 'صبح بخیر';
    if (h < 17) return 'ظهر بخیر';
    if (h < 20) return 'عصر بخیر';
    return 'شب بخیر';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // 👈 دکمه‌ی منو داخل باکس گرادیانی هم‌اندازه‌ی آواتار قبلی
              Container(
                width: 44,
                height: 44,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFF4F28DF), Color(0xFF947BEE)],
                  ),
                ),
                child: const DrawerMenuButton(color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${Titles.hello} · $_greeting',
                      style: sans(size: 11, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_userName 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sans(
                        size: 15,
                        weight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const NotificationBell(),
            ],
          ),
          const SizedBox(height: 14),

          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () => showSearchSheet(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: kAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        Titles.searchText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: sans(size: 13, color: Colors.grey.shade500),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: kAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        size: 16,
                        color: kAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
