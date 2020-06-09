part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();


  @override
  List<Object> get props => [];
}

class LoggedIn extends LoginEvent {
  final String token;

  const LoggedIn({@required this.token});

  @override
  List<Object> get props => [token];

  @override
  String toString() => 'LoggedIn { token: $token }';
}


class LoginFailed extends LoginEvent {}
