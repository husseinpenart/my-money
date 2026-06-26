import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(77, 255, 255, 255),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(95, 119, 118, 118),
              blurRadius: 7,
              offset: Offset(0, 2),
              blurStyle: BlurStyle.normal,
              spreadRadius: BorderSide.strokeAlignOutside
            ),
          ],
        ),
        child: Icon(icon, color: Colors.grey),
      ),
    );
  }
}
