import 'package:flutter/material.dart';

class FilterButtons extends StatelessWidget {
  const FilterButtons({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          // آلفای قبلی (10 در fromRGBO) اشتباه بود؛ اینجا رنگ ثابت و درست
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
          ),
          // سایه فقط در حالت غیرانتخاب، ملایم و بدون spread اضافه
          boxShadow: isSelected
              ? null
              : [
                  BoxShadow(
                    blurRadius: 6,
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'sans',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}