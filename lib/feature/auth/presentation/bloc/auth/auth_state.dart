abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final String message;

  const AuthSuccess({required this.message});
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});
}

/// بعد از بازیابی موفق؛ کد بازیابی جدید باید به کاربر نشان داده شود
class AuthRecoverySuccess extends AuthState {
  final String message;
  final String recoveryCode;

  const AuthRecoverySuccess({
    required this.message,
    required this.recoveryCode,
  });
}
