import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MenuItemModel {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color iconBackColor;
  MenuItemModel({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.iconColor,
    required this.iconBackColor
  });
}
