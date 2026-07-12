import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/data/policy_content.dart';
import 'package:money/helper/utils/validators.dart';
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
import 'success_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _agreed = false;
  bool _agreeError = false;
  String _password = '';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _onPasswordChanged(String value) {
    setState(() => _password = value);
    // Re-validate the confirm field live once the user has started typing it,
    // so a matching/mismatching state updates as the password changes too.
    if (_confirmController.text.isNotEmpty) {
      _formKey.currentState?.validate();
    }
  }

  void _submit() {
    final formValid = _formKey.currentState!.validate();
    setState(() => _agreeError = !_agreed);

    if (formValid && _agreed) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const SuccessScreen(
            title: 'ثبت‌نام موفق!',
            subtitle: 'حساب شما ساخته شد.\nدر حال ورود به برنامه...',
          ),
        ),
      );
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
                  gradientColors: AppColors.purpleGradient,
                  icon: Icons.person_add_alt_1_outlined,
                  title: 'ایجاد حساب جدید',
                  subtitle: 'یک‌بار ثبت‌نام کنید، همیشه سازمان‌یافته بمانید',
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
                          onChanged: (index) {
                            if (index == 1) _goToLogin();
                          },
                        ),
                        const SizedBox(height: 22),
                        AppTextField(
                          controller: _nameController,
                          label: 'نام و نام خانوادگی',
                          hint: 'مثال: محمد رضایی',
                          icon: Icons.person_outline_rounded,
                          validator: Validators.name,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _phoneController,
                          label: 'شماره موبایل',
                          hint: '۰۹۱۲ ۰۰۰ ۰۰۰۰',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          maxLength: 11,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: Validators.phone,
                        ),
                        const SizedBox(height: 16),
                        AppPasswordField(
                          controller: _passwordController,
                          label: 'رمز عبور',
                          hint: 'رمز عبور بسازید',
                          validator: Validators.registerPassword,
                          onChanged: _onPasswordChanged,
                        ),
                        PasswordStrengthMeter(password: _password),
                        const SizedBox(height: 16),
                        AppPasswordField(
                          controller: _confirmController,
                          label: 'تکرار رمز عبور',
                          hint: 'رمز عبور را دوباره وارد کنید',
                          validator: (value) => Validators.confirmPassword(
                            value,
                            _passwordController.text,
                          ),
                        ),
                        const SizedBox(height: 18),
                        AgreeCheckboxRow(
                          value: _agreed,
                          hasError: _agreeError,
                          onChanged: (value) => setState(() {
                            _agreed = value;
                            _agreeError = false;
                          }),
                          onTermsTap: () => PolicyBottomSheet.show(
                            context,
                            title: 'شرایط استفاده',
                            sections: PolicyContent.terms,
                          ),
                          onPrivacyTap: () => PolicyBottomSheet.show(
                            context,
                            title: 'سیاست حریم خصوصی',
                            sections: PolicyContent.privacy,
                          ),
                        ),
                        const SizedBox(height: 18),
                        PrimaryButton(
                          label: 'ایجاد حساب کاربری',
                          gradientColors: AppColors.purpleGradient,
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
    );
  }
}
