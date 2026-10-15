import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_event.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_state.dart';
import 'package:money/feature/model/contact/contact_model.dart';
import 'package:money/screens/contact_details_sheet.dart';
import 'package:money/widgets/contact/contact_card.dart';
import 'package:money/widgets/contact/contact_form_sheet.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/global/app_search_field.dart';
import 'package:money/widgets/global/sync_bar.dart';
import 'package:money/widgets/report/report_format.dart';

class ContactListView extends StatefulWidget {
  const ContactListView({super.key});

  @override
  State<ContactListView> createState() => _ContactListViewState();
}

class _ContactListViewState extends State<ContactListView> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.hasClients &&
        _scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      context.read<ContactBloc>().add(const ContactsLoadMore());
    }
  }

  Future<void> _refresh() {
    final done = Completer<void>();
    context.read<ContactBloc>().add(ContactsRefreshed(done: done));
    return done.future;
  }

  void _clearAll() {
    _search.clear();
    final bloc = context.read<ContactBloc>();
    bloc.add(const ContactQueryChanged(''));
    bloc.add(const ContactFilterChanged(ContactFilter.all));
  }

  Future<void> _open(ContactModel c) async {
    final changed = await showContactDetails(context, c);
    if (changed == true && mounted) {
      context.read<ContactBloc>().add(const ContactsRefreshed());
    }
  }

  Future<void> _confirmDelete(ContactModel c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'حذف طرف حساب',
          style: sans(size: 15, weight: FontWeight.bold),
        ),
        content: Text(
          'آیا از حذف «${c.name}» مطمئن هستی؟\nطرف حسابی که طلب یا بدهی ثبت‌شده دارد حذف نمی‌شود.',
          style: sans(size: 13),
        ),
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
    if (ok == true && mounted) {
      context.read<ContactBloc>().add(ContactDeleted(c.contactId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<ContactBloc, ContactState>(
          buildWhen: (p, c) => p.stats != c.stats || p.filter != c.filter,
          builder: (context, s) => _StatTiles(state: s),
        ),
        const SizedBox(height: 12),
        BlocBuilder<ContactBloc, ContactState>(
          buildWhen: (p, c) => p.isRefreshing != c.isRefreshing,
          builder: (context, s) => AppSearchField(
            controller: _search,
            autofocus: false,
            hintText: 'جستجوی نام، شماره یا توضیحات...',
            isLoading: s.isRefreshing && s.query.isNotEmpty,
            onChanged: (v) =>
                context.read<ContactBloc>().add(ContactQueryChanged(v)),
          ),
        ),
        const SizedBox(height: 10),
        BlocBuilder<ContactBloc, ContactState>(
          buildWhen: (p, c) =>
              p.totalItems != c.totalItems ||
              p.sort != c.sort ||
              p.status != c.status ||
              p.hasActiveFilter != c.hasActiveFilter,
          builder: (context, s) => _Toolbar(state: s, onClear: _clearAll),
        ),
        BlocBuilder<ContactBloc, ContactState>(
          buildWhen: (p, c) => p.isRefreshing != c.isRefreshing,
          builder: (context, s) => AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: s.isRefreshing ? 1 : 0,
            child: const LinearProgressIndicator(minHeight: 2, color: kAccent),
          ),
        ),
        const SizedBox(height: 6),
        BlocBuilder<ContactBloc, ContactState>(
          buildWhen: (p, c) =>
              p.lastSyncedAt != c.lastSyncedAt ||
              p.isRefreshing != c.isRefreshing,
          builder: (context, s) => SyncBar(
            syncedAt: s.lastSyncedAt,
            busy: s.isRefreshing,
            onRefresh: () =>
                context.read<ContactBloc>().add(const ContactsRefreshed()),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: BlocBuilder<ContactBloc, ContactState>(
            buildWhen: (p, c) =>
                p.status != c.status ||
                p.items != c.items ||
                p.isLoadingMore != c.isLoadingMore ||
                p.hasMore != c.hasMore ||
                p.error != c.error ||
                p.hasActiveFilter != c.hasActiveFilter,
            builder: (context, s) => _body(s),
          ),
        ),
      ],
    );
  }

  Widget _body(ContactState s) {
    if (s.status == ContactsStatus.initial ||
        (s.status == ContactsStatus.loading && s.items.isEmpty)) {
      return const _Skeleton();
    }
    if (s.status == ContactsStatus.failure && s.items.isEmpty) {
      return _Message(
        icon: Icons.error_outline,
        text: s.error ?? 'خطا در دریافت طرف حساب',
        actionLabel: 'تلاش دوباره',
        onAction: () =>
            context.read<ContactBloc>().add(const ContactsRefreshed()),
      );
    }
    if (s.items.isEmpty) {
      return s.hasActiveFilter
          ? _Message(
              icon: Icons.search_off_rounded,
              text: 'طرف حسابی با این جستجو یا فیلتر پیدا نشد',
              actionLabel: 'پاک کردن جستجو و فیلتر',
              onAction: _clearAll,
            )
          : _Message(
              icon: Icons.contacts_outlined,
              text: 'هنوز طرف حسابی ثبت نکرده‌ای',
              actionLabel: 'افزودن طرف حساب',
              onAction: () => showContactFormSheet(context),
            );
    }
    return RefreshIndicator(
      color: kAccent,
      onRefresh: _refresh,
      child: ListView.separated(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(2, 6, 2, 100),
        itemCount: s.items.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          if (i >= s.items.length) return _footer(s);
          final c = s.items[i];
          return ContactCard(
            key: ValueKey(c.contactId),
            contact: c,
            onOpen: () => _open(c),
            onEdit: () => showContactFormSheet(context, contact: c),
            onDelete: () => _confirmDelete(c),
          );
        },
      ),
    );
  }

  Widget _footer(ContactState s) {
    if (s.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: kAccent),
          ),
        ),
      );
    }
    if (s.hasMore) {
      return Center(
        child: TextButton(
          onPressed: () =>
              context.read<ContactBloc>().add(const ContactsLoadMore()),
          child: Text('نمایش بیشتر', style: sans(size: 12, color: kAccent)),
        ),
      );
    }
    if (s.items.length > 5) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Text(
            'همه‌ی طرف حساب نمایش داده شد',
            style: sans(size: 11, color: Colors.grey.shade500),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _StatTiles extends StatelessWidget {
  final ContactState state;
  const _StatTiles({required this.state});

  @override
  Widget build(BuildContext context) {
    final st = state.stats;
    String n(int? v) => v == null ? '—' : fa('$v');

    Widget tile(String label, String value, Color c, ContactFilter f) {
      final selected = state.filter == f;
      return Expanded(
        child: GestureDetector(
          onTap: () => context.read<ContactBloc>().add(
            ContactFilterChanged(selected ? ContactFilter.all : f),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? c.withValues(alpha: 0.16)
                  : c.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? c : c.withValues(alpha: 0.18),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  value,
                  style: sans(size: 16, weight: FontWeight.bold, color: c),
                ),
                const SizedBox(height: 3),
                Text(label, style: sans(size: 11, color: c)),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tile('همه', n(st?.total), const Color(0xFF396EEC), ContactFilter.all),
        tile(
          'طلبکار',
          n(st?.demanders),
          const Color(0xFF10B981),
          ContactFilter.demander,
        ),
        tile(
          'بدهکار',
          n(st?.debtors),
          const Color(0xFFEF4444),
          ContactFilter.debtor,
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  final ContactState state;
  final VoidCallback onClear;
  const _Toolbar({required this.state, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final loaded = state.status == ContactsStatus.success;
    return Row(
      children: [
        Text(
          loaded ? '${fa('${state.totalItems}')} طرف حساب' : '',
          style: sans(
            size: 12,
            weight: FontWeight.w600,
            color: Colors.blueGrey.shade700,
          ),
        ),
        if (state.hasActiveFilter)
          TextButton(
            onPressed: onClear,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(
              'پاک کردن فیلترها',
              style: sans(size: 11, color: Colors.red.shade400),
            ),
          ),
        const Spacer(),
        PopupMenuButton<ContactSort>(
          tooltip: 'مرتب‌سازی',
          initialValue: state.sort,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onSelected: (v) =>
              context.read<ContactBloc>().add(ContactSortChanged(v)),
          itemBuilder: (_) => [
            for (final s in ContactSort.values)
              PopupMenuItem(
                value: s,
                child: Row(
                  children: [
                    Icon(
                      s == state.sort ? Icons.check_rounded : null,
                      size: 18,
                      color: kAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(s.label, style: sans(size: 13)),
                  ],
                ),
              ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.swap_vert_rounded, size: 18, color: kAccent),
                const SizedBox(width: 4),
                Text(
                  state.sort.label,
                  style: sans(
                    size: 12,
                    weight: FontWeight.w600,
                    color: kAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEFF4),
        borderRadius: BorderRadius.circular(6),
      ),
    );

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 0),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEEF0F4)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEFF4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bar(120, 14),
                    const SizedBox(height: 8),
                    bar(80, 10),
                  ],
                ),
                const Spacer(),
                bar(60, 14),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F8),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: Colors.grey.shade300),
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
      ),
    );
  }
}
