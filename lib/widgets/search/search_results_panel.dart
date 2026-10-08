import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/search/search_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/search/search_event.dart';
import 'package:money/feature/auth/presentation/bloc/search/search_state.dart';
import 'package:money/feature/model/search_models/search_filter.dart';
import 'package:money/feature/model/search_models/search_models.dart';


const _accent = Color.fromARGB(255, 83, 109, 255);

class SearchResultsPanel extends StatelessWidget {
  /// وقتی روی مخاطب یا بدهی/طلب زده شد (برای ناوبری)
  final void Function(SearchContact contact)? onContactTap;
  final void Function(SearchDebt debt)? onDebtTap;

  const SearchResultsPanel({super.key, this.onContactTap, this.onDebtTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.55,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TypeTabs(state: state),
              if (state.filter.type != SearchType.contacts)
                _DebtFilters(state: state),
              const Divider(height: 1),
              Flexible(
                child: _Body(
                  state: state,
                  onContactTap: onContactTap,
                  onDebtTap: onDebtTap,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ───────────────────────── تب‌ها ─────────────────────────
class _TypeTabs extends StatelessWidget {
  final SearchState state;
  const _TypeTabs({required this.state});

  @override
  Widget build(BuildContext context) {
    String label(String t, int? count) =>
        count == null || state.status != SearchStatus.success
        ? t
        : '$t ($count)';

    final items = <(SearchType, String)>[
      (SearchType.all, 'همه'),
      (SearchType.contacts, label('مخاطبین', state.contacts.totalItems)),
      (SearchType.debts, label('بدهی و طلب', state.debts.totalItems)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          for (final (type, text) in items)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(
                  text,
                  style: const TextStyle(fontFamily: 'sans', fontSize: 12),
                ),
                selected: state.filter.type == type,
                selectedColor: _accent.withOpacity(0.15),
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

// ───────────────────────── فیلترهای بدهی/طلب ─────────────────────────
class _DebtFilters extends StatelessWidget {
  final SearchState state;
  const _DebtFilters({required this.state});

  @override
  Widget build(BuildContext context) {
    final f = state.filter;
    final bloc = context.read<SearchBloc>();

    Widget chip(String text, bool selected, VoidCallback onTap) => Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: FilterChip(
        label: Text(
          text,
          style: const TextStyle(fontFamily: 'sans', fontSize: 11),
        ),
        selected: selected,
        selectedColor: _accent.withOpacity(0.15),
        checkmarkColor: _accent,
        visualDensity: VisualDensity.compact,
        onSelected: (_) => onTap(),
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        children: [
          chip('بدهی', f.recordType == 'Debt', () {
            bloc.add(
              SearchFilterChanged(
                f.recordType == 'Debt'
                    ? f.copyWith(clearRecordType: true)
                    : f.copyWith(recordType: 'Debt'),
              ),
            );
          }),
          chip('طلب', f.recordType == 'Receivable', () {
            bloc.add(
              SearchFilterChanged(
                f.recordType == 'Receivable'
                    ? f.copyWith(clearRecordType: true)
                    : f.copyWith(recordType: 'Receivable'),
              ),
            );
          }),
          chip('پرداخت‌نشده', f.payStatus == false, () {
            bloc.add(
              SearchFilterChanged(
                f.payStatus == false
                    ? f.copyWith(clearPayStatus: true)
                    : f.copyWith(payStatus: false),
              ),
            );
          }),
          chip('پرداخت‌شده', f.payStatus == true, () {
            bloc.add(
              SearchFilterChanged(
                f.payStatus == true
                    ? f.copyWith(clearPayStatus: true)
                    : f.copyWith(payStatus: true),
              ),
            );
          }),
          chip('ستاره‌دار', f.isStarred == true, () {
            bloc.add(
              SearchFilterChanged(
                f.isStarred == true
                    ? f.copyWith(clearIsStarred: true)
                    : f.copyWith(isStarred: true),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ───────────────────────── بدنه ─────────────────────────
class _Body extends StatelessWidget {
  final SearchState state;
  final void Function(SearchContact)? onContactTap;
  final void Function(SearchDebt)? onDebtTap;

  const _Body({required this.state, this.onContactTap, this.onDebtTap});

  @override
  Widget build(BuildContext context) {
    if (state.status == SearchStatus.initial) {
      return _Message(
        icon: Icons.manage_search,
        text: 'نام، شماره یا توضیحات را جستجو کن',
      );
    }

    if (state.status == SearchStatus.loading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator(color: _accent)),
      );
    }

    if (state.status == SearchStatus.failure) {
      return _Message(
        icon: Icons.error_outline,
        text: state.error ?? 'خطا در دریافت اطلاعات',
        color: Colors.red.shade400,
      );
    }

    if (state.isEmptyResult) {
      return _Message(icon: Icons.search_off, text: 'نتیجه‌ای پیدا نشد');
    }

    return _ResultsList(
      state: state,
      onContactTap: onContactTap,
      onDebtTap: onDebtTap,
    );
  }
}

class _ResultsList extends StatefulWidget {
  final SearchState state;
  final void Function(SearchContact)? onContactTap;
  final void Function(SearchDebt)? onDebtTap;

  const _ResultsList({required this.state, this.onContactTap, this.onDebtTap});

  @override
  State<_ResultsList> createState() => _ResultsListState();
}

class _ResultsListState extends State<_ResultsList> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 120) {
      context.read<SearchBloc>().add(const SearchLoadMore());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final showContacts = s.filter.type != SearchType.debts;
    final showDebts = s.filter.type != SearchType.contacts;

    final children = <Widget>[
      if (showContacts && s.contacts.items.isNotEmpty) ...[
        _SectionTitle('مخاطبین', s.contacts.totalItems),
        for (final c in s.contacts.items)
          _ContactTile(contact: c, onTap: widget.onContactTap),
      ],
      if (showDebts && s.debts.items.isNotEmpty) ...[
        _SectionTitle('بدهی و طلب', s.debts.totalItems),
        for (final d in s.debts.items)
          _DebtTile(debt: d, onTap: widget.onDebtTap),
      ],
      if (s.isLoadingMore)
        const Padding(
          padding: EdgeInsets.all(12),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: _accent),
            ),
          ),
        ),
    ];

    return ListView(
      controller: _scroll,
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 8),
      children: children,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;
  const _SectionTitle(this.title, this.count);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Text(
      '$title ($count)',
      style: TextStyle(
        fontFamily: 'sans',
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade600,
      ),
    ),
  );
}

class _ContactTile extends StatelessWidget {
  final SearchContact contact;
  final void Function(SearchContact)? onTap;
  const _ContactTile({required this.contact, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      onTap: onTap == null ? null : () => onTap!(contact),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: _accent.withOpacity(0.12),
        child: Text(
          contact.name.isEmpty ? '?' : contact.name.characters.first,
          style: const TextStyle(
            fontFamily: 'sans',
            color: _accent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        contact.name,
        style: const TextStyle(fontFamily: 'sans', fontSize: 13),
      ),
      subtitle: Text(
        contact.phoneNumber,
        style: TextStyle(
          fontFamily: 'sans',
          fontSize: 11,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: contact.debts.isEmpty
          ? null
          : Text(
              '${contact.debts.length} مورد',
              style: TextStyle(
                fontFamily: 'sans',
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  final SearchDebt debt;
  final void Function(SearchDebt)? onTap;
  const _DebtTile({required this.debt, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = debt.isDebt ? Colors.red.shade400 : Colors.green.shade600;
    final desc = (debt.description ?? '').trim();

    return ListTile(
      dense: true,
      onTap: onTap == null ? null : () => onTap!(debt),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: color.withOpacity(0.12),
        child: Icon(
          debt.isDebt ? Icons.arrow_upward : Icons.arrow_downward,
          size: 18,
          color: color,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              debt.contactName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'sans', fontSize: 13),
            ),
          ),
          if (debt.isStarred)
            const Icon(Icons.star, size: 14, color: Colors.amber),
        ],
      ),
      subtitle: Text(
        desc.isEmpty ? (debt.isDebt ? 'بدهی' : 'طلب') : desc,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'sans',
          fontSize: 11,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            debt.wholePrice,
            style: TextStyle(
              fontFamily: 'sans',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            debt.payStatus ? 'پرداخت‌شده' : 'پرداخت‌نشده',
            style: TextStyle(
              fontFamily: 'sans',
              fontSize: 10,
              color: debt.payStatus
                  ? Colors.green.shade600
                  : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _Message({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 36, color: color ?? Colors.grey.shade400),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'sans',
            fontSize: 12,
            color: color ?? Colors.grey.shade600,
          ),
        ),
      ],
    ),
  );
}
