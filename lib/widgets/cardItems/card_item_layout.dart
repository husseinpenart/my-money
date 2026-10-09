import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/data/dataResource/search_remote_data_source.dart';
import 'package:money/feature/model/search_models/search_filter.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/widgets/cardItems/card_items.dart';
import 'package:money/widgets/cardItems/filter_buttons.dart';
import 'package:money/widgets/contact/contact_style.dart';

enum CardFilter { all, receivable, debt, unpaid, partial, starred, paid }

enum CardSort { newest, oldest, amountDesc, amountAsc, dueSoon }

class CardItemLayout extends StatefulWidget {
  const CardItemLayout({super.key});

  @override
  State<CardItemLayout> createState() => _CardItemLayoutState();
}

class _CardItemLayoutState extends State<CardItemLayout> {
  final _ds = GetIt.I<SearchRemoteDataSource>();

  List<SearchDebt> _all = [];
  bool _loading = true;
  String? _error;

  CardFilter _filter = CardFilter.all;
  CardSort _sort = CardSort.newest;

  // 👈 sentinel های معتبر (به‌جای DateTime.max که وجود ندارد)
  static final DateTime _dMin = DateTime(0);
  static final DateTime _dMax = DateTime(9999, 12, 31);

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

  bool _match(SearchDebt d) => switch (_filter) {
    CardFilter.all => true,
    CardFilter.receivable => !d.isDebt,
    CardFilter.debt => d.isDebt,
    CardFilter.unpaid => !d.payStatus,
    // 👇 partial(=minor): چون PaidAmount نداریم، موقتاً «معوق». با PaidAmount عوض کن:
    //    d.payStatus == false && (d.paidAmount ?? 0) > 0 && (d.paidAmount ?? 0) < price
    CardFilter.partial =>
      !d.payStatus &&
          d.endedDate != null &&
          d.endedDate!.isBefore(DateTime.now()),
    CardFilter.starred => d.isStarred,
    CardFilter.paid => d.payStatus,
  };

  int _amt(SearchDebt d) => int.tryParse(d.wholePrice) ?? 0;

  List<SearchDebt> get _visible {
    final list = _all.where(_match).toList();
    list.sort(
      (a, b) => switch (_sort) {
        CardSort.newest => (b.registerdDate ?? _dMin).compareTo(
          a.registerdDate ?? _dMin,
        ),
        CardSort.oldest => (a.registerdDate ?? _dMax).compareTo(
          b.registerdDate ?? _dMax,
        ),
        CardSort.amountDesc => _amt(b).compareTo(_amt(a)),
        CardSort.amountAsc => _amt(a).compareTo(_amt(b)),
        CardSort.dueSoon => (a.endedDate ?? _dMax).compareTo(
          b.endedDate ?? _dMax,
        ),
      },
    );
    return list;
  }

  Future<void> _openSort() async {
    final picked = await showModalBottomSheet<CardSort>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text('مرتب‌سازی', style: sans(size: 15, weight: FontWeight.bold)),
            const SizedBox(height: 6),
            for (final s in CardSort.values)
              RadioListTile<CardSort>(
                value: s,
                groupValue: _sort,
                activeColor: kAccent,
                title: Text(_sortLabel(s), style: sans(size: 13)),
                onChanged: (v) => Navigator.of(ctx).pop(v),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _sort = picked);
  }

  String _sortLabel(CardSort s) => switch (s) {
    CardSort.newest => 'جدیدترین',
    CardSort.oldest => 'قدیمی‌ترین',
    CardSort.amountDesc => 'بیشترین مبلغ',
    CardSort.amountAsc => 'کمترین مبلغ',
    CardSort.dueSoon => 'نزدیک‌ترین سررسید',
  };

  @override
  Widget build(BuildContext context) {
    final filters = <(String, CardFilter)>[
      (ButtonsDictionary.allButton, CardFilter.all),
      (ScreenDictionary.demandText, CardFilter.receivable),
      (ScreenDictionary.debtsText, CardFilter.debt),
      (ButtonsDictionary.open, CardFilter.unpaid),
      (ButtonsDictionary.minor, CardFilter.partial),
      (ButtonsDictionary.important, CardFilter.starred),
      (ButtonsDictionary.settlement, CardFilter.paid),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final (label, f) in filters)
                FilterButtons(
                  title: label,
                  isSelected: _filter == f,
                  onTap: () => setState(() => _filter = f),
                ),
            ],
          ),
          const SizedBox(height: 10),

          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(color: kAccent)),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      _error!,
                      style: sans(size: 12, color: Colors.red.shade400),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _load,
                      child: Text('تلاش دوباره', style: sans(size: 12)),
                    ),
                  ],
                ),
              ),
            )
          else
            CardItems(
              items: _visible,
              onSortTap: _openSort,
              onChanged: _load, // بعد از ویرایش موفق، لیست تازه می‌شود
            ),
        ],
      ),
    );
  }
}
