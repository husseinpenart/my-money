import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/budget/budget_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/budget/budget_event.dart';
import 'package:money/feature/auth/presentation/bloc/budget/budget_state.dart';
import 'package:money/feature/model/budget/budget_models.dart';
import 'package:money/helper/utils/thousands_formatter.dart';
import 'package:money/widgets/budget/budget_widgets.dart';
import 'package:money/widgets/contact/contact_style.dart';
import 'package:money/widgets/report/report_format.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

Future<void> _show(BuildContext context, Widget child) {
  final bloc = context.read<BudgetBloc>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => BlocProvider.value(value: bloc, child: child),
  );
}

Future<void> showProfileSheet(BuildContext c, SalaryProfile? p) =>
    _show(c, _ProfileSheet(profile: p));

Future<void> showSalaryConfirmSheet(
  BuildContext c, {
  required double expected,
  required int cycleKey,
  bool late = false,
}) => _show(
  c,
  _SalaryConfirmSheet(expected: expected, cycleKey: cycleKey, late: late),
);

Future<void> showItemSheet(
  BuildContext c, {
  BudgetItem? item,
  required int curKey,
}) => _show(c, _ItemSheet(item: item, curKey: curKey));

Future<void> showExpenseSheet(
  BuildContext c, {
  required List<BudgetItem> items,
  String? itemId,
  double? amount,
}) => _show(c, _ExpenseSheet(items: items, itemId: itemId, amount: amount));

InputDecoration _dec(String label, IconData icon, {String? suffix}) =>
    InputDecoration(
      labelText: label,
      suffixText: suffix,
      labelStyle: sans(size: 13, color: Colors.grey.shade600),
      prefixIcon: Icon(icon, color: kAccent, size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      errorStyle: sans(size: 11),
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
    );

String? _amountValidator(String? v) {
  final d = ThousandsInputFormatter.digitsOnly(v ?? '');
  if (d.isEmpty) return 'مبلغ را وارد کن';
  if ((int.tryParse(d) ?? 0) <= 0) return 'مبلغ باید بیشتر از صفر باشد';
  return null;
}

double _amount(String text) =>
    double.parse(ThousandsInputFormatter.digitsOnly(text));

String _fmtJ(Jalali j) => fa(
  '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}',
);

// ───────────────────── قاب مشترک ─────────────────────
class _Frame extends StatefulWidget {
  final String title, submitLabel;
  final GlobalKey<FormState> formKey;
  final Widget child;

  /// می‌تواند async باشد (مثلاً تأیید مبلغ بزرگ)
  final FutureOr<void> Function() onSubmit;
  const _Frame({
    required this.title,
    required this.submitLabel,
    required this.formKey,
    required this.child,
    required this.onSubmit,
  });

  @override
  State<_Frame> createState() => _FrameState();
}

class _FrameState extends State<_Frame> {
  String? _error;

  Future<void> _go() async {
    if (!widget.formKey.currentState!.validate()) return;
    setState(() => _error = null);
    await widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return BlocListener<BudgetBloc, BudgetState>(
      listenWhen: (p, c) => p.isSubmitting && !c.isSubmitting,
      listener: (context, s) {
        final fb = s.feedback;
        if (fb == null) return;
        if (fb.isError) {
          setState(() => _error = fb.message);
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.92),
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
                      widget.title,
                      textAlign: TextAlign.center,
                      style: sans(size: 16, weight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(key: widget.formKey, child: widget.child),
              ),
            ),
            if (_error != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: BlocBuilder<BudgetBloc, BudgetState>(
                buildWhen: (p, c) => p.isSubmitting != c.isSubmitting,
                builder: (context, s) => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: s.isSubmitting ? null : _go,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: s.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.submitLabel,
                            style: sans(size: 14, weight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────── تنظیم حقوق ─────────────────────
class _ProfileSheet extends StatefulWidget {
  final SalaryProfile? profile;
  const _ProfileSheet({required this.profile});

  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  final _key = GlobalKey<FormState>();
  late final _title = TextEditingController(
    text: widget.profile?.title ?? 'حقوق',
  );
  late final _amountC = TextEditingController(
    text: widget.profile == null
        ? ''
        : ThousandsInputFormatter.format(
            widget.profile!.amount.round().toString(),
          ),
  );
  late final _day = TextEditingController(
    text: '${widget.profile?.payDay ?? 1}',
  );

  @override
  void dispose() {
    _title.dispose();
    _amountC.dispose();
    _day.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Frame(
      title: 'تنظیم حقوق',
      submitLabel: 'ذخیره',
      formKey: _key,
      onSubmit: () => context.read<BudgetBloc>().add(
        BudgetProfileSaved(
          SalaryProfile(
            title: _title.text.trim().isEmpty ? 'حقوق' : _title.text.trim(),
            amount: _amount(_amountC.text),
            payDay: int.parse(ThousandsInputFormatter.digitsOnly(_day.text)),
          ),
        ),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: _title,
            style: sans(size: 14),
            decoration: _dec('عنوان درآمد', Icons.work_outline),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _amountC,
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsInputFormatter()],
            style: sans(size: 14),
            decoration: _dec('مبلغ حقوق ماهانه', Icons.payments_outlined),
            validator: _amountValidator,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _day,
            keyboardType: TextInputType.number,
            style: sans(size: 14),
            decoration: _dec(
              'روز دریافت حقوق در ماه (۱ تا ۳۱)',
              Icons.event_outlined,
            ),
            validator: (v) {
              final d = int.tryParse(
                ThousandsInputFormatter.digitsOnly(v ?? ''),
              );
              return (d == null || d < 1 || d > 31)
                  ? 'عددی بین ۱ تا ۳۱ وارد کن'
                  : null;
            },
          ),
          const SizedBox(height: 8),
          Text(
            'این روز «موعد» حقوق است. اگر حقوق دیرتر یا زودتر رسید، موقع ثبت تاریخ واقعی را وارد می‌کنی و مرز دوره‌ها خودکار تنظیم می‌شود. اگر ماهی این روز را نداشته باشد، آخرین روز آن ماه حساب می‌شود.',
            style: sans(size: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ───────────────────── ثبت حقوق (مبلغ + تاریخ واقعی) ─────────────────────
class _SalaryConfirmSheet extends StatefulWidget {
  final double expected;
  final int cycleKey;
  final bool late;
  const _SalaryConfirmSheet({
    required this.expected,
    required this.cycleKey,
    required this.late,
  });

  @override
  State<_SalaryConfirmSheet> createState() => _SalaryConfirmSheetState();
}

class _SalaryConfirmSheetState extends State<_SalaryConfirmSheet> {
  final _key = GlobalKey<FormState>();
  late final _c = TextEditingController(
    text: ThousandsInputFormatter.format(widget.expected.round().toString()),
  );
  final _dateC = TextEditingController();
  Jalali _date = Jalali.now();

  @override
  void initState() {
    super.initState();
    _dateC.text = _fmtJ(_date);
  }

  @override
  void dispose() {
    _c.dispose();
    _dateC.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    FocusScope.of(context).unfocus();
    final now = Jalali.now();
    final p = await showPersianDatePicker(
      context: context,
      initialDate: _date,
      firstDate: now.addDays(-40),
      lastDate: now, // تاریخ آینده مجاز نیست
      initialEntryMode: PersianDatePickerEntryMode.calendar,
      initialDatePickerMode: PersianDatePickerMode.day,
      locale: const Locale('fa', 'IR'),
    );
    if (p == null) return;
    setState(() {
      _date = p;
      _dateC.text = _fmtJ(p);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _Frame(
      title: widget.late ? 'ثبت حقوقِ دیرکرده' : 'حقوق دریافت‌شده',
      submitLabel: 'ثبت حقوق',
      formKey: _key,
      onSubmit: () {
        final d = _date.toDateTime();
        context.read<BudgetBloc>().add(
          BudgetSalaryConfirmed(
            amount: _amount(_c.text),
            cycleKey: widget.cycleKey,
            date: DateTime.utc(d.year, d.month, d.day, 12),
          ),
        );
      },
      child: Column(
        children: [
          Text(
            'مبلغ و تاریخِ واقعیِ واریز را وارد کن. دوره‌ی مالی از همین تاریخ شروع می‌شود و خرج‌های قبل از آن به دوره‌ی قبل می‌روند. اگر مبلغ با اضافه‌کار، پاداش یا کسورات فرق دارد، همین‌جا اصلاح کن.',
            style: sans(size: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _c,
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsInputFormatter()],
            style: sans(size: 14),
            decoration: _dec('مبلغ دریافتی', Icons.payments_outlined),
            validator: _amountValidator,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _dateC,
            readOnly: true,
            onTap: _pick,
            style: sans(size: 14),
            decoration: _dec('تاریخ واریز', Icons.calendar_month_outlined),
          ),
        ],
      ),
    );
  }
}

// ───────────────────── آیتم بودجه ─────────────────────
class _ItemSheet extends StatefulWidget {
  final BudgetItem? item;
  final int curKey;
  const _ItemSheet({required this.item, required this.curKey});

  @override
  State<_ItemSheet> createState() => _ItemSheetState();
}

class _ItemSheetState extends State<_ItemSheet> {
  final _key = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.item?.name ?? '');
  late final _planned = TextEditingController(
    text: (widget.item == null || widget.item!.plannedAmount <= 0)
        ? ''
        : ThousandsInputFormatter.format(
            widget.item!.plannedAmount.round().toString(),
          ),
  );
  late final _due = TextEditingController(text: '${widget.item?.dueDay ?? 1}');
  late String _category = widget.item?.category ?? 'Other';
  late bool _fixed = widget.item?.isFixed ?? true;
  late int _freq = widget.item?.frequencyMonths ?? 1;
  late int _startKey = (widget.item != null && widget.item!.startKey > 0)
      ? widget.item!.startKey
      : widget.curKey;

  bool get _isEdit => widget.item?.itemId != null;

  @override
  void dispose() {
    _name.dispose();
    _planned.dispose();
    _due.dispose();
    super.dispose();
  }

  List<int> get _startOptions {
    final keys = <int>{
      for (var k = widget.curKey; k < widget.curKey + 12; k++) k,
      _startKey,
    }.toList()..sort();
    return keys;
  }

  void _submit() {
    final due =
        int.tryParse(ThousandsInputFormatter.digitsOnly(_due.text)) ?? 1;
    context.read<BudgetBloc>().add(
      BudgetItemSaved(
        BudgetItem(
          itemId: widget.item?.itemId,
          name: _name.text.trim(),
          category: _category,
          plannedAmount: _amount(_planned.text),
          isFixed: _fixed,
          frequencyMonths: _freq,
          startKey: _freq == 1
              ? (widget.item != null && widget.item!.startKey > 0
                    ? widget.item!.startKey
                    : widget.curKey)
              : _startKey,
          dueDay: due.clamp(1, 31),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _Frame(
      title: _isEdit ? 'ویرایش آیتم برنامه' : 'آیتم جدید برنامه',
      submitLabel: _isEdit ? 'ذخیره تغییرات' : 'افزودن به برنامه',
      formKey: _key,
      onSubmit: _submit,
      child: Column(
        children: [
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: true,
                label: Text('قبض / قسط ثابت', style: sans(size: 12)),
                icon: const Icon(Icons.event_repeat, size: 16),
              ),
              ButtonSegment(
                value: false,
                label: Text('بودجه‌ی متغیر', style: sans(size: 12)),
                icon: const Icon(Icons.tune, size: 16),
              ),
            ],
            selected: {_fixed},
            onSelectionChanged: (s) => setState(() => _fixed = s.first),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              _fixed
                  ? 'مبلغ و روز سررسید مشخص دارد؛ مثل قبض، قسط یا بیمه.'
                  : 'سقفی که برای هر دوره کنار می‌گذاری و هزینه‌ها از آن کم می‌شود؛ مثل خرید خانه یا بنزین.',
              style: sans(size: 11, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _name,
            style: sans(size: 14),
            decoration: _dec('نام (مثلاً بیمه بدنه)', Icons.label_outline),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'نام را وارد کن' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: _dec('دسته', BudgetCategory.of(_category).icon),
            items: [
              for (final c in BudgetCategory.all)
                DropdownMenuItem(
                  value: c.key,
                  child: Text(c.label, style: sans(size: 13)),
                ),
            ],
            onChanged: (v) => setState(() => _category = v ?? 'Other'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _planned,
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsInputFormatter()],
            style: sans(size: 14),
            decoration: _dec(
              _fixed ? 'مبلغ هر بار' : 'سقف هر دوره',
              Icons.payments_outlined,
            ),
            validator: _amountValidator,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _freq,
            decoration: _dec('تکرار', Icons.repeat),
            items: [
              for (final e in kFrequencies.entries)
                DropdownMenuItem(
                  value: e.key,
                  child: Text(e.value, style: sans(size: 13)),
                ),
            ],
            onChanged: (v) => setState(() => _freq = v ?? 1),
          ),
          if (_fixed) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _due,
              keyboardType: TextInputType.number,
              style: sans(size: 14),
              decoration: _dec(
                'روز سررسید در ماه (۱ تا ۳۱)',
                Icons.event_outlined,
              ),
              validator: (v) {
                final d = int.tryParse(
                  ThousandsInputFormatter.digitsOnly(v ?? ''),
                );
                return (d == null || d < 1 || d > 31)
                    ? 'عددی بین ۱ تا ۳۱ وارد کن'
                    : null;
              },
            ),
          ],
          if (_freq > 1) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _startKey,
              decoration: _dec(
                'اولین ماه سررسید',
                Icons.calendar_month_outlined,
              ),
              items: [
                for (final k in _startOptions)
                  DropdownMenuItem(
                    value: k,
                    child: Text(cycleLabel(k), style: sans(size: 13)),
                  ),
              ],
              onChanged: (v) => setState(() => _startKey = v ?? _startKey),
            ),
          ],
        ],
      ),
    );
  }
}

// ───────────────────── ثبت هزینه ─────────────────────
class _ExpenseSheet extends StatefulWidget {
  final List<BudgetItem> items;
  final String? itemId;
  final double? amount;
  const _ExpenseSheet({required this.items, this.itemId, this.amount});

  @override
  State<_ExpenseSheet> createState() => _ExpenseSheetState();
}

class _ExpenseSheetState extends State<_ExpenseSheet> {
  final _key = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _note = TextEditingController();
  final _dateC = TextEditingController();
  late final _amountC = TextEditingController(
    text: (widget.amount == null || widget.amount! <= 0)
        ? ''
        : ThousandsInputFormatter.format(widget.amount!.round().toString()),
  );
  late String? _itemId = widget.itemId;
  String _category = 'Other';
  Jalali _date = Jalali.now();

  @override
  void initState() {
    super.initState();
    _dateC.text = _fmtJ(_date);
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    _dateC.dispose();
    _amountC.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final now = Jalali.now();
    final p = await showPersianDatePicker(
      context: context,
      initialDate: _date,
      firstDate: Jalali(now.year - 2, 1, 1),
      lastDate: now, // هزینه‌ی آینده مجاز نیست
      initialEntryMode: PersianDatePickerEntryMode.calendar,
      initialDatePickerMode: PersianDatePickerMode.day,
      locale: const Locale('fa', 'IR'),
    );
    if (p == null) return;
    setState(() {
      _date = p;
      _dateC.text = _fmtJ(p);
    });
  }

  Future<void> _submit() async {
    final amt = _amount(_amountC.text);
    final bloc = context.read<BudgetBloc>();
    final plan = bloc.state.plan;

    // مبلغ بسیار بزرگ نسبت به حقوق: قبل از ثبت تأیید گرفته می‌شود
    if (plan != null && plan.salary > 0 && amt > plan.salary * 0.5) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'مبلغ بزرگ',
            style: sans(size: 15, weight: FontWeight.bold),
          ),
          content: Text(
            'مبلغ ${money(amt)} بیش از نصف حقوق این دوره است. مطمئنی درست وارد کرده‌ای؟',
            style: sans(size: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('اصلاح می‌کنم', style: sans(size: 13)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('بله، ثبت شود', style: sans(size: 13)),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }

    final d = _date.toDateTime();
    final item = widget.items.where((i) => i.itemId == _itemId).firstOrNull;
    bloc.add(
      BudgetExpenseAdded(
        itemId: _itemId,
        title: _title.text,
        note: _note.text,
        category: item?.category ?? _category,
        amount: amt,
        date: DateTime.utc(d.year, d.month, d.day, 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _Frame(
      title: 'ثبت هزینه',
      submitLabel: 'ثبت هزینه',
      formKey: _key,
      onSubmit: _submit,
      child: Column(
        children: [
          DropdownButtonFormField<String?>(
            value: _itemId,
            isExpanded: true,
            decoration: _dec('مربوط به کدام آیتم برنامه؟', Icons.link),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(
                  'بدون برنامه (هزینه‌ی متفرقه)',
                  style: sans(size: 13),
                ),
              ),
              for (final i in widget.items)
                DropdownMenuItem<String?>(
                  value: i.itemId,
                  child: Text(i.name, style: sans(size: 13)),
                ),
            ],
            onChanged: (v) => setState(() => _itemId = v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _title,
            style: sans(size: 14),
            decoration: _dec(
              _itemId == null ? 'عنوان هزینه' : 'عنوان (اختیاری)',
              Icons.edit_outlined,
            ),
            validator: (v) =>
                (_itemId == null && (v == null || v.trim().isEmpty))
                ? 'عنوان را وارد کن'
                : null,
          ),
          if (_itemId == null) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: _dec('دسته', BudgetCategory.of(_category).icon),
              items: [
                for (final c in BudgetCategory.all)
                  DropdownMenuItem(
                    value: c.key,
                    child: Text(c.label, style: sans(size: 13)),
                  ),
              ],
              onChanged: (v) => setState(() => _category = v ?? 'Other'),
            ),
          ],
          const SizedBox(height: 12),
          TextFormField(
            controller: _amountC,
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsInputFormatter()],
            style: sans(size: 14),
            decoration: _dec('مبلغ', Icons.payments_outlined),
            validator: _amountValidator,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _dateC,
            readOnly: true,
            onTap: _pickDate,
            style: sans(size: 14),
            decoration: _dec('تاریخ', Icons.calendar_month_outlined),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _note,
            minLines: 1,
            maxLines: 3,
            style: sans(size: 14),
            decoration: _dec('یادداشت (اختیاری)', Icons.notes_outlined),
          ),
        ],
      ),
    );
  }
}
