//  class for all events in bloc section items
abstract class AuthEvent {
  const AuthEvent();
}

//  login submit
class LoginSubmitted extends AuthEvent {
  final String phoneNumber;
  final String password;

  const LoginSubmitted({required this.phoneNumber, required this.password});
}

class RegisterSubmitted extends AuthEvent {
  final String identity;
  final String phoneNumber;
  final String password;
  final String confirmedPassword;

  const RegisterSubmitted({
    required this.identity,
    required this.phoneNumber,
    required this.password,
    required this.confirmedPassword,
  });
}
    