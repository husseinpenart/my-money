import 'package:flutter/material.dart';

/// A labeled password field with a lock icon and a show/hide toggle.
class AppPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final AutovalidateMode autovalidateMode;
  final String? errorText; // 👈 ۱. متغیر خطا

  const AppPasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.onChanged,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.errorText, // 👈 ۲. اضافه شدن به سازنده
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5164),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          onChanged: widget.onChanged,
          validator: widget.validator,
          autovalidateMode: widget.autovalidateMode,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText, // 👈 ۳. نمایش متن خطا زیر فیلد
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: Color(0xFF9AA1B3),
            ),
            suffixIcon: IconButton(
              splashRadius: 18,
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: const Color(0xFF9AA1B3),
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
      ],
    );
  }
}
