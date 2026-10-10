abstract class AuthEvent {
  const AuthEvent();
}

class LoginSubmitted extends AuthEvent {
  final String phoneNumber;
  final String password;

  const LoginSubmitted({required this.phoneNumber, required this.password});
}

class RegisterSubmitted extends AuthEvent {
  final String name;
  final String phoneNumber;
  final String password;
  final String confirmedPassword;
  final bool agreedToTerms;

  const RegisterSubmitted({
    required this.name,
    required this.phoneNumber,
    required this.password,
    required this.confirmedPassword,
    required this.agreedToTerms,
  });
}

class ResetPasswordSubmitted extends AuthEvent {
  final String phoneNumber;
  final String recoveryCode;
  final String newPassword;
  final String confirmedPassword;

  const ResetPasswordSubmitted({
    required this.phoneNumber,
    required this.recoveryCode,
    required this.newPassword,
    required this.confirmedPassword,
  });
}
