import 'dart:async';

import 'package:bloc/bloc.dart';
import './../authentification/authentication.dart';
import './../authentification/authentication_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';


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
    if (event is LoginButtonPressed) {
      yield LoginInProgress();

      try {
        /*final token = await authHandler.authenticate(
          username: event.username,
          password: event.password,
        );

        authenticationBloc.add(AuthenticationLoggedIn(token: token));*/
        yield LoginInitial();
      } catch (error) {
        yield LoginFailure(error: error.toString());
      }
    }
  }
}