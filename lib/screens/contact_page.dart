import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_event.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_state.dart';
import 'package:money/helper/list/contact_counter.dart';
import 'package:money/widgets/contact/contact_form_sheet.dart';
import 'package:money/widgets/contact/contact_list_view.dart';
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

class _ContactView extends StatelessWidget {
  const _ContactView();

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

            // ───── لیست + سرچ + فیلتر + جزئیات ─────
            const Expanded(child: ContactListView()),
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
