import 'package:flutter/material.dart';

// 👈 معادلِ دقیقِ Color.fromARGB(255, 83, 109, 255) ولی به‌صورت hex literal
// تا const-fold تضمینی باشد (83=0x53، 109=0x6D، 255=0xFF)
const Color kAccent = Color(0xFF536DFF);

TextStyle sans({double size = 13, FontWeight? weight, Color? color}) =>
    TextStyle(
      fontFamily: 'sans',
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
