import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/core/di/injection.dart';

import 'package:money/data/policy_content.dart';
import 'package:money/feature/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/auth/auth_event.dart';
import 'package:money/feature/auth/presentation/bloc/auth/auth_state.dart';
import 'package:money/helper/utils/number_helper.dart';
import 'package:money/theme/app_colors.dart';

import 'package:money/widgets/auth/agree_checkbox_row.dart';
import 'package:money/widgets/auth/app_password_field.dart';
import 'package:money/widgets/auth/app_text_field.dart';
import 'package:money/widgets/auth/auth_card.dart';
import 'package:money/widgets/auth/auth_tabs.dart';
import 'package:money/widgets/auth/hero_header.dart';
import 'package:money/widgets/auth/password_strength_meter.dart';
import 'package:money/widgets/auth/policy_bottom_sheet.dart';
import 'package:money/widgets/auth/primary_button.dart';
import 'package:money/widgets/auth/switch_link.dart';

import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => getIt<AuthBloc>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _agreed = false;
  bool _agreeError = false;

  // 👈 لیست خطاهای دریافتی از سرور
  List<String> _serverErrors = [];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // 👈 این متد بررسی می‌کند کدام خطاها توسط کاربر برطرف شده‌اند تا آن‌ها را پاک کند
  List<String> get _activeErrors {
    final name = _nameController.text.trim();
    final phone = NumberHelper.toPersianDigits(_phoneController.text.trim());
    final pass = _passwordController.text;
    final confirm = _confirmController.text;

    return _serverErrors.where((err) {
      if (err.contains('نام') && name.isNotEmpty) return false;
      if (err.contains('تماس الزامی') && phone.isNotEmpty) return false;
      if (err.contains('11 رقم') && phone.length == 11) return false;
      if (err.contains('09') && phone.startsWith('09')) return false;
      if (err.contains('عبور الزامی') && pass.isNotEmpty) return false;
      if (err.contains('8 کاراکتر') && pass.length >= 8) return false;
      if ((err.contains('تکرار') || err.contains('مطابقت')) &&
          confirm.isNotEmpty &&
          pass == confirm) {
        return false;
      }
      return true; // اگر هنوز برطرف نشده، نمایش بده
    }).toList();
  }

  void _goToLogin() {
    if (context.read<AuthBloc>().state is AuthLoading) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _submit() {
    setState(() {
      _serverErrors = []; // پاک کردن خطاهای قبلی قبل از ارسال جدید
      _agreeError = !_agreed;
    });

    context.read<AuthBloc>().add(
      RegisterSubmitted(
        name: _nameController.text.trim(),
        phoneNumber: NumberHelper.toPersianDigits(_phoneController.text.trim()),
        password: _passwordController.text,
        confirmedPassword: _confirmController.text,
        agreedToTerms: _agreed,
      ),
    );

    if (!_agreed) {
      setState(() {
        _serverErrors = ['لطفاً شرایط و قوانین را بپذیرید.'];
      });
      return;
    }
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (!mounted) return;

    if (state is AuthFailure) {
      setState(() {
        // جدا کردن خطاهای چندخطی سرور و تبدیل به لیست
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              state.message.isEmpty
                  ? 'ثبت‌نام با موفقیت انجام شد'
                  : state.message,
            ),
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: _onAuthStateChanged,
      builder: (context, state) {
        final bool isLoading = state is AuthLoading;
        final activeErrors = _activeErrors; // خطاهای باقی‌مانده

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
                        gradientColors: AppColors.purpleGradient,
                        icon: Icons.person_add_alt_1_outlined,
                        title: 'ایجاد حساب جدید',
                        subtitle:
                            'یک‌بار ثبت‌نام کنید، همیشه سازمان‌یافته بمانید',
                      ),

                      Transform.translate(
                        offset: const Offset(0, -40),
                        child: AuthCard(
                          child: Column(
                            children: [
                              AuthTabs(
                                leftLabel: 'ثبت‌نام',
                                rightLabel: 'ورود',
                                activeIndex: 0,
                                activeColor: AppColors.purple3,
                                onChanged: (int index) {
                                  if (index == 1) _goToLogin();
                                },
                              ),

                              const SizedBox(height: 22),

                              AppTextField(
                                controller: _nameController,
                                label: 'نام و نام خانوادگی',
                                hint: 'مثال: محمد رضایی',
                                icon: Icons.person_outline_rounded,
                                onChanged: (_) =>
                                    setState(() {}), // 👈 بررسی لحظه‌ای
                              ),

                              const SizedBox(height: 16),

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
                                onChanged: (_) =>
                                    setState(() {}), // 👈 بررسی لحظه‌ای
                              ),

                              const SizedBox(height: 16),

                              AppPasswordField(
                                controller: _passwordController,
                                label: 'رمز عبور',
                                hint: 'رمز عبور بسازید',
                                onChanged: (_) =>
                                    setState(() {}), // 👈 بررسی لحظه‌ای
                              ),

                              PasswordStrengthMeter(
                                password: _passwordController.text,
                              ),

                              const SizedBox(height: 16),

                              AppPasswordField(
                                controller: _confirmController,
                                label: 'تکرار رمز عبور',
                                hint: 'رمز عبور را دوباره وارد کنید',
                                onChanged: (_) =>
                                    setState(() {}), // 👈 بررسی لحظه‌ای
                              ),

                              const SizedBox(height: 18),

                              AgreeCheckboxRow(
                                value: _agreed,
                                hasError: _agreeError,
                                onChanged: (bool value) {
                                  setState(() {
                                    _agreed = value;
                                    _agreeError = false;
                                    _serverErrors.removeWhere(
                                      (e) => e.contains('قوانین'),
                                    );
                                  });
                                },
                                onTermsTap: () {
                                  PolicyBottomSheet.show(
                                    context,
                                    title: 'شرایط استفاده',
                                    sections: PolicyContent.terms,
                                  );
                                },
                                onPrivacyTap: () {
                                  PolicyBottomSheet.show(
                                    context,
                                    title: 'سیاست حریم خصوصی',
                                    sections: PolicyContent.privacy,
                                  );
                                },
                              ),

                              const SizedBox(height: 18),

                              PrimaryButton(
                                label: 'ایجاد حساب کاربری',
                                gradientColors: AppColors.purpleGradient,
                                loading: isLoading,
                                onPressed: _submit,
                              ),

                              // 👈 باکس نمایش خطاها در پایین دکمه
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
                            ],
                          ),
                        ),
                      ),

                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: SwitchLink(
                          plainText: 'حساب دارید؟ ',
                          linkText: 'وارد شوید',
                          linkColor: AppColors.purple3,
                          onTap: _goToLogin,
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
