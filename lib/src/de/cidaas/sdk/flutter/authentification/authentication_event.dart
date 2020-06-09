import 'package:cidaassdkflutter/src/de/cidaas/sdk/flutter/entity/token_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AuthenticationStarted extends AuthenticationEvent {}

class AuthenticationLoggedIn extends AuthenticationEvent {
  final TokenEntity tokenEntity;

  const AuthenticationLoggedIn({@required this.tokenEntity});

  @override
  List<Object> get props => [tokenEntity];

  @override
  String toString() => 'LoggedIn { tokenEntity: $tokenEntity }';
}

class AuthenticationLoggedOut extends AuthenticationEvent {}