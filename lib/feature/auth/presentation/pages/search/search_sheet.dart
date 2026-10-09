import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:money/feature/auth/presentation/pages/contact/contact_details_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money/core/bus/debt_change_bus.dart';
import 'package:money/feature/auth/presentation/bloc/search/search_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/search/search_event.dart';
import 'package:money/feature/auth/presentation/bloc/search/search_state.dart';
import 'package:money/feature/auth/presentation/pages/debt/debt_details_sheet.dart';
import 'package:money/feature/model/search_models/search_filter.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/helper/utils/input_utils.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/global/app_search_field.dart';
import 'package:money/widgets/report/report_format.dart';

Future<void> showSearchSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => const SearchSheet(),
  );
}

// ───────────────────── جستجوهای اخیر ─────────────────────
class _RecentStore {
  static const _k = 'recent_searches';
  static const _max = 8;

  static SharedPreferences get _p => GetIt.I<SharedPreferences>();

  static List<String> load() => _p.getStringList(_k) ?? <String>[];

  static Future<List<String>> add(String q) async {
    final t = q.trim();
    if (t.length < 2) return load();
    final list = load()..remove(t);
    list.insert(0, t);
    final cut = list.take(_max).toList();
    await _p.setStringList(_k, cut);
    return cut;
  }

  static Future<List<String>> remove(String q) async {
    final list = load()..remove(q);
    await _p.setStringList(_k, list);
    return list;
  }

  static Future<void> clear() => _p.remove(_k);
}

class SearchSheet extends StatefulWidget {
  const SearchSheet({super.key});

  @override
  State<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  late final SearchBloc _bloc;
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  List<String> _recent = [];

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I<SearchBloc>();
    _recent = _RecentStore.load();
    _scroll.addListener(() {
      if (_scroll.hasClients &&
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 120) {
        _bloc.add(const SearchLoadMore());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _bloc.close();
    super.dispose();
  }

  void _query(String v) => _bloc.add(SearchQueryChanged(v));

  Future<void> _remember() async {
    final list = await _RecentStore.add(_controller.text);
    if (mounted) setState(() => _recent = list);
  }

  void _afterChange() {
    DebtChangeBus.instance.notifyChanged();
    _query(_controller.text);
  }

  Future<void> _openDebt(SearchDebt d) async {
    _remember();
    final changed = await showDebtDetails(context, d);
    if (changed && mounted) _afterChange();
  }

  Future<void> _openContact(SearchContact c) async {
    _remember();
    final changed = await showContactDetails(context, c);
    if (changed && mounted) _afterChange();
  }

  void _useRecent(String q) {
    _controller.text = q;
    _controller.selection = TextSelection.collapsed(offset: q.length);
    _query(q);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return BlocProvider.value(
      value: _bloc,
      child: Container(
        height: media.size.height * 0.92,
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                  Expanded(
                    child: Text(
                      'جستجو',
                      textAlign: TextAlign.center,
                      style: sans(size: 16, weight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: BlocBuilder<SearchBloc, SearchState>(
                buildWhen: (p, c) => p.status != c.status,
                builder: (context, s) => AppSearchField(
                  controller: _controller,
                  hintText: 'نام، شماره، مبلغ یا توضیحات...',
                  isLoading: s.status == SearchStatus.loading,
                  onChanged: _query,
                  onSubmitted: (_) => _remember(),
                ),
              ),
            ),
            BlocBuilder<SearchBloc, SearchState>(
              builder: (context, s) => Column(
                children: [
                  _TypeTabs(state: s),
                  if (s.filter.type != SearchType.contacts)
                    _DebtFilters(state: s),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, s) => _body(s),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────── بدنه ─────────────
  Widget _body(SearchState s) {
    final hasData = s.contacts.items.isNotEmpty || s.debts.items.isNotEmpty;

    if (s.status == SearchStatus.initial) return _initial();

    if (s.status == SearchStatus.loading && !hasData) {
      return const Center(child: CircularProgressIndicator(color: kAccent));
    }

    if (s.status == SearchStatus.failure && !hasData) {
      return _Message(
        icon: Icons.error_outline,
        text: s.error ?? 'خطا در دریافت اطلاعات',
        color: Colors.red.shade400,
        action: 'تلاش دوباره',
        onAction: () => _query(_controller.text),
      );
    }

    if (s.isEmptyResult) {
      return _Message(
        icon: Icons.search_off,
        text: 'نتیجه‌ای برای «${s.query}» پیدا نشد',
      );
    }

    final showContacts = s.filter.type != SearchType.debts;
    final showDebts = s.filter.type != SearchType.contacts;

    return Column(
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: s.status == SearchStatus.loading ? 1 : 0,
          child: const LinearProgressIndicator(minHeight: 2, color: kAccent),
        ),
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
            children: [
              if (showContacts && s.contacts.items.isNotEmpty) ...[
                _SectionTitle('مخاطبین', s.contacts.totalItems),
                for (final c in s.contacts.items)
                  _ContactTile(
                    contact: c,
                    query: s.query,
                    onTap: () => _openContact(c),
                  ),
              ],
              if (showDebts && s.debts.items.isNotEmpty) ...[
                _SectionTitle('بدهی و طلب', s.debts.totalItems),
                for (final d in s.debts.items)
                  _DebtTile(debt: d, query: s.query, onTap: () => _openDebt(d)),
              ],
              if (s.isLoadingMore)
                const Padding(
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
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _initial() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_recent.isNotEmpty) ...[
          Row(
            children: [
              Text(
                'جستجوهای اخیر',
                style: sans(size: 12, weight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  await _RecentStore.clear();
                  if (mounted) setState(() => _recent = []);
                },
                child: Text('پاک کردن', style: sans(size: 11)),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final q in _recent)
                InputChip(
                  avatar: Icon(
                    Icons.history,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  label: Text(q, style: sans(size: 12)),
                  onPressed: () => _useRecent(q),
                  onDeleted: () async {
                    final l = await _RecentStore.remove(q);
                    if (mounted) setState(() => _recent = l);
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),
        ],
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.tips_and_updates_outlined,
                    size: 18,
                    color: kAccent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'نکته‌های جستجو',
                    style: sans(
                      size: 12,
                      weight: FontWeight.bold,
                      color: kAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _tip('نام یا شماره‌ی مخاطب را بنویس'),
              _tip('چند کلمه را با فاصله بنویس؛ همه‌ی کلمه‌ها باید پیدا شوند'),
              _tip('کلمه‌ی «بدهی» یا «طلب» فقط همان نوع را نشان می‌دهد'),
              _tip(
                'با فیلترهای پایین، فقط پرداخت‌نشده‌ها یا ستاره‌دارها را ببین',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tip(String t) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('•  ', style: sans(size: 12, color: Colors.grey.shade600)),
        Expanded(
          child: Text(t, style: sans(size: 12, color: Colors.grey.shade700)),
        ),
      ],
    ),
  );
}

// ───────────────────── تب‌ها ─────────────────────
class _TypeTabs extends StatelessWidget {
  final SearchState state;
  const _TypeTabs({required this.state});

  @override
  Widget build(BuildContext context) {
    final ok = state.status == SearchStatus.success;
    String label(String t, int n) => ok ? '$t (${fa('$n')})' : t;

    final items = <(SearchType, String)>[
      (SearchType.all, 'همه'),
      (SearchType.contacts, label('مخاطبین', state.contacts.totalItems)),
      (SearchType.debts, label('بدهی و طلب', state.debts.totalItems)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Row(
        children: [
          for (final (type, text) in items)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(text, style: sans(size: 12)),
                selected: state.filter.type == type,
                selectedColor: kAccent.withValues(alpha: 0.15),
                showCheckmark: false,
                onSelected: (_) => context.read<SearchBloc>().add(
                  SearchFilterChanged(state.filter.copyWith(type: type)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────── فیلترها ─────────────────────
class _DebtFilters extends StatelessWidget {
  final SearchState state;
  const _DebtFilters({required this.state});

  @override
  Widget build(BuildContext context) {
    final f = state.filter;
    final bloc = context.read<SearchBloc>();

    Widget chip(String text, bool selected, SearchFilter next) => Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: FilterChip(
        label: Text(text, style: sans(size: 11)),
        selected: selected,
        selectedColor: kAccent.withValues(alpha: 0.15),
        checkmarkColor: kAccent,
        visualDensity: VisualDensity.compact,
        onSelected: (_) => bloc.add(SearchFilterChanged(next)),
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          chip(
            'بدهی',
            f.recordType == 'Debt',
            f.recordType == 'Debt'
                ? f.copyWith(clearRecordType: true)
                : f.copyWith(recordType: 'Debt'),
          ),
          chip(
            'طلب',
            f.recordType == 'Receivable',
            f.recordType == 'Receivable'
                ? f.copyWith(clearRecordType: true)
                : f.copyWith(recordType: 'Receivable'),
          ),
          chip(
            'پرداخت‌نشده',
            f.payStatus == false,
            f.payStatus == false
                ? f.copyWith(clearPayStatus: true)
                : f.copyWith(payStatus: false),
          ),
          chip(
            'پرداخت‌شده',
            f.payStatus == true,
            f.payStatus == true
                ? f.copyWith(clearPayStatus: true)
                : f.copyWith(payStatus: true),
          ),
          chip(
            'ستاره‌دار',
            f.isStarred == true,
            f.isStarred == true
                ? f.copyWith(clearIsStarred: true)
                : f.copyWith(isStarred: true),
          ),
          if (f.isActive)
            TextButton.icon(
              onPressed: () =>
                  bloc.add(SearchFilterChanged(SearchFilter(type: f.type))),
              icon: const Icon(Icons.close, size: 14),
              label: Text(
                'پاک کردن فیلترها',
                style: sans(size: 11, color: Colors.red.shade400),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────── هایلایت ─────────────────────
class _Highlight extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final int maxLines;
  const _Highlight({
    required this.text,
    required this.query,
    required this.style,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final terms = normalizeDigits(
      query,
    ).toLowerCase().split(' ').where((t) => t.isNotEmpty).toList();
    if (terms.isEmpty || text.isEmpty) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    final lower = text.toLowerCase();
    final ranges = <(int, int)>[];
    for (final t in terms) {
      var i = lower.indexOf(t);
      while (i != -1) {
        ranges.add((i, i + t.length));
        i = lower.indexOf(t, i + t.length);
      }
    }
    if (ranges.isEmpty) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    ranges.sort((a, b) => a.$1.compareTo(b.$1));
    final merged = <(int, int)>[];
    for (final r in ranges) {
      if (merged.isNotEmpty && r.$1 <= merged.last.$2) {
        merged[merged.length - 1] = (
          merged.last.$1,
          r.$2 > merged.last.$2 ? r.$2 : merged.last.$2,
        );
      } else {
        merged.add(r);
      }
    }

    final spans = <TextSpan>[];
    var pos = 0;
    for (final r in merged) {
      if (r.$1 > pos) spans.add(TextSpan(text: text.substring(pos, r.$1)));
      spans.add(
        TextSpan(
          text: text.substring(r.$1, r.$2),
          style: TextStyle(
            backgroundColor: const Color(0xFFFFF3B0),
            fontWeight: FontWeight.bold,
            color: style.color,
          ),
        ),
      );
      pos = r.$2;
    }
    if (pos < text.length) spans.add(TextSpan(text: text.substring(pos)));

    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ───────────────────── آیتم‌ها ─────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;
  const _SectionTitle(this.title, this.count);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
    child: Row(
      children: [
        Text(
          title,
          style: sans(
            size: 12,
            weight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            fa('$count'),
            style: sans(size: 11, color: Colors.blueGrey),
          ),
        ),
      ],
    ),
  );
}

BoxDecoration _cardDeco() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  border: Border.all(color: const Color(0xFFEEF0F4)),
);

class _ContactTile extends StatelessWidget {
  final SearchContact contact;
  final String query;
  final VoidCallback onTap;
  const _ContactTile({
    required this.contact,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unpaid = contact.debts.where((d) => !d.payStatus).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: _cardDeco(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: kAccent.withValues(alpha: 0.12),
                child: Text(
                  contact.name.isEmpty ? '؟' : contact.name.characters.first,
                  style: sans(
                    size: 15,
                    weight: FontWeight.bold,
                    color: kAccent,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Highlight(
                      text: contact.name,
                      query: query,
                      style: sans(
                        size: 14,
                        weight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    _Highlight(
                      text: contact.phoneNumber,
                      query: query,
                      style: sans(size: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              if (contact.debts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: unpaid > 0
                        ? Colors.orange.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    unpaid > 0 ? '${fa('$unpaid')} باز' : 'تسویه',
                    style: sans(
                      size: 10,
                      weight: FontWeight.bold,
                      color: unpaid > 0
                          ? Colors.orange.shade800
                          : Colors.green.shade700,
                    ),
                  ),
                ),
              Icon(Icons.chevron_left, size: 18, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  final SearchDebt debt;
  final String query;
  final VoidCallback onTap;
  const _DebtTile({
    required this.debt,
    required this.query,
    required this.onTap,
  });

  (String, Color) get _status {
    if (debt.payStatus) return ('تسویه‌شده', const Color(0xFF10B981));
    final e = debt.endedDate;
    if (e == null) return ('پرداخت‌نشده', Colors.orange.shade800);
    final u = e.toUtc();
    final n = DateTime.now().toUtc();
    final days = DateTime.utc(
      u.year,
      u.month,
      u.day,
    ).difference(DateTime.utc(n.year, n.month, n.day)).inDays;
    if (days < 0)
      return ('${fa('${days.abs()}')} روز معوق', const Color(0xFFEF4444));
    if (days == 0) return ('امروز سررسید', const Color(0xFFF97316));
    if (days <= 3) return ('${fa('$days')} روز مانده', const Color(0xFFF59E0B));
    return ('${fa('$days')} روز مانده', Colors.blueGrey);
  }

  @override
  Widget build(BuildContext context) {
    final color = debt.isDebt
        ? const Color(0xFFEF4444)
        : const Color(0xFF10B981);
    final desc = (debt.description ?? '').trim();
    final amount = parseAmount(debt.wholePrice);
    final (statusText, statusColor) = _status;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: _cardDeco(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  debt.isDebt ? Icons.north_east : Icons.south_west,
                  size: 17,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: _Highlight(
                            text: debt.contactName,
                            query: query,
                            style: sans(
                              size: 14,
                              weight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (debt.isStarred)
                          const Padding(
                            padding: EdgeInsetsDirectional.only(start: 4),
                            child: Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Colors.amber,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    _Highlight(
                      text: desc.isEmpty
                          ? (debt.isDebt ? 'بدهی' : 'طلب')
                          : desc,
                      query: query,
                      style: sans(size: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount == null ? debt.wholePrice : money(amount),
                    style: sans(
                      size: 13,
                      weight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: sans(
                        size: 10,
                        weight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              Icon(Icons.chevron_left, size: 18, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  final String? action;
  final VoidCallback? onAction;
  const _Message({
    required this.icon,
    required this.text,
    this.color,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: color ?? Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: sans(size: 12, color: color ?? Colors.grey.shade600),
          ),
          if (action != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onAction,
              child: Text(action!, style: sans(size: 12)),
            ),
          ],
        ],
      ),
    ),
  );
}
