import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/di/injection.dart';
import 'package:money/core/storage/token_storage.dart'; // 👈 اضافه کردن اینپورت
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/screens/home_page.dart';
import 'package:money/screens/intro_page.dart'; // 👈 اضافه کردن اینپورت

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  // 👈 بررسی وجود توکن
  final tokenStorage = GetIt.I<TokenStorage>();
  final token = tokenStorage
      .getToken(); // نکته: اگر اسم متد خواندن توکن در کلاست متفاوت است، آن را تغییر بده
  final bool isLoggedIn = token != null && token.isNotEmpty;

  // وضعیت لاگین را به اپلیکیشن پاس می‌دهیم
  runApp(MoneyApp(isLoggedIn: isLoggedIn));
}

class MoneyApp extends StatefulWidget {
  final bool isLoggedIn; // 👈 دریافت وضعیت لاگین

  const MoneyApp({super.key, required this.isLoggedIn});
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
      // 👈 تصمیم‌گیری برای نمایش صفحه اول:
      home: widget.isLoggedIn
          ? const MyHomePage(title: Titles.mainTitle) // کاربر لاگین است
          : const IntroPage(), // کاربر لاگین نیست
    );
  }
}
