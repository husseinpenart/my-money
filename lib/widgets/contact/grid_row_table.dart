import 'package:flutter/material.dart';

class gridRowTable extends StatelessWidget {
  const gridRowTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            blurStyle: BlurStyle.normal,
            color: Colors.black.withValues(alpha: 0.07),
            offset: Offset(2, 2),
            spreadRadius: 0.05,
          ),
        ],
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _InfoItem(title: 'نوع رابطه', value: 'طلبکار'),
                ),
                Container(width: 1, color: const Color(0xFFEAEAEA)),
                Expanded(
                  child: _InfoItem(title: 'تاریخ ثبت', value: '1403/03/12'),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFEAEAEA)),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _InfoItem(title: 'سررسید', value: '1403/04/01'),
                ),
                Container(width: 1, color: const Color(0xFFEAEAEA)),
                Expanded(
                  child: _InfoItem(title: 'مانده پرداخت', value: '2,500,000 ت'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10.0,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'sans',
              fontSize: 12,
              color: Color(0xFF8C8C8C),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'sans',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
