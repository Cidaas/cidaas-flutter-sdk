part of 'authentication_bloc.dart';

abstract class AuthenticationState {}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationSuccess extends AuthenticationState {
  final TokenEntity tokenEntity;

  AuthenticationSuccess({@required this.tokenEntity});

  TokenEntity get token{
    return tokenEntity;
  }

  @override
  String toString() => 'LoggedIn { tokenEntity: $tokenEntity }';
}

class AuthenticationFailure extends AuthenticationState {}

class AuthenticationInProgress extends AuthenticationState {}
