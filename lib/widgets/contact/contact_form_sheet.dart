import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_event.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_state.dart';
import 'package:money/feature/model/contact/contact_model.dart';
import 'package:money/helper/utils/input_utils.dart';
import 'package:money/widgets/contact/contact_style.dart';

/// [contact] != null → حالت ویرایش
Future<void> showContactFormSheet(
  BuildContext context, {
  ContactModel? contact,
}) {
  final bloc = context.read<ContactBloc>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: ContactFormSheet(contact: contact),
    ),
  );
}

class ContactFormSheet extends StatefulWidget {
  final ContactModel? contact;
  const ContactFormSheet({super.key, this.contact});

  @override
  State<ContactFormSheet> createState() => _ContactFormSheetState();
}

class _ContactFormSheetState extends State<ContactFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  String? _error;

  bool get _isEdit => widget.contact != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.contact?.name ?? '');
    _phone = TextEditingController(text: widget.contact?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);

    final name = _name.text.trim();
    final phone = normalizePhone(_phone.text); // خالی ← ''
    final bloc = context.read<ContactBloc>();

    if (_isEdit) {
      bloc.add(
        ContactUpdated(
          contactId: widget.contact!.contactId,
          name: name,
          phoneNumber: phone,
        ),
      );
    } else {
      bloc.add(ContactCreated(name: name, phoneNumber: phone));
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottom = math.max(media.viewInsets.bottom, media.padding.bottom);

    return BlocListener<ContactBloc, ContactState>(
      listenWhen: (p, c) => p.isSubmitting && !c.isSubmitting,
      listener: (context, state) {
        final fb = state.feedback;
        if (fb == null) return;
        if (fb.isError) {
          setState(() => _error = fb.message);
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        padding: EdgeInsets.only(bottom: bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 14),
              Text(
                _isEdit ? 'ویرایش طرف حساب' : 'طرف حساب جدید',
                style: sans(size: 16, weight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _name,
                        textInputAction: TextInputAction.next,
                        style: sans(size: 14),
                        decoration: _decoration(
                          'نام طرف حساب',
                          Icons.person_outline,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'نام را وارد کن'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        style: sans(size: 14),
                        decoration: _decoration(
                          'شماره تماس (اختیاری)',
                          Icons.phone_outlined,
                        ),
                        validator: (v) {
                          final p = normalizePhone(v ?? '');
                          if (p.isEmpty) return null; // اختیاری
                          return isValidPhone(p)
                              ? null
                              : 'شماره تماس معتبر نیست';
                        },
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _error!,
                            style: sans(size: 12, color: Colors.red.shade400),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      BlocBuilder<ContactBloc, ContactState>(
                        buildWhen: (p, c) => p.isSubmitting != c.isSubmitting,
                        builder: (context, state) => SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: state.isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: state.isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _isEdit ? 'ذخیره تغییرات' : 'ثبت طرف حساب',
                                    style: sans(
                                      size: 14,
                                      weight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    labelStyle: sans(size: 13, color: Colors.grey.shade600),
    prefixIcon: Icon(icon, color: kAccent),
    filled: true,
    fillColor: Colors.grey.shade50,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kAccent, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red.shade300),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
    ),
    errorStyle: sans(size: 11),
  );
}
