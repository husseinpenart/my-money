import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_event.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_state.dart';
import 'package:money/feature/model/contact/contact_model.dart';
import 'package:money/helper/utils/input_utils.dart';
import 'package:money/screens/contact_details_sheet.dart';
import 'package:money/widgets/contact/contact_card.dart';
import 'package:money/widgets/contact/contact_form_sheet.dart';
import 'package:money/widgets/contact/contact_style.dart';

enum ContactFilter { all, demander, debtor }

class ContactListView extends StatefulWidget {
  const ContactListView({super.key});

  @override
  State<ContactListView> createState() => _ContactListViewState();
}

class _ContactListViewState extends State<ContactListView> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  String _query = '';
  ContactFilter _filter = ContactFilter.all;

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
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.hasClients &&
        _scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      context.read<ContactBloc>().add(const ContactsLoadMore());
    }
  }

  Future<void> _refresh() {
    final done = Completer<void>();
    context.read<ContactBloc>().add(ContactsFetched(done: done));
    return done.future;
  }

  Future<void> _confirmDelete(ContactModel c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'حذف مخاطب',
          style: sans(size: 15, weight: FontWeight.bold),
        ),
        content: Text(
          'آیا از حذف «${c.name}» مطمئن هستی؟',
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

  List<ContactModel> _apply(List<ContactModel> items) {
    final q = normalizeDigits(_query.trim().toLowerCase());
    return items.where((c) {
      if (_filter == ContactFilter.demander && !c.hasUnpaidReceivable) {
        return false;
      }
      if (_filter == ContactFilter.debtor && !c.hasUnpaidDebt) return false;
      if (q.isNotEmpty) {
        final hay =
            '${normalizeDigits(c.name.toLowerCase())} ${normalizeDigits(c.phoneNumber)}';
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ───── نوار جستجو ─────
        TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _query = v),
          style: sans(size: 13),
          decoration: InputDecoration(
            hintText: 'جستجوی نام یا شماره...',
            hintStyle: sans(size: 13, color: Colors.grey.shade400),
            prefixIcon: const Icon(Icons.search, color: kAccent),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _query = '');
                    },
                  ),
            isDense: true,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kAccent, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ───── چیپ‌های فیلتر ─────
        Row(
          children: [
            _chip('همه', ContactFilter.all),
            const SizedBox(width: 8),
            _chip('طلبکار', ContactFilter.demander),
            const SizedBox(width: 8),
            _chip('بدهکار', ContactFilter.debtor),
          ],
        ),
        const SizedBox(height: 14),

        // ───── لیست ─────
        Expanded(
          child: BlocBuilder<ContactBloc, ContactState>(
            buildWhen: (p, c) =>
                p.status != c.status ||
                p.items != c.items ||
                p.isLoadingMore != c.isLoadingMore ||
                p.error != c.error,
            builder: (context, state) {
              if (state.status == ContactsStatus.initial ||
                  (state.status == ContactsStatus.loading &&
                      state.items.isEmpty)) {
                return const Center(
                  child: CircularProgressIndicator(color: kAccent),
                );
              }

              if (state.status == ContactsStatus.failure &&
                  state.items.isEmpty) {
                return _Message(
                  icon: Icons.error_outline,
                  text: state.error ?? 'خطا در دریافت مخاطبین',
                  actionLabel: 'تلاش دوباره',
                  onAction: () =>
                      context.read<ContactBloc>().add(const ContactsFetched()),
                );
              }

              if (state.items.isEmpty) {
                return _Message(
                  icon: Icons.contacts_outlined,
                  text: 'هنوز مخاطبی ثبت نکرده‌ای',
                  actionLabel: 'افزودن مخاطب',
                  onAction: () => showContactFormSheet(context),
                );
              }

              final visible = _apply(state.items);

              if (visible.isEmpty) {
                return _Message(
                  icon: Icons.filter_alt_off_outlined,
                  text: 'موردی با این جستجو/فیلتر پیدا نشد',
                );
              }

              return RefreshIndicator(
                color: kAccent,
                onRefresh: _refresh,
                child: ListView.separated(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(2, 2, 2, 24),
                  itemCount: visible.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
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
                    final c = visible[i];
                    return InkWell(
                      // 👈 tap = جزئیات حساب‌کتاب (بدون دست‌زدن به ContactCard)
                      onTap: () => showContactDetails(context, c),
                      borderRadius: BorderRadius.circular(14),
                      child: ContactCard(
                        key: ValueKey(c.contactId),
                        contact: c,
                        onEdit: () => showContactFormSheet(context, contact: c),
                        onDelete: () => _confirmDelete(c),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, ContactFilter f) {
    final selected = _filter == f;
    return ChoiceChip(
      label: Text(label, style: sans(size: 12)),
      selected: selected,
      onSelected: (_) => setState(() => _filter = f),
      selectedColor: kAccent.withValues(alpha: 0.12),
      labelStyle: sans(
        size: 12,
        color: selected ? kAccent : Colors.grey.shade600,
        weight: selected ? FontWeight.bold : null,
      ),
      showCheckmark: false,
      side: BorderSide(color: selected ? kAccent : Colors.grey.shade300),
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
