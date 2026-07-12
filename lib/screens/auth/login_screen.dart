import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/helper/utils/validators.dart';
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
import 'success_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToRegister() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('لینک بازیابی رمز عبور به شماره موبایل شما پیامک خواهد شد.')),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => const SuccessScreen(
          title: 'ورود موفق!',
          subtitle: 'خوش برگشتید 👋\nدر حال ورود به برنامه...',
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
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
                          hint: '۰۹۱۲ ۰۰۰ ۰۰۰۰',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          maxLength: 11,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: Validators.phone,
                        ),
                        const SizedBox(height: 16),
                        AppPasswordField(
                          controller: _passwordController,
                          label: 'رمز عبور',
                          hint: 'رمز عبور خود را وارد کنید',
                          validator: Validators.loginPassword,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: _forgotPassword,
                            child: const Text('فراموشی رمز عبور؟', style: TextStyle(fontSize: 12.5)),
                          ),
                        ),
                        const SizedBox(height: 2),
                        PrimaryButton(
                          label: 'ورود به حساب',
                          gradientColors: AppColors.blueGradient,
                          onPressed: _submit,
                        ),
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
    );
  }
}
