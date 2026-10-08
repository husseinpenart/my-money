import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_event.dart';
import 'package:money/feature/auth/presentation/bloc/contact/contact_state.dart';
import 'package:money/feature/model/contact/contact_model.dart';
import 'package:money/helper/utils/input_utils.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

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
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: ContactFormSheet(contact: contact),
    ),
  );
}

enum _Mode { manual, phone }

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
  _Mode _mode = _Mode.manual;
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
    final phone = normalizePhone(_phone.text);
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

    return BlocListener<ContactBloc, ContactState>(
      // وقتی عملیات تمام شد: موفق → بستن شیت | خطا → نمایش داخل شیت
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
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
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
              _isEdit ? 'ویرایش مخاطب' : 'مخاطب جدید',
              style: sans(size: 16, weight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            if (!_isEdit)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ModeToggle(
                  mode: _mode,
                  onChanged: (m) => setState(() {
                    _mode = m;
                    _error = null;
                  }),
                ),
              ),
            const SizedBox(height: 14),
            if (_mode == _Mode.manual)
              _buildManualForm()
            else
              SizedBox(
                height: media.size.height * 0.6,
                child: const _PhoneImportView(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualForm() {
    return Padding(
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
              decoration: _decoration('نام مخاطب', Icons.person_outline),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'نام را وارد کن' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              style: sans(size: 14),
              decoration: _decoration('شماره تماس', Icons.phone_outlined),
              validator: (v) {
                final p = normalizePhone(v ?? '');
                if (p.isEmpty) return 'شماره تماس را وارد کن';
                if (!isValidPhone(p)) return 'شماره تماس معتبر نیست';
                return null;
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
                          _isEdit ? 'ذخیره تغییرات' : 'ثبت مخاطب',
                          style: sans(size: 14, weight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
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

// ───────────────────── تاگل حالت ─────────────────────
class _ModeToggle extends StatelessWidget {
  final _Mode mode;
  final ValueChanged<_Mode> onChanged;
  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget item(String text, IconData icon, _Mode m) {
      final selected = mode == m;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(m),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? kAccent : Colors.grey.shade500,
                ),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: sans(
                    size: 12,
                    weight: selected ? FontWeight.bold : null,
                    color: selected ? kAccent : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          item('ثبت دستی', Icons.edit_outlined, _Mode.manual),
          item('از مخاطبین گوشی', Icons.contacts_outlined, _Mode.phone),
        ],
      ),
    );
  }
}

// ───────────────────── ایمپورت از مخاطبین گوشی ─────────────────────
class _PhoneImportView extends StatefulWidget {
  const _PhoneImportView();

  @override
  State<_PhoneImportView> createState() => _PhoneImportViewState();
}

class _PhoneImportViewState extends State<_PhoneImportView> {
  bool _loading = true;
  bool _denied = false;
  String? _loadError;
  List<PhoneEntry> _all = [];
  final Set<String> _selected = {};
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _denied = false;
      _loadError = null;
    });

    try {
      // ۱. درخواست دسترسی با متد نسخه جدید
      final status = await FlutterContacts.permissions.request(
        PermissionType.read,
      );
      final granted = status == PermissionStatus.granted;

      if (!granted) {
        if (mounted) {
          setState(() {
            _loading = false;
            _denied = true;
          });
        }
        return;
      }

      // ۲. دریافت مخاطبین با متد نسخه جدید (getAll به‌جای getContacts)
      // ۲. دریافت مخاطبین با فیلد شماره تلفن
      final contacts = await FlutterContacts.getAll(
        properties: {ContactProperty.phone},
      );

      final map = <String, PhoneEntry>{};
      for (final c in contacts) {
        for (final p in c.phones) {
          final phone = normalizePhone(p.number);
          if (!isValidPhone(phone) || map.containsKey(phone)) continue;
          final name = (c.displayName ?? '').trim();
          map[phone] = PhoneEntry(
            name: name.isEmpty ? phone : name,
            phoneNumber: phone,
          );
        }
      }

      final list = map.values.toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      if (mounted) {
        setState(() {
          _all = list;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = 'خواندن مخاطبین گوشی ناموفق بود';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: kAccent));
    }

    if (_denied || _loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 40, color: Colors.grey.shade400),
              const SizedBox(height: 10),
              Text(
                _denied
                    ? 'دسترسی به مخاطبین داده نشده است.\nاز تنظیمات دستگاه اجازه‌ی دسترسی بده و دوباره تلاش کن.'
                    : _loadError!,
                textAlign: TextAlign.center,
                style: sans(size: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _load,
                child: Text('تلاش دوباره', style: sans(size: 12)),
              ),
            ],
          ),
        ),
      );
    }

    return BlocBuilder<ContactBloc, ContactState>(
      builder: (context, state) {
        final existing = state.items
            .map((c) => normalizePhone(c.phoneNumber))
            .toSet();

        final q = normalizeDigits(_query.trim().toLowerCase());
        final filtered = q.isEmpty
            ? _all
            : _all
                  .where(
                    (e) =>
                        e.name.toLowerCase().contains(q) ||
                        e.phoneNumber.contains(q),
                  )
                  .toList();

        final selectable = filtered
            .where((e) => !existing.contains(e.phoneNumber))
            .toList();
        final allSelected =
            selectable.isNotEmpty &&
            selectable.every((e) => _selected.contains(e.phoneNumber));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                style: sans(size: 13),
                decoration: InputDecoration(
                  hintText: 'جستجو در مخاطبین گوشی',
                  hintStyle: sans(size: 13, color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search, color: kAccent),
                  isDense: true,
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
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Checkbox(
                    value: allSelected,
                    activeColor: kAccent,
                    onChanged: selectable.isEmpty
                        ? null
                        : (v) => setState(() {
                            for (final e in selectable) {
                              v == true
                                  ? _selected.add(e.phoneNumber)
                                  : _selected.remove(e.phoneNumber);
                            }
                          }),
                  ),
                  Text('انتخاب همه', style: sans(size: 12)),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '${filtered.length} مخاطب',
                      style: sans(size: 11, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'مخاطبی پیدا نشد',
                        style: sans(size: 12, color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final e = filtered[i];
                        final isExisting = existing.contains(e.phoneNumber);
                        final checked = _selected.contains(e.phoneNumber);

                        return CheckboxListTile(
                          dense: true,
                          value: isExisting ? true : checked,
                          activeColor: kAccent,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: isExisting
                              ? null
                              : (v) => setState(() {
                                  v == true
                                      ? _selected.add(e.phoneNumber)
                                      : _selected.remove(e.phoneNumber);
                                }),
                          title: Text(e.name, style: sans(size: 13)),
                          subtitle: Text(
                            e.phoneNumber,
                            style: sans(size: 11, color: Colors.grey.shade600),
                          ),
                          secondary: isExisting
                              ? Text(
                                  'ثبت‌شده',
                                  style: sans(
                                    size: 10,
                                    color: Colors.grey.shade500,
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: (_selected.isEmpty || state.isSubmitting)
                      ? null
                      : () {
                          final entries = _all
                              .where((e) => _selected.contains(e.phoneNumber))
                              .toList();
                          context.read<ContactBloc>().add(
                            ContactsImported(entries),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state.isSubmitting
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${state.importDone} / ${state.importTotal}',
                              style: sans(size: 13),
                            ),
                          ],
                        )
                      : Text(
                          _selected.isEmpty
                              ? 'مخاطبی انتخاب نشده'
                              : 'افزودن ${_selected.length} مخاطب',
                          style: sans(size: 14, weight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
