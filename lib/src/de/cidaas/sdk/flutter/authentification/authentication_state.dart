part of 'authentication_bloc.dart';

abstract class AuthenticationState {
  const AuthenticationState();
}

class AuthenticationSuccessState extends AuthenticationState {
  final TokenEntity tokenEntity;

  AuthenticationSuccessState({@required this.tokenEntity});

  TokenEntity get token{
    return tokenEntity;
  }

  @override
  String toString() => 'LoggedIn { tokenEntity: $tokenEntity }';
}

class AuthenticationFailureState extends AuthenticationState {
  final String error;

  const AuthenticationFailureState({@required this.error});

  @override
  String toString() => 'AuthenticationFailure { error: $error }';
}

class AuthenticationLoggedOutState extends AuthenticationState {}

class AuthenticationInProgressState extends AuthenticationState {}
