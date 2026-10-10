import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/widgets/contact/contact_style.dart';

const _grey500 = Color(0xFF9E9E9E);
const _brand = Color(0xFF4E81EF);

class CopyableField extends StatelessWidget {
  const CopyableField({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color = _brand,
    this.mono = true,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color color;
  final bool mono;

  String get _display => mono ? _group(value) : value;

  static String _group(String s) {
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && i % 4 == 0) b.write('  ');
      b.write(s[i]);
    }
    return b.toString();
  }

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          width: 240,
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFF111827),
          content: Row(
            children: [
              const Icon(Icons.copy_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text('$label کپی شد', style: sans(size: 12, color: Colors.white)),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _copy(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEEF0F4)),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: sans(size: 11, color: _grey500)),
                    const SizedBox(height: 3),
                    Text(
                      _display,
                      style: TextStyle(
                        fontFamily: mono ? 'monospace' : 'sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: mono ? 0.5 : 0,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(Icons.copy_rounded, size: 16, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
