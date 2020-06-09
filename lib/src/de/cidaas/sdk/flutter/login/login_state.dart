part of 'login_bloc.dart';


abstract class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {}

class LoginInProgress extends LoginState {}

class LoginFailure extends LoginState {
  final String error;

  const LoginFailure({@required this.error});

  @override
  String toString() => 'LoginFailure { error: $error }';
}