import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_event.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_state.dart';
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: [
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
            const SizedBox(height: 16),
            const Expanded(child: ContactListView()),
          ],
        ),
      ),
    );
  }
}
