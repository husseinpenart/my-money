import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/cache/contact_cache.dart';
import 'package:money/core/cache/sync_repository.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/model/contact/contact_model.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/helper/utils/input_utils.dart';
import 'package:money/widgets/cardItems/card_items.dart';
import 'package:money/widgets/cardItems/filter_buttons.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/global/sync_bar.dart';

enum CardFilter { all, receivable, debt, unpaid, partial, starred, paid }

enum CardSort { newest, oldest, amountDesc, amountAsc, dueSoon }

class CardItemLayout extends StatefulWidget {
  const CardItemLayout({super.key});

  @override
  State<CardItemLayout> createState() => _CardItemLayoutState();
}

class _CardItemLayoutState extends State<CardItemLayout> {
  final _cache = GetIt.I<ContactCache>();
  final _sync = GetIt.I<SyncRepository>();

  String? _error;
  CardFilter _filter = CardFilter.all;
  CardSort _sort = CardSort.newest;

  static final DateTime _dMin = DateTime(0);
  static final DateTime _dMax = DateTime(9999, 12, 31);

  @override
  void initState() {
    super.initState();
    _cache.addListener(_onCache);
    if (!_cache.hasData) _refresh(toast: false);
  }

  @override
  void dispose() {
    _cache.removeListener(_onCache);
    super.dispose();
  }

  void _onCache() {
    if (mounted) setState(() {});
  }

  Future<void> _refresh({bool toast = true}) async {
    setState(() => _error = null);
    try {
      final r = await _sync.refresh();
      if (toast && mounted) _snack(r.message, false);
    } catch (e) {
      final msg = e is ContactApiException ? e.message : backendMessage(e);
      if (!mounted) return;
      if (_cache.hasData) {
        _snack(msg, true);
      } else {
        setState(() => _error = msg);
      }
    }
  }

  void _snack(String m, bool err) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: err ? Colors.red.shade600 : Colors.green.shade600,
          content: Text(m, style: sans(size: 13, color: Colors.white)),
        ),
      );
  }

  bool _match(SearchDebt d) => switch (_filter) {
    CardFilter.all => true,
    CardFilter.receivable => !d.isDebt,
    CardFilter.debt => d.isDebt,
    CardFilter.unpaid => !d.payStatus,
    // «جزئی»: چون مبلغ پرداخت‌شده در بک‌اند نیست، فعلاً «معوق»
    CardFilter.partial =>
      !d.payStatus &&
          d.endedDate != null &&
          d.endedDate!.isBefore(DateTime.now()),
    CardFilter.starred => d.isStarred,
    CardFilter.paid => d.payStatus,
  };

  double _amt(SearchDebt d) => parseAmount(d.wholePrice) ?? 0;

  List<SearchDebt> get _visible {
    final list = _cache.allDebts.where(_match).toList();
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
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _sync.syncing,
            builder: (context, busy, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SyncBar(
                syncedAt: _cache.syncedAt,
                busy: busy,
                onRefresh: _refresh,
              ),
            ),
          ),
          const SizedBox(height: 10),
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
          if (!_cache.hasData && _error == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(color: kAccent)),
            )
          else if (!_cache.hasData)
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
                      onPressed: _refresh,
                      child: Text('تلاش دوباره', style: sans(size: 12)),
                    ),
                  ],
                ),
              ),
            )
          else
            // Commandها (ویرایش، ستاره، تسویه، حذف) خودشان کش را به‌روز می‌کنند
            CardItems(items: _visible, onSortTap: _openSort),
        ],
      ),
    );
  }
}
