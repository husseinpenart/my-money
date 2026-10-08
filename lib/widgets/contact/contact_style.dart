import 'package:flutter/material.dart';

const Color kAccent = Color.fromARGB(255, 83, 109, 255);

TextStyle sans({double size = 13, FontWeight? weight, Color? color}) =>
    TextStyle(
      fontFamily: 'sans',
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
