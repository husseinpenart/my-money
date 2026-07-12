import 'password_strength.dart';

/// Pure, testable validators. Each returns `null` when valid, or a
/// Persian error message to show under the field.
class Validators {
  Validators._();

  static final RegExp _iranPhoneRegExp = RegExp(r'^09\d{9}$');

  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'شماره موبایل را وارد کنید';
    if (!_iranPhoneRegExp.hasMatch(v)) return 'شماره موبایل معتبر نیست';
    return null;
  }

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'نام و نام خانوادگی را وارد کنید';
    if (v.length < 3) return 'نام باید حداقل ۳ حرف باشد';
    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'رمز عبور را وارد کنید';
    return null;
  }

  static String? registerPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'رمز عبور را وارد کنید';
    final result = PasswordStrengthResult.fromPassword(v);
    if (result.score < 2) return 'رمز عبور ضعیف است، شرایط بالا را کامل کنید';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'تکرار رمز عبور را وارد کنید';
    if (value != password) return 'رمز عبور مطابقت ندارد';
    return null;
  }
}
