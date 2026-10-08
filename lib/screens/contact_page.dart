import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_event.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_state.dart';
import 'package:money/feature/model/contact/contact_model.dart';
import 'package:money/helper/list/contact_counter.dart';
import 'package:money/widgets/contact/contact_card.dart';
import 'package:money/widgets/contact/contact_form_sheet.dart';
import 'package:money/widgets/contact/contact_style.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<ContactBloc>()..add(const ContactsFetched()),
      child: const _ContactView(),
    );
  }
}

class _ContactView extends StatefulWidget {
  const _ContactView();

  @override
  State<_ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<_ContactView> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scroll.hasClients &&
        _scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      context.read<ContactBloc>().add(const ContactsLoadMore());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactBloc, ContactState>(
      listenWhen: (p, c) =>
          c.feedback != null && !identical(p.feedback, c.feedback),
      listener: (context, state) {
        final fb = state.feedback!;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: fb.isError
                  ? Colors.red.shade400
                  : Colors.green.shade600,
              content: Text(
                fb.message,
                style: sans(size: 13, color: Colors.white),
              ),
            ),
          );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ───── عنوان + دکمه افزودن ─────
            Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Text(
                    BottomNavigations.contacts,
                    textAlign: TextAlign.center,
                    style: sans(size: 20, weight: FontWeight.bold),
                  ),
                ),
                InkWell(
                  onTap: () => showContactFormSheet(context),
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: kAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ───── شمارنده‌ها ─────
            BlocBuilder<ContactBloc, ContactState>(
              buildWhen: (p, c) =>
                  p.items != c.items || p.totalItems != c.totalItems,
              builder: (context, state) => _Counters(state: state),
            ),
            const SizedBox(height: 20),

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
                      onAction: () => context.read<ContactBloc>().add(
                        const ContactsFetched(),
                      ),
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

                  return RefreshIndicator(
                    color: kAccent,
                    onRefresh: _refresh,
                    child: ListView.separated(
                      controller: _scroll,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(2, 2, 2, 24),
                      itemCount:
                          state.items.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) {
                        if (i >= state.items.length) {
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
                        final c = state.items[i];
                        return ContactCard(
                          key: ValueKey(c.contactId),
                          contact: c,
                          onEdit: () =>
                              showContactFormSheet(context, contact: c),
                          onDelete: () => _confirmDelete(c),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────── شمارنده‌ها ─────────────────────
class _Counters extends StatelessWidget {
  final ContactState state;
  const _Counters({required this.state});

  @override
  Widget build(BuildContext context) {
    // شمارش «طلبکار/بدهکار» روی مخاطبین لودشده است
    final demanders = state.items.where((c) => c.hasUnpaidReceivable).length;
    final debtors = state.items.where((c) => c.hasUnpaidDebt).length;

    final items = <ContactCounter>[
      ContactCounter(
        backgroundColor: const Color.fromRGBO(239, 246, 255, 1),
        borderColor: const Color.fromRGBO(231, 236, 243, 1),
        number: '${state.totalItems}',
        numberColor: const Color.fromRGBO(57, 110, 236, 1),
        textString: BottomNavigations.contacts,
        textStringColor: const Color.fromRGBO(57, 110, 236, 1),
      ),
      ContactCounter(
        backgroundColor: const Color.fromRGBO(240, 253, 244, 1),
        borderColor: const Color.fromRGBO(234, 241, 239, 1),
        number: '$demanders',
        numberColor: const Color.fromRGBO(49, 190, 145, 1),
        textString: ScreenDictionary.demander,
        textStringColor: const Color.fromRGBO(49, 190, 145, 1),
      ),
      ContactCounter(
        backgroundColor: const Color.fromRGBO(254, 242, 242, 1),
        borderColor: const Color.fromRGBO(241, 233, 235, 1),
        number: '$debtors',
        numberColor: const Color.fromRGBO(239, 68, 68, 1),
        textString: ScreenDictionary.debtor,
        textStringColor: const Color.fromRGBO(239, 68, 68, 1),
      ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.backgroundColor,
              border: Border.all(width: 1, color: item.borderColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.number,
                  style: sans(
                    size: 15,
                    weight: FontWeight.bold,
                    color: item.numberColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.textString,
                  textAlign: TextAlign.center,
                  style: sans(size: 11, color: item.textStringColor),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _Message({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

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
