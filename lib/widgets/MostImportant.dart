import 'package:flutter/gestures.dart'; // 👈 برای PointerDeviceKind
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/bus/debt_change_bus.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/auth/presentation/pages/debt/debt_details_sheet.dart';
import 'package:money/feature/auth/presentation/pages/important/important_debts_page.dart';
import 'package:money/feature/data/dataResource/search_remote_data_source.dart';
import 'package:money/feature/model/search_models/search_filter.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/helper/list/mount_money.dart';
import 'package:money/widgets/report/report_format.dart';

class Mostimportant extends StatefulWidget {
  const Mostimportant({super.key});

  @override
  State<Mostimportant> createState() => _MostimportantState();
}

class _MostimportantState extends State<Mostimportant> {
  final _ds = GetIt.I<SearchRemoteDataSource>();

  List<SearchDebt> _raw = [];
  List<MountMoney> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    DebtChangeBus.instance.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    DebtChangeBus.instance.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final starred = <SearchDebt>[];
      int page = 1;
      while (true) {
        final res = await _ds.search(
          query: '',
          filter: const SearchFilter(type: SearchType.debts),
          pageNumber: page,
          pageSize: 100,
        );
        starred.addAll(res.debts.items.where((d) => d.isStarred));
        if (!res.debts.hasMore) break;
        page++;
        if (page > 10) break;
      }
      starred.sort(
        (a, b) => (int.tryParse(b.wholePrice) ?? 0).compareTo(
          int.tryParse(a.wholePrice) ?? 0,
        ),
      );

      // 👈 تشخیص قطعی «آیا اصلاً چیزی برای اسکرول هست؟»
      debugPrint('>>> carousel starred count = ${starred.length}');

      setState(() {
        _raw = starred;
        _items = starred.map(_toCard).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = backendMessage(e);
      });
    }
  }

  MountMoney _toCard(SearchDebt d) {
    final price = int.tryParse(d.wholePrice) ?? 0;
    final isDebt = d.isDebt;
    final name = d.contactName.trim();
    return MountMoney(
      firstCharacter: name.isEmpty ? '؟' : name.substring(0, 1),
      name: name.isEmpty ? '—' : name,
      price: money(price),
      title: isDebt ? 'بدهی' : 'طلب',
      priceTypeColor: isDebt ? Colors.red : Colors.green,
    );
  }

  Future<void> _open(SearchDebt d) async {
    await showDebtDetails(context, d);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ───── هدر (دست‌نخورده) ─────
        Container(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 124,
            children: [
              Text(
                ScreenDictionary.mostSee,
                style: const TextStyle(fontSize: 14, fontFamily: 'sans'),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ImportantDebtsPage(),
                      ),
                    ),
                    child: const Text(
                      'مشاهده همه',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'sans',
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    ScreenDictionary.importantOnes,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'sans',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ───── کاروسل ─────
        Container(
          height: 180,
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'sans',
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                )
              : _items.isEmpty
              ? const Center(
                  child: Text(
                    'مورد ستاره‌داری ثبت نشده',
                    style: TextStyle(
                      fontFamily: 'sans',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                )
              // 👇 ScrollConfiguration: روی وب ماوس/trackpad هم drag می‌کند
              : ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                      PointerDeviceKind.stylus,
                    },
                  ),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 15),
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () => _open(_raw[i]),
                      child: _card(_items[i]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _card(MountMoney item) {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(15),
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, 0.5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      transform: const GradientRotation(10),
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: const [
                        Color.fromRGBO(56, 0, 146, 1),
                        Color.fromRGBO(102, 26, 224, 1),
                        Color.fromRGBO(160, 112, 236, 1),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item.firstCharacter,
                      style: const TextStyle(
                        fontFamily: 'sans',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontFamily: 'sans',
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontFamily: 'sans',
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.price,
                style: TextStyle(
                  fontFamily: 'sans',
                  color: item.priceTypeColor,
                  fontSize: 14,
                ),
              ),
              const Text(
                'تومان',
                style: TextStyle(
                  fontFamily: 'sans',
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
