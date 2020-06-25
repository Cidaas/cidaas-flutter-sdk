part of 'authentication_bloc.dart';

/// The AuthenticationEvent
abstract class AuthenticationEvent {
  const AuthenticationEvent();
}

/// Describes that the Authentication has started
class AuthenticationStartedEvent extends AuthenticationEvent {}

/// Describes that the Authentication was successful
///
/// Contains the [TokenEntity] with the access_token
class AuthenticationLoggedInEvent extends AuthenticationEvent {
  final TokenEntity tokenEntity;

  const AuthenticationLoggedInEvent({@required this.tokenEntity});

  @override
  String toString() => 'AuthenticationLoggedInEvent { tokenEntity: $tokenEntity }';
}

/// Describes that the logout has started
class AuthenticationLoggedOutEvent extends AuthenticationEvent {}
