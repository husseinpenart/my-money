import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/helper/utils/number_helper.dart';
import 'package:money/widgets/forms/top_button_filter.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

class ConfirmDemandLayout extends StatefulWidget {
  final TextEditingController _startDateController;
  final TextEditingController _endDateController;
  final bool hasDebt;
  final bool editTitle;
  const ConfirmDemandLayout({
    super.key,
    required TextEditingController startDateController,
    required TextEditingController endDateController,
    required this.hasDebt,
    this.editTitle = false,
  }) : _startDateController = startDateController,
       _endDateController = endDateController;

  @override
  State<ConfirmDemandLayout> createState() => _ConfirmDemandLayoutState();
}

class _ConfirmDemandLayoutState extends State<ConfirmDemandLayout> {
  late bool _isDemand;
  late bool _isDebt;

  Future<void> _pickDate(TextEditingController controller) async {
    FocusScope.of(context).unfocus();

    Jalali? picked = await showPersianDatePicker(
      context: context,
      initialDate: Jalali.now(),
      firstDate: Jalali(1400, 1),
      lastDate: Jalali(1450, 12),
      initialEntryMode: PersianDatePickerEntryMode.calendar,
      initialDatePickerMode: PersianDatePickerMode.day,
      locale: const Locale('fa', 'IR'),
    );

    if (picked != null) {
      final rawDate =
          '${picked.year}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}';

      setState(() {
        controller.text = NumberHelper.toPersianDigits(rawDate);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    super.initState();
    _isDemand = !widget.hasDebt;
    _isDebt = widget.hasDebt;
  }

  void _selectDemand() {
    setState(() {
      _isDemand = true;
      _isDebt = false;
    });
  }

  void _selectDebt() {
    setState(() {
      _isDemand = false;
      _isDebt = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(maxHeight: double.infinity),

        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              widget.editTitle
                  ? ScreenDictionary.informEdit
                  : _isDemand
                  ? ScreenDictionary.informTitle
                  : ScreenDictionary.informNewDebt,
              style: const TextStyle(fontFamily: 'sans', fontSize: 17),
            ),
            SizedBox(height: 20),
            const Divider(thickness: 0.5, height: 1),
            SizedBox(height: 20),
            TopButtonFilter(
              isDemand: _isDemand,
              isDebt: _isDebt,
              onDemandTap: _selectDemand,
              onDebtTap: _selectDebt,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10.0,
                children: [
                  Text(
                    ScreenDictionary.labelName,
                    style: TextStyle(
                      fontFamily: 'sans',
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 211, 205, 205),
                        ),
                      ),
                      hintText: ScreenDictionary.placeholderName,
                      hintStyle: TextStyle(
                        fontFamily: 'sans',
                        fontSize: 12,
                        color: const Color.fromARGB(255, 211, 205, 205),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      prefixIcon: Align(
                        widthFactor: 1.0,
                        heightFactor: 1.0,
                        child: Icon(Icons.person, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10.0,
                children: [
                  Text(
                    ScreenDictionary.labelPrice,
                    style: TextStyle(
                      fontFamily: 'sans',
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 211, 205, 205),
                        ),
                      ),
                      hintText: ScreenDictionary.placeholderPrice,
                      hintStyle: TextStyle(
                        fontFamily: 'sans',
                        fontSize: 12,
                        color: const Color.fromARGB(255, 211, 205, 205),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      prefixIcon: Align(
                        widthFactor: 1.0,
                        heightFactor: 1.0,
                        child: Icon(Icons.credit_card, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10.0,
                children: [
                  Text(
                    ScreenDictionary.labelMobile,
                    style: TextStyle(
                      fontFamily: 'sans',
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 211, 205, 205),
                        ),
                      ),
                      hintText: ScreenDictionary.placeholderMobile,
                      hintStyle: TextStyle(
                        fontFamily: 'sans',
                        fontSize: 12,
                        color: const Color.fromARGB(255, 211, 205, 205),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      prefixIcon: Align(
                        widthFactor: 1.0,
                        heightFactor: 1.0,
                        child: Icon(Icons.phone, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                spacing: 5.0,
                children: [
                  Expanded(
                    child: Column(
                      spacing: 10.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ScreenDictionary.initialRegisterDate,
                          style: TextStyle(
                            fontFamily: 'sans',
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        TextField(
                          controller: widget._startDateController,
                          readOnly: true,
                          onTap: () => _pickDate(widget._startDateController),
                          style: TextStyle(fontFamily: 'sans', fontSize: 14),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 211, 205, 205),
                              ),
                            ),
                            hintText: 'انتخاب تاریخ',

                            hintStyle: TextStyle(
                              fontFamily: 'sans',
                              fontSize: 12,
                              color: const Color.fromARGB(255, 211, 205, 205),
                            ),

                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            prefixIcon: Align(
                              widthFactor: 1.0,
                              heightFactor: 1.0,
                              child: Icon(Icons.calendar_month, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10.0,
                      children: [
                        Text(
                          ScreenDictionary.endPaymentDate,
                          style: TextStyle(
                            fontFamily: 'sans',
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        TextField(
                          controller: widget._endDateController,
                          readOnly: true,
                          onTap: () => _pickDate(widget._endDateController),
                          style: TextStyle(fontFamily: 'sans', fontSize: 14),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 211, 205, 205),
                              ),
                            ),
                            hintText: 'انتخاب تاریخ',

                            hintStyle: TextStyle(
                              fontFamily: 'sans',
                              fontSize: 12,
                              color: const Color.fromARGB(255, 211, 205, 205),
                            ),

                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            prefixIcon: Align(
                              widthFactor: 1.0,
                              heightFactor: 1.0,
                              child: Icon(Icons.calendar_month, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10.0,
                children: [
                  Text(
                    ScreenDictionary.labelNote,
                    style: TextStyle(
                      fontFamily: 'sans',
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  SizedBox(
                    height: 70,
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      maxLines: null,
                      expands: true,
                      textAlign: TextAlign.right,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 211, 205, 205),
                          ),
                        ),
                        hintText: ScreenDictionary.placeholderNote,
                        hintStyle: TextStyle(
                          fontFamily: 'sans',
                          fontSize: 12,
                          color: const Color.fromARGB(255, 211, 205, 205),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        prefixIcon: Align(
                          widthFactor: 1.0,
                          heightFactor: 1.0,
                          child: Icon(Icons.create_outlined, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () {},
                  child: Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(13),
                      padding: EdgeInsets.all(13),

                      decoration: BoxDecoration(
                        color: _isDemand
                            ? Color.fromRGBO(37, 99, 235, 1)
                            : const Color.fromRGBO(239, 68, 68, 1),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Text(
                        ScreenDictionary.saveDemmandButton,
                        style: TextStyle(
                          fontFamily: 'sans',
                          fontSize: 13,
                          color: Colors.white,
                        ),
                        selectionColor: Colors.transparent,
                        textAlign: TextAlign.center,
                      ),
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
