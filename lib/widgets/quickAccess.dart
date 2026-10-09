import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/auth/presentation/pages/debt/debt_list_page.dart';
import 'package:money/feature/auth/presentation/pages/debt/report_page.dart';
import 'package:money/helper/list/menu_item.dart';
import 'package:money/layouts/confirm_demand_layout.dart';


class Quickaccess extends StatefulWidget {
  const Quickaccess({super.key});

  @override
  State<Quickaccess> createState() => _QuickaccessState();
}

class _QuickaccessState extends State<Quickaccess> {
  // آیتم‌ها داخل یک متد ساخته می‌شوند تا context برای navigate/bottomSheet در دسترس باشد.
  List<MenuItemModel> _items(BuildContext context) => [
    MenuItemModel(
      icon: Icons.compare_arrows_sharp,
      label: ScreenDictionary.approveDemand,
      iconColor: const Color.fromRGBO(77, 128, 239, 10),
      iconBackColor: const Color.fromRGBO(239, 246, 255, 10),
      onTap: () => showDebtFormSheet(context, hasDebt: false), // ثبت طلب
    ),
    MenuItemModel(
      icon: Icons.arrow_outward,
      label: ScreenDictionary.approveDebt,
      iconColor: const Color.fromRGBO(242, 102, 102, 10),
      iconBackColor: const Color.fromRGBO(254, 242, 242, 10),
      onTap: () => showDebtFormSheet(context, hasDebt: true), // ثبت بدهی
    ),
    MenuItemModel(
      icon: Icons.payment,
      label: ScreenDictionary.payment,
      iconColor: const Color.fromRGBO(119, 216, 182, 10),
      iconBackColor: const Color.fromRGBO(240, 253, 244, 10),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const DebtListPage(
            filter: DebtListFilter.paid,
            title: 'پرداخت‌شده‌ها',
            subtitle: 'تمام رکوردهایی که پرداخت آن‌ها ثبت شده است',
          ),
        ),
      ),
    ),
    MenuItemModel(
      icon: Icons.money_off,
      label: ScreenDictionary.fullsettlement,
      iconColor: const Color.fromRGBO(245, 159, 13, 10),
      iconBackColor: const Color.fromRGBO(255, 251, 235, 10),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const DebtListPage(
            filter: DebtListFilter.settledFull,
            title: 'تسویه‌کامل‌ها',
            subtitle: 'رکوردهایی که به‌طور کامل تسویه شده‌اند',
          ),
        ),
      ),
    ),
    MenuItemModel(
      icon: Icons.dashboard_outlined,
      label: ScreenDictionary.report,
      iconColor: const Color.fromRGBO(149, 106, 247, 10),
      iconBackColor: const Color.fromRGBO(239, 246, 255, 10),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ReportPage()),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.tryParse('470.70'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurStyle: BlurStyle.normal,
            spreadRadius: BorderSide.strokeAlignOutside,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ScreenDictionary.quickAccess,
            style: const TextStyle(fontFamily: 'sans'),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 10),
          Center(
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 15.0,
              runSpacing: 20.0,
              children: _items(context).map((item) {
                return Container(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: item.iconBackColor,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 7,
                              color: Colors.black.withValues(alpha: 0.08),
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(item.icon),
                          color: item.iconColor,
                          iconSize: 20,
                          onPressed: item.onTap,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'sans',
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}