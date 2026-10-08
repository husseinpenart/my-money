import 'package:flutter/material.dart';

/// The main gradient call-to-action button used on both auth forms.
class PrimaryButton extends StatelessWidget {
  final String label;
  final List<Color> gradientColors;
  final VoidCallback? onPressed;
  final bool loading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.gradientColors,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    // اگر در حال لودینگ باشد یا onPressed نال باشد، دکمه غیرفعال است
    final enabled = onPressed != null && !loading;

    return Opacity(
      opacity: enabled ? 1 : 0.6, // وقتی در حال انجام است کم‌رنگ‌تر می‌شود
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: gradientColors.last.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            // در حالت لودینگ هیچ رویداد کلیکی انجام نمی‌شود
            onTap: enabled ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (!loading) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
