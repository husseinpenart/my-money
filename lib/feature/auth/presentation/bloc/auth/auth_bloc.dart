// lib/feature/auth/presentation/bloc/auth/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money/core/network/backend_message.dart';
import 'package:money/core/storage/token_storage.dart';
import 'package:money/feature/auth/data/dataResource/auth_remote_data_source.dart';
import 'package:money/feature/auth/presentation/bloc/auth/auth_event.dart';
import 'package:money/feature/auth/presentation/bloc/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthBloc({required this.remoteDataSource, required this.tokenStorage})
    : super(const AuthInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final dynamic response = await remoteDataSource.register(
        name: event.name,
        phoneNumber: event.phoneNumber,
        password: event.password,
        confirmedPassword: event.confirmedPassword,
      );

      if (_isFailedResponse(response)) {
        emit(
          AuthFailure(
            message: _responseMessage(
              response,
              fallback: 'ثبت‌نام ناموفق بود.',
            ),
          ),
        );
        return;
      }

      emit(
        AuthSuccess(
          message: _responseMessage(
            response,
            fallback: 'ثبت‌نام با موفقیت انجام شد.',
          ),
        ),
      );
    } catch (error) {
      emit(AuthFailure(message: backendMessage(error)));
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final dynamic response = await remoteDataSource.login(
        phoneNumber: event.phoneNumber,
        password: event.password,
      );

      // ۱. بررسی خطای سرور
      if (_isFailedResponse(response)) {
        emit(
          AuthFailure(
            message: _responseMessage(response, fallback: 'ورود ناموفق بود.'),
          ),
        );
        return;
      }

      // ۲. خواندن و ذخیره امن توکن
      final String? token = _readToken(response);
      if (token != null && token.isNotEmpty) {
        await tokenStorage.saveToken(token);
      }

      emit(
        AuthSuccess(
          message: _responseMessage(
            response,
            fallback: 'ورود با موفقیت انجام شد.',
          ),
        ),
      );
    } catch (error) {
      emit(AuthFailure(message: backendMessage(error)));
    }
  }

  bool _isFailedResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      if (response['success'] == false) return true;
      final dynamic sc = response['statusCode'];
      if (sc is int && sc >= 400) return true;
      if (sc is String) {
        final int? p = int.tryParse(sc);
        if (p != null && p >= 400) return true;
      }
    }
    return false;
  }

  String _responseMessage(dynamic response, {required String fallback}) {
    final List<String> m = [];
    if (response is Map<String, dynamic>) {
      m.addAll(extractApiMessages(response['errors']));
      if (m.isEmpty) m.addAll(extractApiMessages(response['message']));
      final dynamic d = response['data'];
      if (d is Map<String, dynamic>) {
        if (m.isEmpty) m.addAll(extractApiMessages(d['errors']));
        if (m.isEmpty) m.addAll(extractApiMessages(d['message']));
      }
    }
    if (m.isNotEmpty) return m.join('\n');
    return fallback;
  }

  String? _readToken(dynamic response) {
    if (response is Map<String, dynamic>) {
      for (final k in ['token', 'accessToken', 'access_token', 'jwt']) {
        final v = response[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
      final d = response['data'];
      if (d is Map<String, dynamic>) {
        for (final k in ['token', 'accessToken', 'access_token', 'jwt']) {
          final v = d[k];
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
      }
    }
    return null;
  }
}
