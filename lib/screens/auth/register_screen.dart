import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/core/di/injection.dart';

import 'package:money/data/policy_content.dart';
import 'package:money/feature/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/auth/auth_event.dart';
import 'package:money/feature/auth/presentation/bloc/auth/auth_state.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();

    super.dispose();
  }

  String _normalizeDigits(String value) {
    const Map<String, String> digitMap = {
      '۰': '0',
      '۱': '1',
      '۲': '2',
      '۳': '3',
      '۴': '4',
      '۵': '5',
      '۶': '6',
      '۷': '7',
      '۸': '8',
      '۹': '9',

      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };

    return value.split('').map((String char) => digitMap[char] ?? char).join();
  }

  String? _validateName(String? value) {
    final String text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'نام و نام خانوادگی الزامی است.';
    }

    if (text.length < 3) {
      return 'نام باید حداقل ۳ کاراکتر باشد.';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    final String text = _normalizeDigits(value?.trim() ?? '');

    if (text.isEmpty) {
      return 'شماره موبایل الزامی است.';
    }

    final RegExp phoneRegExp = RegExp(r'^09[0-9]{9}$');

    if (!phoneRegExp.hasMatch(text)) {
      return 'شماره موبایل باید ۱۱ رقم باشد و با ۰۹ شروع شود.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final String text = value ?? '';

    if (text.isEmpty) {
      return 'رمز عبور الزامی است.';
    }

    if (text.length < 8) {
      return 'رمز عبور باید حداقل ۸ کاراکتر باشد.';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final String text = value ?? '';

    if (text.isEmpty) {
      return 'تکرار رمز عبور الزامی است.';
    }

    if (text != _passwordController.text) {
      return 'رمز عبور و تکرار آن یکسان نیست.';
    }

    return null;
  }

  void _goToLogin() {
    final AuthState currentState = context.read<AuthBloc>().state;

    if (currentState is AuthLoading) {
      return;
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  // داخل _RegisterViewState:

  void _submit() {
    _formKey.currentState?.validate(); // validatorها null → همیشه true

    setState(() => _agreeError = !_agreed); // فقط تیک قوانین سمت UI می‌ماند

    if (!_agreed) return; // 👈 تنها چک کلاینتی (تعهد محلی)

    context.read<AuthBloc>().add(
      RegisterSubmitted(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmController.text,
        agreedToTerms: _agreed,
      ),
    );
  }

  void _showMessage({required String message, required bool isError}) {
    if (!mounted) {
      return;
    }

    final String text = message.trim().isEmpty
        ? (isError ? 'خطایی رخ داد.' : 'عملیات با موفقیت انجام شد.')
        : message.trim();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(text),
          ),
          backgroundColor: isError
              ? Colors.red.shade700
              : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: isError ? 5 : 3),
        ),
      );
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (!mounted) {
      return;
    }

    if (state is AuthFailure) {
      _showMessage(message: state.message, isError: true);
      return;
    }

    if (state is AuthSuccess) {
      _showMessage(message: state.message, isError: false);

      /// بعد از ثبت‌نام موفق، کاربر را به صفحه ورود می‌برد.
      /// اگر نمی‌خواهی این اتفاق بیفتد، این Future.delayed را حذف کن.
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) {
          return;
        }

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
                                  if (index == 1) {
                                    _goToLogin();
                                  }
                                },
                              ),

                              const SizedBox(height: 22),

                              AppTextField(
                                controller: _nameController,
                                label: 'نام و نام خانوادگی',
                                hint: 'مثال: محمد رضایی',
                                icon: Icons.person_outline_rounded,
                                validator: null, // 👈 خطا از سرور
                              ),

                              const SizedBox(height: 16),

                              AppTextField(
                                controller: _phoneController,
                                label: 'شماره موبایل',
                                hint: '0912 000 0000', // 👈 لاتین
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                maxLength: 11,
                                textDirection:
                                    TextDirection.ltr, // 👈 رفع برعکس
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: null, // 👈 خطا از سرور
                              ),

                              const SizedBox(height: 16),

                              AppPasswordField(
                                controller: _passwordController,
                                label: 'رمز عبور',
                                hint: 'رمز عبور بسازید',
                                validator: null, // 👈 خطا از سرور
                                onChanged: (_) => setState(() {}),
                              ),

                              PasswordStrengthMeter(
                                password: _passwordController.text,
                              ),

                              const SizedBox(height: 16),

                              AppPasswordField(
                                controller: _confirmController,
                                label: 'تکرار رمز عبور',
                                hint: 'رمز عبور را دوباره وارد کنید',
                                validator: null, // 👈 خطا از سرور
                              ),
                              const SizedBox(height: 18),

                              AgreeCheckboxRow(
                                value: _agreed,
                                hasError: _agreeError,
                                onChanged: (bool value) {
                                  setState(() {
                                    _agreed = value;
                                    _agreeError = false;
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
}/*  */