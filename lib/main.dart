import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:money/core/di/injection.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/screens/home_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  runApp(const MoneyApp());
}

class MoneyApp extends StatefulWidget {
  
  const MoneyApp({super.key});
  @override
  State<MoneyApp> createState() => _MoneyAppState();
}

class _MoneyAppState extends State<MoneyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('fa', 'IR'),
      localizationsDelegates: const [
        PersianMaterialLocalizations.delegate,
        PersianCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fa', 'IR')],
      title: Titles.topTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 93, 0, 255),
        ),

        bottomSheetTheme: const BottomSheetThemeData(
          showDragHandle: true,
          dragHandleColor: Color.fromARGB(255, 179, 169, 169),
          dragHandleSize: Size(60, 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          backgroundColor: Colors.white,
          modalBackgroundColor: Colors.amberAccent,
        ),
      ),
      home: const MyHomePage(title: Titles.mainTitle),
    );
  }
}
