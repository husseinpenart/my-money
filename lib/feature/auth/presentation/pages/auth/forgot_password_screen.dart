import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:money/feature/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:money/feature/auth/presentation/bloc/auth/auth_event.dart';
import 'package:money/feature/auth/presentation/bloc/auth/auth_state.dart';
import 'package:money/helper/utils/string_utils.dart';
import 'package:money/theme/app_colors.dart';
import 'package:money/widgets/auth/app_password_field.dart';
import 'package:money/widgets/auth/app_text_field.dart';
import 'package:money/widgets/auth/auth_card.dart';
import 'package:money/widgets/auth/hero_header.dart';
import 'package:money/widgets/auth/primary_button.dart';
import 'package:money/widgets/auth/recovery_code_dialog.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => GetIt.I<AuthBloc>(),
      child: const _View(),
    );
  }
}

class _View extends StatefulWidget {
  const _View();

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    final phone = NumberHelper.toEnglishDigits(_phone.text.trim());
    final code = NumberHelper.toEnglishDigits(_code.text.trim());

    if (phone.isEmpty || code.isEmpty || _pass.text.isEmpty) {
      setState(() => _error = 'پر کردن تمامی فیلدها الزامی است');
      return;
    }
    if (_pass.text.length < 8) {
      setState(() => _error = 'رمز عبور جدید باید حداقل ۸ کاراکتر باشد');
      return;
    }
    if (_pass.text != _confirm.text) {
      setState(() => _error = 'رمز عبور و تکرار آن یکسان نیست');
      return;
    }

    setState(() => _error = null);
    context.read<AuthBloc>().add(
      ResetPasswordSubmitted(
        phoneNumber: phone,
        recoveryCode: code,
        newPassword: _pass.text,
        confirmedPassword: _confirm.text,
      ),
    );
  }

  Future<void> _onState(BuildContext context, AuthState state) async {
    if (state is AuthFailure) {
      setState(() => _error = state.message);
    } else if (state is AuthRecoverySuccess) {
      if (state.recoveryCode.isNotEmpty) {
        await showRecoveryCodeDialog(context, state.recoveryCode);
      }
      if (!context.mounted) return;
      Navigator.of(context).pop(); // برگشت به صفحه‌ی ورود
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade700,
          content: Text(
            'رمز عبور تغییر کرد. اکنون وارد شو.',
            style: const TextStyle(fontFamily: 'sans', color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: _onState,
      builder: (context, state) {
        final loading = state is AuthLoading;

        return Scaffold(
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: AbsorbPointer(
                absorbing: loading,
                child: Column(
                  children: [
                    const HeroHeader(
                      gradientColors: AppColors.blueGradient,
                      icon: Icons.lock_reset_rounded,
                      title: 'بازیابی رمز عبور',
                      subtitle: 'با کد بازیابی، رمز جدید تعیین کن',
                    ),
                    Transform.translate(
                      offset: const Offset(0, -40),
                      child: AuthCard(
                        child: Column(
                          children: [
                            AppTextField(
                              controller: _phone,
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
                              onChanged: (_) {},
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _code,
                              label: 'کد بازیابی',
                              hint: 'XXXX-XXXX-XXXX',
                              icon: Icons.vpn_key_outlined,
                              keyboardType: TextInputType.text,
                              maxLength: 20,
                              textDirection: TextDirection.ltr,
                              inputFormatters: const [],
                              validator: null,
                              onChanged: (_) {},
                            ),
                            const SizedBox(height: 16),
                            AppPasswordField(
                              controller: _pass,
                              label: 'رمز عبور جدید',
                              hint: 'حداقل ۸ کاراکتر',
                              validator: null,
                              onChanged: (_) {},
                            ),
                            const SizedBox(height: 16),
                            AppPasswordField(
                              controller: _confirm,
                              label: 'تکرار رمز عبور جدید',
                              hint: 'رمز جدید را دوباره وارد کن',
                              validator: null,
                              onChanged: (_) {},
                            ),
                            const SizedBox(height: 20),
                            PrimaryButton(
                              label: loading
                                  ? 'در حال بررسی...'
                                  : 'تغییر رمز عبور',
                              gradientColors: AppColors.blueGradient,
                              loading: loading,
                              onPressed: _submit,
                            ),
                            if (_error != null) ...[
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
                                        _error!,
                                        style: TextStyle(
                                          color: Colors.red.shade800,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: loading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              child: const Text(
                                'بازگشت به ورود',
                                style: TextStyle(fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
