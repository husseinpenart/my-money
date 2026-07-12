import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:money/theme/app_colors.dart';

/// Checkbox + rich text row: "با ثبت‌نام، شرایط استفاده و سیاست حریم خصوصی
/// را می‌پذیرم", where the two phrases are tappable links.
class AgreeCheckboxRow extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;
  final bool hasError;

  const AgreeCheckboxRow({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onTermsTap,
    required this.onPrivacyTap,
    this.hasError = false,
  });

  @override
  State<AgreeCheckboxRow> createState() => _AgreeCheckboxRowState();
}

class _AgreeCheckboxRowState extends State<AgreeCheckboxRow> {
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = widget.onTermsTap;
    _privacyRecognizer = TapGestureRecognizer()..onTap = widget.onPrivacyTap;
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontFamily = Theme.of(context).textTheme.bodyMedium?.fontFamily;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => widget.onChanged(!widget.value),
          child: Container(
            margin: const EdgeInsets.only(top: 1),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: widget.value ? AppColors.purple3 : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: widget.hasError ? AppColors.danger : (widget.value ? AppColors.purple3 : const Color(0xFFC3C8D4)),
                width: 1.7,
              ),
            ),
            child: widget.value ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => widget.onChanged(!widget.value),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 12.5, color: const Color(0xFF6B7280), fontWeight: FontWeight.w500, height: 1.9, fontFamily: fontFamily),
                children: [
                  const TextSpan(text: 'با ثبت‌نام، '),
                  TextSpan(
                    text: 'شرایط استفاده',
                    style: const TextStyle(color: AppColors.purple3, fontWeight: FontWeight.w700),
                    recognizer: _termsRecognizer,
                  ),
                  const TextSpan(text: ' و '),
                  TextSpan(
                    text: 'سیاست حریم خصوصی',
                    style: const TextStyle(color: AppColors.purple3, fontWeight: FontWeight.w700),
                    recognizer: _privacyRecognizer,
                  ),
                  const TextSpan(text: ' را می‌پذیرم'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
