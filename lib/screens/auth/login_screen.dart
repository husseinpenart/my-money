// lib/feature/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:money/dictionary/titles.dart';

import 'package:money/feature/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/auth/auth_event.dart';
import 'package:money/feature/auth/presentation/bloc/auth/auth_state.dart';
import 'package:money/feature/auth/presentation/pages/auth/forgot_password_screen.dart';
import 'package:money/helper/utils/string_utils.dart';
import 'package:money/screens/home_page.dart';
import 'package:money/theme/app_colors.dart';
import 'package:money/widgets/auth/app_password_field.dart';
import 'package:money/widgets/auth/app_text_field.dart';
import 'package:money/widgets/auth/auth_card.dart';
import 'package:money/widgets/auth/auth_tabs.dart';
import 'package:money/widgets/auth/hero_header.dart';
import 'package:money/widgets/auth/primary_button.dart';
import 'package:money/widgets/auth/switch_link.dart';
import 'package:money/widgets/auth/trust_badge_row.dart';

import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => GetIt.I<AuthBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  List<String> _serverErrors = [];

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // بررسی لحظه‌ای خطاها برای حذف موارد برطرف‌شده
  List<String> get _activeErrors {
    final phone = _phoneController.text.trim();
    final pass = _passwordController.text;

    return _serverErrors.where((err) {
      if (err.contains('الزامی') && phone.isNotEmpty && pass.isNotEmpty) {
        return false;
      }
      if (err.contains('تماس') && phone.isNotEmpty) return false;
      if (err.contains('11 رقم') && phone.length == 11) return false;
      if (err.contains('09') && phone.startsWith('09')) return false;
      if (err.contains('عبور') && pass.isNotEmpty) return false;
      if (err.contains('8 کاراکتر') && pass.length >= 8) return false;
      return true;
    }).toList();
  }

  void _goToRegister() {
    if (context.read<AuthBloc>().state is AuthLoading) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  void _submit() {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    // تبدیل شماره به ارقام انگلیسی استاندارد برای ارسال به سرور ASP.NET
    final normalizedPhone = NumberHelper.toEnglishDigits(phone);

    if (normalizedPhone.isEmpty || password.isEmpty) {
      setState(() {
        _serverErrors = ['پر کردن تمامی فیلد ها الزامی است'];
      });
      return;
    }

    setState(() {
      _serverErrors = [];
    });

    // ارسال ایونت ورود
    context.read<AuthBloc>().add(
      LoginSubmitted(phoneNumber: normalizedPhone, password: password),
    );
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (!mounted) return;

    if (state is AuthFailure) {
      setState(() {
        _serverErrors = state.message
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      });
      return;
    }

    if (state is AuthSuccess) {
      setState(() => _serverErrors = []);

      // ۱. متن پیام برگشتی از سمت سرور
      final successMsg = state.message.isNotEmpty
          ? state.message
          : 'ورود با موفقیت انجام شد';

      // ۲. انتقال به صفحه اصلی و پاک کردن تمام صفحات قبلی از پشته (Stack)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MyHomePage(title: Titles.mainTitle),
        ),
        (route) => false,
      );

      // ۳. نمایش پیام سرور روی صفحه اصلی
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                successMsg,
                style: const TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: _onAuthStateChanged,
      builder: (context, state) {
        final bool isLoading = state is AuthLoading;
        final activeErrors = _activeErrors;

        return Scaffold(
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: AbsorbPointer(
                absorbing: isLoading,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const HeroHeader(
                        gradientColors: AppColors.blueGradient,
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'خوش آمدید',
                        subtitle: 'وارد حساب کاربری خود شوید',
                      ),

                      Transform.translate(
                        offset: const Offset(0, -40),
                        child: AuthCard(
                          child: Column(
                            children: [
                              AuthTabs(
                                leftLabel: 'ثبت‌نام',
                                rightLabel: 'ورود',
                                activeIndex: 1,
                                activeColor: AppColors.blue2,
                                onChanged: (index) {
                                  if (index == 0) _goToRegister();
                                },
                              ),

                              const SizedBox(height: 22),

                              AppTextField(
                                controller: _phoneController,
                                label: 'شماره موبایل',
                                hint: '0912 000 0000',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                maxLength: 11,
                                textDirection: TextDirection.ltr,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: null,
                                onChanged: (_) => setState(() {}),
                              ),

                              const SizedBox(height: 16),

                              AppPasswordField(
                                controller: _passwordController,
                                label: 'رمز عبور',
                                hint: 'رمز عبور خود را وارد کنید',
                                validator: null,
                                onChanged: (_) => setState(() {}),
                              ),

                              const SizedBox(height: 30),

                              PrimaryButton(
                                label: isLoading
                                    ? 'در حال ورود...'
                                    : 'ورود به حساب',
                                gradientColors: AppColors.blueGradient,
                                loading: isLoading,
                                onPressed: _submit,
                              ),
                              const SizedBox(height: 20),
                              TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ForgotPasswordScreen(),
                                        ),
                                      ),
                                child: const Text(
                                  'فراموشی رمز عبور؟',
                                  style: TextStyle(fontSize: 12.5),
                                ),
                              ),
                              if (activeErrors.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: activeErrors.map((err) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 3,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.error_outline_rounded,
                                              color: Colors.red.shade700,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                err,
                                                style: TextStyle(
                                                  color: Colors.red.shade800,
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 16),

                              const TrustBadgeRow(),
                            ],
                          ),
                        ),
                      ),

                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: SwitchLink(
                          plainText: 'حساب ندارید؟ ',
                          linkText: 'ثبت‌نام رایگان',
                          linkColor: AppColors.blue2,
                          onTap: _goToRegister,
                        ),
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
