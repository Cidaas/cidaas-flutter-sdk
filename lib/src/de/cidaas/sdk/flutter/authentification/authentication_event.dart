import 'package:cidaassdkflutter/src/de/cidaas/sdk/flutter/entity/token_entity.dart';
import 'package:meta/meta.dart';

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
