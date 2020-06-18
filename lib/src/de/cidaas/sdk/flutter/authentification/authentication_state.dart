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
  String toString() => 'AuthenticationSuccessState { tokenEntity: $tokenEntity }';
}

class AuthenticationFailureState extends AuthenticationState {
  final String error;

  const AuthenticationFailureState({@required this.error});

  @override
  String toString() => 'AuthenticationFailureState { error: $error }';
}

class AuthenticationShowLoginWithBrowserState extends AuthenticationState {}

class AuthenticationHasLoggedOutState extends AuthenticationState {}

class AuthenticationInProgressState extends AuthenticationState {}
