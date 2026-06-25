import 'package:flutter/material.dart';

class Homelayouts extends StatefulWidget {
  const Homelayouts({super.key});

  @override
  State<Homelayouts> createState() => _MyHomePageLayouts();
}

class _MyHomePageLayouts extends State<Homelayouts> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Layout appears',
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w900),
      ),
    );
  }
}
