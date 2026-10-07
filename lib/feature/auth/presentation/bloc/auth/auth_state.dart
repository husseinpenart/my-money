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
