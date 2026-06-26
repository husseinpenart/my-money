import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/widgets/global/CustomIconButton.dart';

class Header extends StatefulWidget {
  const Header({super.key});
  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  bool _isSearchVisible = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Titles.hello,
                    style: const TextStyle(fontSize: 12, fontFamily: 'sans'),
                  ),
                  const Text(
                    'حسین اسدی 👋',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black,
                      fontFamily: 'sans',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  CustomIconButton(
                    onPressed: () {
                      setState(() {
                        _isSearchVisible = !_isSearchVisible;
                      });
                    },
                    icon: _isSearchVisible ? Icons.close : Icons.search,
                  ),
                  const SizedBox(width: 12),
                  CustomIconButton(
                    onPressed: () => print('bell'),
                    icon: Icons.doorbell,
                  ),
                ],
              ),
            ],
          ),
          if (_isSearchVisible) ...[
            const SizedBox(height: 20),
            TextFormField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: Titles.searchText,
                hintStyle: TextStyle(fontFamily: 'sans'),
                fillColor: Colors.white,
                filled: true,
                prefixIcon: Icon(Icons.search),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 83, 109, 255),
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 83, 109, 255),
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
