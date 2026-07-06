import 'package:flutter/material.dart';

class FinancialCard {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color iconBackColor;
  final String price;
  FinancialCard({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.iconBackColor,
    required this.price,
  });
}
