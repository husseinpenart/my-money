import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 👈 haptic
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/auth/presentation/pages/budget/budget_page.dart';
import 'package:money/layouts/HomeLayouts.dart';
import 'package:money/screens/contact_page.dart';
import 'package:money/screens/report_page.dart';
import 'package:money/widgets/custom_expandable_fab.dart';

const _navActive = Color.fromRGBO(78, 129, 239, 1);
const _navInactive = Color.fromRGBO(163, 168, 176, 1);
const _dur = Duration(milliseconds: 280);
const _curve = Curves.easeOutCubic;

typedef _NavItemData = ({String label, IconData active, IconData inactive});

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    Homelayouts(),
    BudgetPage(),
    ReportPage(),
    ContactPage(),
  ];

  static const List<_NavItemData> _items = [
    (
      label: BottomNavigations.home,
      active: Icons.home_rounded,
      inactive: Icons.home_outlined,
    ),
    (
      label: ScreenDictionary.calculationItems,
      active: Icons.account_balance_wallet_rounded,
      inactive: Icons.account_balance_wallet_outlined,
    ),
    (
      label: ScreenDictionary.report,
      active: Icons.bar_chart_rounded,
      inactive: Icons.bar_chart_outlined,
    ),
    (
      label: BottomNavigations.contacts,
      active: Icons.people_rounded,
      inactive: Icons.people_outline,
    ),
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // 👈 rebuild بی‌خود نه
    HapticFeedback.selectionClick(); // 👈 حس فیزیکی
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: _BottomBar(
        index: _selectedIndex,
        items: _items,
        onTap: _onItemTapped,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: const CustomExpandableFab(),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.index,
    required this.items,
    required this.onTap,
  });

  final int index;
  final List<_NavItemData> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(
          top: BorderSide(color: Color(0xFFF1F3F6), width: 1), // 👈 لبه‌ی مویی
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 22,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 74,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    data: items[i],
                    isActive: i == index,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.data,
    required this.isActive,
    required this.onTap,
  });

  final _NavItemData data;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? _navActive : _navInactive;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 👇 آیکون: فعال کمی بزرگ‌تر و بالا‌آمده (lift)
          AnimatedSlide(
            duration: _dur,
            curve: _curve,
            offset: Offset(0, isActive ? -0.15 : 0),
            child: AnimatedScale(
              duration: _dur,
              curve: _curve,
              scale: isActive ? 1.08 : 0.92,
              child: Icon(
                isActive ? data.active : data.inactive,
                size: 25,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 5),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontFamily: 'sans',
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
            child: Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 👇 نقطه‌ی درخشان (به‌جای کپسول/پس‌زمینه) — slot ثابت تا پرش نکند
          SizedBox(
            height: 12,
            child: Center(
              child: AnimatedScale(
                duration: _dur,
                curve: Curves.easeOutBack,
                scale: isActive ? 1 : 0,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _navActive,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _navActive.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
