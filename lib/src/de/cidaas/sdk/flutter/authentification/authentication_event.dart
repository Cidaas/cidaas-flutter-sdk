part of 'authentication_bloc.dart';

abstract class AuthenticationEvent {
  const AuthenticationEvent();
}

class AuthenticationStartedEvent extends AuthenticationEvent {}

class AuthenticationLoggedInEvent extends AuthenticationEvent {
  final TokenEntity tokenEntity;

  const AuthenticationLoggedInEvent({@required this.tokenEntity});

  @override
  String toString() => 'AuthenticationLoggedInEvent { tokenEntity: $tokenEntity }';
}

class AuthenticationLoggedOutEvent extends AuthenticationEvent {}
