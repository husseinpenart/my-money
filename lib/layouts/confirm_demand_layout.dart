import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/feature/auth/presentation/bloc/DebtReceviable/debt_form_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/DebtReceviable/debt_form_event.dart';
import 'package:money/feature/auth/presentation/bloc/DebtReceviable/debt_form_state.dart';
import 'package:money/feature/model/DebtReceviable/cover_image.dart';
import 'package:money/feature/model/DebtReceviable/debt_form_data.dart';
import 'package:money/feature/model/search_models/search_models.dart';
import 'package:money/helper/utils/number_helper.dart';
import 'package:money/helper/utils/thousands_formatter.dart';
import 'package:money/widgets/DebtReceviable/contact_picker_field.dart';
import 'package:money/widgets/DebtReceviable/cover_gallery_field.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/forms/top_button_filter.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

/// خروجی: true یعنی با موفقیت ثبت/ویرایش شد (لیست را رفرش کن)
Future<bool?> showDebtFormSheet(
  BuildContext context, {
  bool hasDebt = false,
  SearchDebt? initial, // برای ویرایش
  SearchContact? initialContact, // انتخاب از قبل طرف حساب
  bool editTitle = false, // 👈 جدید: عنوان ویرایش بدون initial
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => BlocProvider(
      create: (_) => GetIt.I<DebtFormBloc>(),
      child: ConfirmDemandLayout(
        hasDebt: hasDebt,
        initial: initial,
        initialContact: initialContact,
        editTitle: editTitle || initial != null,
      ),
    ),
  );
}

const _borderColor = Color.fromARGB(255, 211, 205, 205);

class ConfirmDemandLayout extends StatefulWidget {
  final bool hasDebt;
  final bool editTitle;
  final SearchDebt? initial;
  final SearchContact? initialContact;

  const ConfirmDemandLayout({
    super.key,
    required this.hasDebt,
    this.editTitle = false,
    this.initial,
    this.initialContact,
  });

  @override
  State<ConfirmDemandLayout> createState() => _ConfirmDemandLayoutState();
}

class _ConfirmDemandLayoutState extends State<ConfirmDemandLayout> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _price = TextEditingController();
  final _desc = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  late final CoverController _covers;

  late bool _isDemand;
  SearchContact? _contact;
  String? _contactError;
  Jalali? _start;
  Jalali? _end;
  bool _paid = false;
  bool _starred = false;
  String? _serverError;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final d = widget.initial;

    _isDemand = d != null ? !d.isDebt : !widget.hasDebt;

    if (d != null) {
      _contact = SearchContact(
        contactId: d.contactId,
        name: d.contactName,
        phoneNumber: d.contactPhoneNumber,
        createdAt: null,
        debts: const [],
      );
      _price.text = ThousandsInputFormatter.format(d.wholePrice);
      _desc.text = d.description ?? '';
      _paid = d.payStatus;
      _starred = d.isStarred;
      if (d.registerdDate != null) {
        _start = Jalali.fromDateTime(d.registerdDate!);
      }
      if (d.endedDate != null) _end = Jalali.fromDateTime(d.endedDate!);
    } else {
      _contact = widget.initialContact;
    }

    _start ??= Jalali.now();
    _phone.text = _contact?.phoneNumber ?? '';
    _startCtrl.text = _fmt(_start);
    _endCtrl.text = _fmt(_end);

    final covers = d?.covers ?? const <String>[];
    _covers = CoverController([
      for (var i = 0; i < covers.length; i++)
        CoverImage(
          id: 'remote_$i',
          name: covers[i].split('/').last,
          url: covers[i],
        ),
    ]);
  }

  @override
  void dispose() {
    _phone.dispose();
    _price.dispose();
    _desc.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _covers.dispose();
    super.dispose();
  }

  String _fmt(Jalali? j) => j == null
      ? ''
      : NumberHelper.toPersianDigits(
          '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}',
        );

  DateTime _toUtcNoon(Jalali j) {
    final d = j.toDateTime();
    return DateTime.utc(d.year, d.month, d.day, 12);
  }

  Future<void> _pickDate({required bool isStart}) async {
    FocusScope.of(context).unfocus();
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: (isStart ? _start : _end) ?? _start ?? Jalali.now(),
      firstDate: Jalali(1400, 1),
      lastDate: Jalali(1450, 12),
      initialEntryMode: PersianDatePickerEntryMode.calendar,
      initialDatePickerMode: PersianDatePickerMode.day,
      locale: const Locale('fa', 'IR'),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        _startCtrl.text = _fmt(picked);
      } else {
        _end = picked;
        _endCtrl.text = _fmt(picked);
      }
    });
    _formKey.currentState?.validate();
  }

  void _submit() {
    final formOk = _formKey.currentState!.validate();
    setState(() {
      _contactError = _contact == null ? 'طرف حساب را انتخاب کن' : null;
      _serverError = null;
    });
    if (!formOk || _contact == null) return;

    final data = DebtFormData(
      payId: widget.initial?.payId,
      contactId: _contact!.contactId,
      recordType: _isDemand ? 'Receivable' : 'Debt',
      wholePrice: ThousandsInputFormatter.digitsOnly(_price.text),
      registerdDate: _toUtcNoon(_start!),
      endedDate: _toUtcNoon(_end!),
      description: _desc.text,
      payStatus: _paid,
      isStarred: _starred,
      newCovers: _covers.locals,
    );
    context.read<DebtFormBloc>().add(DebtSubmitted(data));
  }

  Widget _label(String t) =>
      Text(t, style: sans(size: 12, color: Colors.grey[500]));

  InputDecoration _dec({required String hint, required IconData icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: sans(size: 12, color: _borderColor),
        errorStyle: sans(size: 11),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: _isDemand
                ? const Color.fromRGBO(37, 99, 235, 1)
                : const Color.fromRGBO(239, 68, 68, 1),
            width: 1.5,
          ),
        ),
      );

  Widget _section(String label, Widget field) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_label(label), const SizedBox(height: 8), field],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final accent = _isDemand
        ? const Color.fromRGBO(37, 99, 235, 1)
        : const Color.fromRGBO(239, 68, 68, 1);

    return BlocListener<DebtFormBloc, DebtFormState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == DebtFormStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green.shade600,
              content: Text(
                state.message ?? '',
                style: sans(size: 13, color: Colors.white),
              ),
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state.status == DebtFormStatus.failure) {
          setState(() => _serverError = state.message);
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
                Expanded(
                  child: Text(
                    widget.editTitle
                        ? ScreenDictionary.informEdit
                        : _isDemand
                        ? ScreenDictionary.informTitle
                        : ScreenDictionary.informNewDebt,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'sans', fontSize: 17),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(thickness: 0.5, height: 1),
            const SizedBox(height: 12),

            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TopButtonFilter(
                        isDemand: _isDemand,
                        isDebt: !_isDemand,
                        onDemandTap: () => setState(() => _isDemand = true),
                        onDebtTap: () => setState(() => _isDemand = false),
                      ),

                      _section(
                        ScreenDictionary.labelName,
                        ContactPickerField(
                          value: _contact,
                          errorText: _contactError,
                          onSelected: (c) => setState(() {
                            _contact = c;
                            _contactError = null;
                            _phone.text = c.phoneNumber;
                          }),
                        ),
                      ),

                      _section(
                        ScreenDictionary.labelMobile,
                        TextFormField(
                          controller: _phone,
                          readOnly: true,
                          style: sans(size: 14),
                          decoration: _dec(
                            hint: ScreenDictionary.placeholderMobile,
                            icon: Icons.phone,
                          ),
                        ),
                      ),

                      _section(
                        ScreenDictionary.labelPrice,
                        TextFormField(
                          controller: _price,
                          keyboardType: TextInputType.number,
                          inputFormatters: [ThousandsInputFormatter()],
                          style: sans(size: 14),
                          decoration: _dec(
                            hint: ScreenDictionary.placeholderPrice,
                            icon: Icons.credit_card,
                          ),
                          validator: (v) {
                            final digits = ThousandsInputFormatter.digitsOnly(
                              v ?? '',
                            );
                            if (digits.isEmpty) return 'مبلغ را وارد کن';
                            if (int.tryParse(digits) == 0) {
                              return 'مبلغ باید بیشتر از صفر باشد';
                            }
                            return null;
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label(ScreenDictionary.initialRegisterDate),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _startCtrl,
                                    readOnly: true,
                                    onTap: () => _pickDate(isStart: true),
                                    style: sans(size: 14),
                                    decoration: _dec(
                                      hint: 'انتخاب تاریخ',
                                      icon: Icons.calendar_month,
                                    ),
                                    validator: (v) => (v == null || v.isEmpty)
                                        ? 'تاریخ را انتخاب کن'
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label(ScreenDictionary.endPaymentDate),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _endCtrl,
                                    readOnly: true,
                                    onTap: () => _pickDate(isStart: false),
                                    style: sans(size: 14),
                                    decoration: _dec(
                                      hint: 'انتخاب تاریخ',
                                      icon: Icons.calendar_month,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'تاریخ را انتخاب کن';
                                      }
                                      if (_start != null &&
                                          _end != null &&
                                          _end!.toDateTime().isBefore(
                                            _start!.toDateTime(),
                                          )) {
                                        return 'قبل از تاریخ شروع است';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      _section(
                        ScreenDictionary.labelNote,
                        TextFormField(
                          controller: _desc,
                          minLines: 2,
                          maxLines: 4,
                          keyboardType: TextInputType.multiline,
                          style: sans(size: 14),
                          decoration: _dec(
                            hint: ScreenDictionary.placeholderNote,
                            icon: Icons.create_outlined,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: CoverGalleryField(controller: _covers),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: SwitchListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                activeColor: accent,
                                value: _paid,
                                onChanged: (v) => setState(() => _paid = v),
                                title: Text(
                                  'پرداخت‌شده',
                                  style: sans(size: 13),
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'ستاره‌دار',
                              onPressed: () =>
                                  setState(() => _starred = !_starred),
                              icon: Icon(
                                _starred ? Icons.star : Icons.star_border,
                                color: _starred ? Colors.amber : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_serverError != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _serverError!,
                            style: sans(size: 12, color: Colors.red.shade400),
                          ),
                        ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: BlocBuilder<DebtFormBloc, DebtFormState>(
                buildWhen: (p, c) => p.status != c.status,
                builder: (context, state) {
                  final busy = state.status == DebtFormStatus.submitting;
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: busy ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              ScreenDictionary.saveDemmandButton,
                              style: sans(size: 13, color: Colors.white),
                            ),
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
