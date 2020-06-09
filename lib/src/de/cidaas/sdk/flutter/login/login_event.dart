part of 'login_bloc.dart';

abstract class LoginEvent {
  const LoginEvent();
}

class LoggedIn extends LoginEvent {
  final TokenEntity tokenEntity;

  const LoggedIn({@required this.tokenEntity});

  @override
  String toString() => 'LoggedIn { tokenEntity: $tokenEntity }';
}


class LoginFailed extends LoginEvent {}
