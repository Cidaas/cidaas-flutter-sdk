part of 'authentication_bloc.dart';

abstract class AuthenticationEvent {
  const AuthenticationEvent();
}

class AuthenticationStarted extends AuthenticationEvent {}

class AuthenticationLoggedIn extends AuthenticationEvent {
  final TokenEntity tokenEntity;

  const AuthenticationLoggedIn({@required this.tokenEntity});

  @override
  String toString() => 'LoggedIn { tokenEntity: $tokenEntity }';
}

class AuthenticationLoggedOut extends AuthenticationEvent {}