import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/auth/presentation/pages/debt/debt_details_sheet.dart';
import 'package:money/feature/data/dataResource/search_remote_data_source.dart';
import 'package:money/feature/model/search_models/search_filter.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/report/report_format.dart';

class ImportantDebtsPage extends StatefulWidget {
  const ImportantDebtsPage({super.key});

  @override
  State<ImportantDebtsPage> createState() => _ImportantDebtsPageState();
}

class _ImportantDebtsPageState extends State<ImportantDebtsPage> {
  final _ds = GetIt.I<SearchRemoteDataSource>();

  List<SearchDebt> _all = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final acc = <SearchDebt>[];
      int page = 1;
      while (true) {
        final res = await _ds.search(
          query: '',
          // 👇 اگر نام عضو enum نوع در search_filter.dart فرق دارد، همین یک خط
          filter: const SearchFilter(type: SearchType.debts),
          pageNumber: page,
          pageSize: 100,
        );
        acc.addAll(res.debts.items);
        if (!res.debts.hasMore) break; // 👇 اگر نام فیلد PagedResult فرق دارد
        page++;
        if (page > 10) break; // سقف ایمنی
      }
      setState(() {
        _all = acc;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = backendMessage(e);
      });
    }
  }

  List<SearchDebt> get _starred =>
      _all.where((d) => d.isStarred).toList()..sort(_byAmountDesc);

  // 👇 «۲۵ آیتم مهم» = ۲۵ مورد برتر بر اساس مبلغ.
  //    اگر منظورت «۲۵ مورد آخر بر اساس تاریخ ثبت» بود، فقط sort زیر را عوض کن:
  //    ..sort((a, b) => (b.registerdDate ?? DateTime(0))
  //        .compareTo(a.registerdDate ?? DateTime(0)));
  List<SearchDebt> get _top25 {
    final sorted = [..._all]..sort(_byAmountDesc);
    return sorted.take(25).toList();
  }

  static int _amt(SearchDebt d) => int.tryParse(d.wholePrice) ?? 0;
  static int _byAmountDesc(SearchDebt a, SearchDebt b) =>
      _amt(b).compareTo(_amt(a));

  Future<void> _open(SearchDebt d) async {
    final changed = await showDebtDetails(context, d);
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'موارد مهم',
            style: sans(size: 16, weight: FontWeight.bold),
          ),
          bottom: const TabBar(
            labelColor: kAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: kAccent,
            tabs: [
              Tab(text: 'ستاره‌دارها'),
              Tab(text: '۲۵ مورد برتر'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: kAccent))
            : _error != null
            ? _Msg(
                icon: Icons.error_outline,
                text: _error!,
                actionLabel: 'تلاش دوباره',
                onAction: _load,
              )
            : TabBarView(
                children: [
                  _list(_starred, emptyText: 'مورد ستاره‌داری ثبت نشده'),
                  _list(_top25, emptyText: 'موردی برای نمایش وجود ندارد'),
                ],
              ),
      ),
    );
  }

  Widget _list(List<SearchDebt> items, {required String emptyText}) {
    if (items.isEmpty) return _Msg(icon: Icons.inbox_outlined, text: emptyText);
    return RefreshIndicator(
      color: kAccent,
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) =>
            _Tile(d: items[i], onTap: () => _open(items[i])),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.d, required this.onTap});
  final SearchDebt d;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDebt = d.isDebt;
    final color = isDebt
        ? const Color.fromRGBO(239, 68, 68, 1)
        : const Color.fromRGBO(49, 190, 145, 1);
    final icon = isDebt ? Icons.north_east : Icons.south_west;
    final price = int.tryParse(d.wholePrice) ?? 0;
    final name = d.contactName.trim();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black.withValues(alpha: 0.04),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name.isEmpty ? '—' : name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: sans(size: 13, weight: FontWeight.bold),
                        ),
                      ),
                      if (d.isStarred)
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Colors.amber,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDebt ? 'بدهی' : 'طلب',
                    style: sans(size: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.event_busy_outlined,
                        size: 11,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'سررسید: ${d.endedDate == null ? '—' : jalaliDate(d.endedDate!)}',
                        style: sans(size: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  money(price),
                  style: sans(size: 14, weight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: d.payStatus
                        ? const Color.fromRGBO(240, 253, 244, 1)
                        : const Color.fromRGBO(254, 243, 199, 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    d.payStatus ? 'پرداخت‌شده' : 'پرداخت‌نشده',
                    style: sans(
                      size: 10,
                      color: d.payStatus
                          ? const Color.fromRGBO(49, 190, 145, 1)
                          : const Color.fromRGBO(176, 123, 77, 1),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Msg extends StatelessWidget {
  const _Msg({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: sans(size: 13, color: Colors.grey.shade600),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onAction,
              child: Text(actionLabel!, style: sans(size: 12)),
            ),
          ],
        ],
      ),
    );
  }
}
