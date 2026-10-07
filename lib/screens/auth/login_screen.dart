// lib/feature/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:money/feature/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/auth/auth_event.dart';
import 'package:money/feature/auth/presentation/bloc/auth/auth_state.dart';
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

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToRegister() {
    if (context.read<AuthBloc>().state is AuthLoading) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  void _submit() {
    // بدون validator، validate() همیشه true است → درخواست حتماً به سرور می‌رود.
    _formKey.currentState?.validate();

    context.read<AuthBloc>().add(
      LoginSubmitted(
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _showMessage({required String message, required bool isError}) {
    if (!mounted) return;
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
    if (!mounted) return;

    if (state is AuthFailure) {
      _showMessage(message: state.message, isError: true);
      return;
    }

    if (state is AuthSuccess) {
      _showMessage(message: state.message, isError: false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SuccessScreen(
            title: 'ورود موفق!',
            subtitle: 'خوش برگشتید\nدر حال ورود به برنامه...',
          ),
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
                                hint: '0912 000 0000', // لاتین
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
                                hint: 'رمز عبور خود را وارد کنید',
                                validator: null, // 👈 خطا از سرور
                              ),

                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: isLoading ? null : () {},
                                  child: const Text(
                                    'فراموشی رمز عبور؟',
                                    style: TextStyle(fontSize: 12.5),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 2),

                              PrimaryButton(
                                label: 'ورود به حساب',
                                gradientColors: AppColors.blueGradient,
                                loading: isLoading,
                                onPressed: isLoading ? null : _submit,
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
          ),
        );
      },
    );
  }
}
