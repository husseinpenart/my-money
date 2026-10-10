import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/feature/auth/presentation/bloc/budget/budget_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/budget/budget_event.dart';
import 'package:money/feature/auth/presentation/bloc/budget/budget_state.dart';
import 'package:money/feature/data/dataResource/budget_remote_data_source.dart';
import 'package:money/feature/model/budget/budget_models.dart';
import 'package:money/widgets/budget/budget_widgets.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/global/app_search_field.dart';
import 'package:money/widgets/report/report_format.dart';

class ExpensesTab extends StatefulWidget {
  const ExpensesTab({super.key});

  @override
  State<ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab> {
  final _ds = GetIt.I<BudgetRemoteDataSource>();
  final _scroll = ScrollController();
  Timer? _debounce;

  String _query = '';
  String? _category;
  int? _cycle;
  List<ExpenseModel> _items = [];
  int _page = 1, _totalPages = 0, _total = 0, _req = 0;
  bool _loading = true, _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cycle = context.read<BudgetBloc>().state.plan?.cycleKey;
    _scroll.addListener(() {
      if (_scroll.hasClients &&
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 120) {
        _load(reset: false);
      }
    });
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load({required bool reset}) async {
    if (!reset && (_loading || _loadingMore || _page >= _totalPages)) return;
    final req = ++_req;
    setState(() {
      if (reset) {
        _loading = true;
        _error = null;
      } else {
        _loadingMore = true;
      }
    });
    try {
      final r = await _ds.getExpenses(
        pageNumber: reset ? 1 : _page + 1,
        cycle: _cycle,
        query: _query,
        category: _category,
      );
      if (!mounted || req != _req) return;
      setState(() {
        _items = reset ? r.items : [..._items, ...r.items];
        _page = r.pageNumber;
        _totalPages = r.totalPages;
        _total = r.totalItems;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted || req != _req) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = e is BudgetApiException ? e.message : backendMessage(e);
      });
    }
  }

  Future<void> _confirmDelete(ExpenseModel e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'حذف هزینه',
          style: sans(size: 15, weight: FontWeight.bold),
        ),
        content: Text('هزینه‌ی «${e.title}» حذف شود؟', style: sans(size: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('انصراف', style: sans(size: 13)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'حذف',
              style: sans(size: 13, color: Colors.red.shade400),
            ),
          ),
        ],
      ),
    );
    if (ok == true && mounted)
      context.read<BudgetBloc>().add(BudgetExpenseDeleted(e.expenseId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BudgetBloc, BudgetState>(
      listenWhen: (p, c) =>
          p.version != c.version || p.plan?.cycleKey != c.plan?.cycleKey,
      listener: (context, s) {
        _cycle = s.plan?.cycleKey;
        _load(reset: true);
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: AppSearchField(
              hintText: 'جستجوی عنوان یا یادداشت',
              autofocus: false,
              isLoading: _loading,
              onChanged: (v) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 400), () {
                  _query = v.trim();
                  _load(reset: true);
                });
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text('همه', style: sans(size: 12)),
                    selected: _category == null,
                    showCheckmark: false,
                    selectedColor: kAccent.withValues(alpha: 0.15),
                    onSelected: (_) {
                      _category = null;
                      _load(reset: true);
                    },
                  ),
                ),
                for (final c in BudgetCategory.all)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      avatar: Icon(c.icon, size: 15, color: c.color),
                      label: Text(c.label, style: sans(size: 12)),
                      selected: _category == c.key,
                      showCheckmark: false,
                      selectedColor: c.color.withValues(alpha: 0.15),
                      onSelected: (_) {
                        _category = _category == c.key ? null : c.key;
                        _load(reset: true);
                      },
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 4),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                '${fa('$_total')} هزینه در این دوره',
                style: sans(size: 11, color: Colors.grey.shade600),
              ),
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: kAccent));
    }
    if (_error != null && _items.isEmpty) {
      return EmptyBox(
        icon: Icons.error_outline,
        text: _error!,
        action: 'تلاش دوباره',
        onAction: () => _load(reset: true),
      );
    }
    if (_items.isEmpty) {
      return const EmptyBox(
        icon: Icons.receipt_long_outlined,
        text: 'هزینه‌ای در این دوره ثبت نشده است',
      );
    }

    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      itemCount: _items.length + (_loadingMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= _items.length) {
          return const Padding(
            padding: EdgeInsets.all(14),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: kAccent,
                ),
              ),
            ),
          );
        }
        final e = _items[i];
        final cat = BudgetCategory.of(e.category);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          decoration: cardDeco(),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(cat.icon, size: 18, color: cat.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sans(size: 13, weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (e.date != null) jalaliDate(e.date!),
                        cat.label,
                        if ((e.note ?? '').isNotEmpty) e.note!,
                      ].join('  ·  '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sans(size: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Text(
                money(e.amount),
                style: sans(size: 13, weight: FontWeight.bold, color: kRed),
              ),
              IconButton(
                tooltip: 'حذف',
                visualDensity: VisualDensity.compact,
                onPressed: () => _confirmDelete(e),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
