import 'package:flutter/material.dart';
import 'package:money/helper/utils/colors.dart';
import 'package:money/helper/utils/number_helper.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';



const _kFont = 'sans';

class RecordPayment extends StatefulWidget {
  final String contactName;
  final String contactSubtitle;
  final String contactInitial;
  final String badgeLabel;
  final double totalAmount;
  final double paidAmount;
  final VoidCallback? onCancel;
  final void Function({
    required double amount,
    required bool fullSettlement,
    required String date,
    required String note,
  })?
  onSubmit;

  const RecordPayment({
    super.key,
    this.contactName = 'علی رضایی',
    this.contactSubtitle = 'قرض شخصی برای اجاره خانه',
    this.contactInitial = '۴',
    this.badgeLabel = 'طلبکارم',
    this.totalAmount = 4500000,
    this.paidAmount = 2000000,
    this.onCancel,
    this.onSubmit,
  });

  @override
  State<RecordPayment> createState() => _RecordPaymentState();
}

class _RecordPaymentState extends State<RecordPayment> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  bool _fullSettlement = false;

  double get _remaining => widget.totalAmount - widget.paidAmount;

  double get _progress =>
      widget.totalAmount == 0 ? 0 : widget.paidAmount / widget.totalAmount;

  @override
  void initState() {
    super.initState();
    final today = Jalali.now();
    _dateController.text = NumberHelper.toPersianDigits(
      '${today.year}/${today.month.toString().padLeft(2, '0')}/${today.day.toString().padLeft(2, '0')}',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();

    final picked = await showPersianDatePicker(
      context: context,
      initialDate: Jalali.now(),
      firstDate: Jalali(1400, 1),
      lastDate: Jalali(1450, 12),
      initialEntryMode: PersianDatePickerEntryMode.calendar,
      initialDatePickerMode: PersianDatePickerMode.day,
      locale: const Locale('fa', 'IR'),
    );

    if (picked == null) return;

    final rawDate =
        '${picked.year}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}';

    setState(() => _dateController.text = NumberHelper.toPersianDigits(rawDate));
  }

  String _money(double value) {
    final formatted = value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return NumberHelper.toPersianDigits(formatted);
  }

  void _submit() {
    final amount = _fullSettlement
        ? _remaining
        : double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;

    widget.onSubmit?.call(
      amount: amount,
      fullSettlement: _fullSettlement,
      date: _dateController.text,
      note: _noteController.text,
    );
  }

  // ---- shared style helpers -------------------------------------------

  TextStyle get _labelStyle =>
      const TextStyle(fontFamily: _kFont, fontSize: 12, color: RP.fieldLabel);

  OutlineInputBorder get _fieldBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: RP.inputBorder),
      );

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    bool filled = false,
  }) {
    return InputDecoration(
      filled: filled,
      fillColor: Colors.grey[100],
      border: _fieldBorder,
      enabledBorder: _fieldBorder,
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: _kFont,
        fontSize: 12,
        color: RP.placeholder,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      prefixIcon: Align(
        widthFactor: 1.0,
        heightFactor: 1.0,
        child: Icon(icon, size: 18, color: RP.fieldLabel),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(text, style: _labelStyle);

  // ---- sections ----------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onCancel ?? () => Navigator.maybePop(context),
            icon: const Icon(Icons.close, size: 20, color: RP.closeIcon),
          ),
          const Expanded(
            child: Text(
              'ثبت پرداخت',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: _kFont,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: RP.titleText,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: RP.iconBoxBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(Icons.credit_card, size: 20, color: RP.iconGlyph),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: RP.cardBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: RP.avatarBg,
                ),
                child: Text(
                  widget.contactInitial,
                  style: const TextStyle(
                    fontFamily: _kFont,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.contactName,
                      style: const TextStyle(
                        fontFamily: _kFont,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: RP.titleText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.contactSubtitle,
                      style: const TextStyle(
                        fontFamily: _kFont,
                        fontSize: 12,
                        color: RP.fieldLabel,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: RP.badgeBg,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  widget.badgeLabel,
                  style: const TextStyle(
                    fontFamily: _kFont,
                    fontSize: 12,
                    color: RP.badgeText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: RP.cardBorder, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _amountColumn(_money(_remaining), 'مانده', RP.amountRed,
                  CrossAxisAlignment.start),
              _amountColumn(_money(widget.paidAmount), 'پرداخت شده',
                  RP.amountGreen, CrossAxisAlignment.center),
              _amountColumn(_money(widget.totalAmount), 'مبلغ کل',
                  RP.amountBlack, CrossAxisAlignment.end),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                NumberHelper.toPersianDigits('${(_progress * 100).round()}%'),
                style: const TextStyle(
                  fontFamily: _kFont,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: RP.percentText,
                ),
              ),
              const Text(
                'وضعیت فعلی',
                style: TextStyle(
                  fontFamily: _kFont,
                  fontSize: 11,
                  color: RP.fieldLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _amountColumn(
    String value,
    String label,
    Color color,
    CrossAxisAlignment align,
  ) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: _kFont,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: _kFont,
            fontSize: 11,
            color: RP.amountLabel,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fillWidth = constraints.maxWidth * _progress.clamp(0, 1);
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 8,
            color: RP.progressTrack,
            alignment: Alignment.centerRight, // RTL: fill grows from right
            child: Container(
              width: fillWidth,
              height: 8,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [RP.progressStart, RP.progressEnd],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettlementToggle() {
    return Container(
      padding: const EdgeInsets.all(13),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: RP.cardBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              size: 20, color: RP.toggleCheckIcon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تسویه کامل',
                  style: TextStyle(
                    fontFamily: _kFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: RP.titleText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'پرداخت مانده ${_money(_remaining)} تومان',
                  style: const TextStyle(
                    fontFamily: _kFont,
                    fontSize: 11,
                    color: RP.fieldLabel,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _fullSettlement,
            activeColor: Colors.white,
            activeTrackColor: RP.switchOnTrack,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: RP.switchOffTrack,
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
            onChanged: (value) {
              setState(() {
                _fullSettlement = value;
                _amountController.text = value ? _money(_remaining) : '';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('مبلغ پرداختی (تومان)'),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            enabled: !_fullSettlement,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            style: const TextStyle(fontFamily: _kFont, fontSize: 13),
            decoration: _fieldDecoration(
              hint: 'حداکثر ${_money(_remaining)}',
              icon: Icons.credit_card,
              filled: _fullSettlement,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateAndNoteRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel('تاریخ پرداخت'),
                const SizedBox(height: 8),
                TextField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickDate,
                  style: const TextStyle(fontFamily: _kFont, fontSize: 13),
                  decoration: _fieldDecoration(
                    hint: 'انتخاب تاریخ',
                    icon: Icons.calendar_month,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel('یادداشت'),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  style: const TextStyle(fontFamily: _kFont, fontSize: 13),
                  decoration: _fieldDecoration(
                    hint: 'اختیاری',
                    icon: Icons.description_outlined,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _submit,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: RP.submitBg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Text(
                  'ثبت پرداخت',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: _kFont,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: widget.onCancel ?? () => Navigator.maybePop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: RP.cancelBg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Text(
                  'انصراف',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: _kFont,
                    fontSize: 13,
                    color: RP.cancelText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            _buildHeader(context),
            const SizedBox(height: 10),
            const Divider(thickness: 0.5, height: 1),
            const SizedBox(height: 15),
            _buildContactCard(),
            const SizedBox(height: 15),
            _buildSettlementToggle(),
            const SizedBox(height: 15),
            _buildAmountField(),
            const SizedBox(height: 15),
            _buildDateAndNoteRow(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}