import 'package:flutter/material.dart';
import 'package:money/helper/utils/password_strength.dart';
import 'package:money/theme/app_colors.dart';

/// Live strength indicator shown below the register password field:
/// 3 colored bars + a label + requirement chips (length / number / uppercase).
class PasswordStrengthMeter extends StatelessWidget {
  final String password;

  const PasswordStrengthMeter({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final result = PasswordStrengthResult.fromPassword(password);
    final levelIndex = switch (result.strength) {
      PasswordStrength.weak => 0,
      PasswordStrength.medium => 1,
      PasswordStrength.strong => 2,
    };
    const colors = [AppColors.danger, AppColors.warn, AppColors.ok];
    const labels = ['ضعیف', 'متوسط', 'قوی'];
    final activeColor = colors[levelIndex];

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: i == 2 ? 0 : 5),
                  height: 5,
                  decoration: BoxDecoration(
                    color: i <= levelIndex ? activeColor : AppColors.line,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 7),
          Text(
            labels[levelIndex],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: activeColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _RequirementChip(label: '۶+ کاراکتر', met: result.hasLength),
              _RequirementChip(label: 'عدد', met: result.hasNumber),
              _RequirementChip(label: 'حرف بزرگ', met: result.hasUppercase),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequirementChip extends StatelessWidget {
  final String label;
  final bool met;
  const _RequirementChip({required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    final textColor = met ? AppColors.ok : const Color(0xFF9AA1B3);
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 8, 5),
      decoration: BoxDecoration(
        color: met ? const Color(0xFFEAFBF3) : const Color(0xFFF0F2F6),
        border: Border.all(
          color: met ? const Color(0xFFBDEED7) : AppColors.line,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: met ? AppColors.ok : Colors.transparent,
              border: Border.all(
                color: met ? AppColors.ok : const Color(0xFFC3C8D4),
                width: 1.5,
              ),
            ),
            child: met
                ? const Icon(Icons.check, size: 9, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
