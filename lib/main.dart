import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/layouts/HomeLayouts.dart';
import 'package:money/screens/report_page.dart';
import 'package:money/widgets/custom_expandable_fab.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('fa')],
      title: Titles.topTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 93, 0, 255),
        ),
      ),
      home: const MyHomePage(title: Titles.mainTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    Homelayouts(),
    ReportPage(),
    Center(child: Text('مخاطبین')),
    Center(child: Text('تنظیمات')),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color.fromRGBO(78, 129, 239, 1),
        unselectedItemColor: Color.fromRGBO(163, 168, 176, 1),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedLabelStyle: TextStyle(fontFamily: 'sans', fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontFamily: 'sans', fontSize: 12),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 20),
            label: BottomNavigations.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: ScreenDictionary.report,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: BottomNavigations.contacts,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: BottomNavigations.setting,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .startFloat, // قرارگیری در پایین راست/چپ بر اساس RTL/LTR
      floatingActionButton: const CustomExpandableFab(),
    );
  }
}
