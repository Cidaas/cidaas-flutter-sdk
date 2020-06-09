import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import './../authentification/authentication.dart';
import './../authentification/authentication_handler.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthHandler authHandler;
  final AuthenticationBloc authenticationBloc;

  LoginBloc({
    @required this.authHandler,
    @required this.authenticationBloc,
  })  : assert(authHandler != null),
        assert(authenticationBloc != null);

  @override
  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoggedIn) {
      yield LoginInitial();
      authenticationBloc.add(AuthenticationLoggedIn(token: event.props.first));
      yield LoginInitial();
    }
    if (event is LoginFailed) {
      yield LoginFailure();
    }
  }
}
