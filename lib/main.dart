import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // 👈 اضافه شد برای تشخیص وب
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:money/core/di/injection.dart';
import 'package:money/core/drawer/app_info.dart';
import 'package:money/core/network/api_client.dart';
import 'package:money/core/storage/session/session_cleaner.dart';
import 'package:money/core/storage/token_storage.dart';
import 'package:money/core/storage/web_persist.dart';
import 'package:money/widgets/global/web_frame.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/screens/home_page.dart';
import 'package:money/screens/intro_page.dart';
import 'package:cryptography_flutter/cryptography_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool _loggingOut = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterCryptography.enable();
  await configureDependencies();
  await AppInfo.init();
  requestPersistentStorage();

  _installAuthGuard();

  runApp(MoneyApp(isLoggedIn: GetIt.I<TokenStorage>().isLoggedIn));
}

void _installAuthGuard() {
  GetIt.I<ApiClient>().dio.interceptors.add(
    InterceptorsWrapper(
      onError: (e, handler) async {
        final isAuthCall = e.requestOptions.path.contains('/AuthControllers/');
        final hadToken = GetIt.I<TokenStorage>().getToken() != null;

        if (e.response?.statusCode == 401 &&
            hadToken &&
            !isAuthCall &&
            !_loggingOut) {
          _loggingOut = true;
          await SessionCleaner.clear();
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const IntroPage()),
            (_) => false,
          );
          _loggingOut = false;
        }
        handler.next(e);
      },
    ),
  );
}

class MoneyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MoneyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      // ✅ این خط کپسول مزاحم رو روی گوشی کلاً خاموش میکنه:
      builder: (context, child) {
        final Widget content = child ?? const SizedBox.expand();
        return kIsWeb ? WebFrame(child: content) : content;
      },
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
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(
          0xFFF3F4F6,
        ), // رنگ خاکستری ملایم پس‌زمینه
        fontFamily: 'sans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 93, 0, 255),
          brightness: Brightness.light,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          showDragHandle: true,
          dragHandleColor: Color.fromARGB(255, 179, 169, 169),
          dragHandleSize: Size(60, 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          backgroundColor: Colors.white,
        ),
      ),
      home: isLoggedIn
          ? const MyHomePage(title: Titles.mainTitle)
          : const IntroPage(),
    );
  }
}
