import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/data/dataResource/search_remote_data_source.dart';
import 'package:money/feature/model/search_models/search_filter.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/layouts/confirm_demand_layout.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/report/report_format.dart';

enum DebtListFilter { all, paid, unpaid, settledFull }

class DebtListPage extends StatefulWidget {
  const DebtListPage({
    super.key,
    required this.filter,
    required this.title,
    this.subtitle,
  });

  final DebtListFilter filter;
  final String title;
  final String? subtitle;

  @override
  State<DebtListPage> createState() => _DebtListPageState();
}

class _DebtListPageState extends State<DebtListPage> {
  final _ds = GetIt.I<SearchRemoteDataSource>();
  final _scroll = ScrollController();

  List<SearchDebt> _all = [];
  int _page = 1;
  bool _hasMore = false;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.hasClients &&
        _scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _load(more: true);
    }
  }

  Future<void> _load({bool more = false}) async {
    if (more && (_loadingMore || !_hasMore)) return;
    setState(() {
      if (more) {
        _loadingMore = true;
      } else {
        _loading = true;
        _error = null;
      }
    });

    try {
      final res = await _ds.search(
        query: '',
        // 👇 اگر نام enum نوع رکورد در search_filter.dart چیز دیگری است، همین را عوض کن
        filter: const SearchFilter(type: SearchType.debts),
        pageNumber: more ? _page + 1 : 1,
        pageSize: 100,
      );
      final items = res.debts.items;
      setState(() {
        _all = more ? [..._all, ...items] : items;
        _page = res.debts.pageNumber;
        _hasMore = res.debts.hasMore;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = backendMessage(e);
      });
    }
  }

  // 👇 تنها نقطه‌ای که با اضافه‌شدن PaidAmount به مدل/DB عوض می‌شود:
  bool _match(SearchDebt d) => switch (widget.filter) {
    DebtListFilter.all => true,
    DebtListFilter.paid => d.payStatus, // هر چه پرداخت شده
    DebtListFilter.unpaid => !d.payStatus,
    // تسویه‌کامل: فعلاً همان payStatus (چون فیلد پرداختِ جزئی نداریم).
    // وقتی PaidAmount اضافه شد: d.payStatus && d.paidAmount == d.wholePrice
    DebtListFilter.settledFull => d.payStatus,
  };

  @override
  Widget build(BuildContext context) {
    final visible = _all.where(_match).toList()
      ..sort((a, b) {
        final da = a.endedDate, db = b.endedDate;
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: sans(size: 16, weight: FontWeight.bold),
        ),
        bottom: widget.subtitle == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(28),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.subtitle!,
                      style: sans(size: 11, color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ),
      ),
      body: _body(visible),
    );
  }

  Widget _body(List<SearchDebt> visible) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: kAccent));
    }
    if (_error != null && _all.isEmpty) {
      return _Msg(
        icon: Icons.error_outline,
        text: _error!,
        actionLabel: 'تلاش دوباره',
        onAction: _load,
      );
    }
    if (visible.isEmpty) {
      return _Msg(
        icon: Icons.inbox_outlined,
        text: 'موردی برای نمایش وجود ندارد',
      );
    }

    return RefreshIndicator(
      color: kAccent,
      onRefresh: _load,
      child: ListView.separated(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount: visible.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          if (i >= visible.length) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: kAccent,
                  ),
                ),
              ),
            );
          }
          return _DebtRow(d: visible[i]);
        },
      ),
    );
  }
}

class _DebtRow extends StatelessWidget {
  const _DebtRow({required this.d});
  final SearchDebt d;

  @override
  Widget build(BuildContext context) {
    final isDebt = d.isDebt;
    final color = isDebt
        ? const Color.fromRGBO(239, 68, 68, 1)
        : const Color.fromRGBO(49, 190, 145, 1);
    final icon = isDebt ? Icons.north_east : Icons.south_west;
    final price = int.tryParse(d.wholePrice) ?? 0;

    return InkWell(
      onTap: () => showDebtFormSheet(context, initial: d), // ویرایش
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
                          d.contactName.isEmpty ? '—' : d.contactName,
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
